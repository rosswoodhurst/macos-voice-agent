import Foundation
import AVFoundation
import SwiftData
import Testing
@testable import Verba

struct VerbaTests {
    @Test func realtimeModelIsFixed() {
        #expect(AppConfig.appDisplayName == "Karen")
        #expect(AppConfig.realtimeModel == "gpt-realtime-2")
    }

    @Test func apiKeyMaskOnlyShowsLastFourCharacters() {
        #expect(APIKeyMasker.masked("sk-proj-1234567890") == "configured ...7890")
    }

    @Test func apiKeyMaskShowsUnconfiguredStateForMissingKey() {
        #expect(APIKeyMasker.masked(nil) == "not configured")
        #expect(APIKeyMasker.masked("") == "not configured")
    }

    @Test func instructionComposerAppendsActiveSkillPrompt() {
        let composer = RealtimeInstructionComposer(basePersona: "base")

        #expect(composer.compose(activeSkillPromptFragment: "skill") == "base\n\nskill")
        #expect(composer.compose(activeSkillPromptFragment: nil) == "base")
        #expect(composer.compose(activeSkillPromptFragment: "  ") == "base")
    }

    @Test func sessionUpdateUsesFixedRealtimeModel() throws {
        let tool = RealtimeToolDefinition(
            name: "record_session",
            description: "Persist score.",
            parameters: .object(properties: [:], required: [])
        )
        let configuration = RealtimeSessionConfiguration(instructions: "coach", tools: [tool])
        let event = configuration.sessionUpdateEvent()

        #expect(event.type == "session.update")
        #expect(event.session?.model == "gpt-realtime-2")
        #expect(event.session?.instructions == "coach")
        #expect(event.session?.audio.output.format.rate == 24_000)
        #expect(event.session?.tools == [tool])
    }

    @Test func webSocketRealtimeURLUsesFixedModel() throws {
        let url = try WebSocketRealtimeTransport.realtimeURL(model: AppConfig.realtimeModel)

        #expect(url.absoluteString == "wss://api.openai.com/v1/realtime?model=gpt-realtime-2")
    }

    @MainActor
    @Test func skillRegistryPreservesRegistrationOrder() throws {
        let registry = SkillRegistry()
        try registry.register(TestSkill(id: "first"))
        try registry.register(TestSkill(id: "second"))

        #expect(registry.allSkills.map(\.id) == ["first", "second"])
        #expect(try registry.requireSkill(id: "second").id == "second")
    }

    @MainActor
    @Test func defaultRegistryRegistersOnlyTrainingSkill() throws {
        let registry = try DefaultSkillRegistry.make()

        #expect(registry.allSkills.map(\.id) == ["uc-communication-training"])
    }

    @MainActor
    @Test func skillRegistryRejectsDuplicateIDs() throws {
        let registry = SkillRegistry()
        try registry.register(TestSkill(id: "training"))

        do {
            try registry.register(TestSkill(id: "training"))
            Issue.record("Expected duplicate registration to throw.")
        } catch SkillRegistryError.duplicateSkillID(let id) {
            #expect(id == "training")
        }
    }

    @Test func realtimeToolDefinitionEncodesFunctionSchema() throws {
        let tool = RealtimeToolDefinition(
            name: "record_session",
            description: "Persist a finished round.",
            parameters: .object(
                properties: [
                    "exerciseId": .string(),
                    "total": .integer
                ],
                required: ["exerciseId", "total"]
            )
        )

        let data = try JSONEncoder().encode(tool)
        let decoded = try JSONDecoder().decode(RealtimeToolDefinition.self, from: data)

        #expect(decoded == tool)
    }

    @Test func inputAudioBufferAppendEventBase64EncodesPCM() {
        let data = Data([0x01, 0x02, 0x03])
        let event = RealtimeClientEvent.inputAudioBufferAppend(audio: data)

        #expect(event.type == "input_audio_buffer.append")
        #expect(event.audio == data.base64EncodedString())
    }

    @MainActor
    @Test func trainingSkillExposesRequiredTools() {
        let skill = UCCommunicationTrainingSkill()
        let toolNames = skill.tools.map(\.name)

        #expect(toolNames == [
            "record_session",
            "start_round",
            "flag_jargon_interruption",
            "recall_phrase_result",
            "get_recent_scores"
        ])
        #expect(Set(skill.makeToolHandlers().keys) == Set(toolNames))
    }

    @MainActor
    @Test func trainingSkillPromptIncludesAllExercisesAndGuardrail() {
        let prompt = UCCommunicationTrainingSkill().systemPromptFragment

        #expect(TrainingExercises.all.count == 10)
        #expect(prompt.contains("Do not flatter. If a score above 4 cannot be justified by a specific quote from the user's speech in this round, lower it. Real customers won't be polite."))
        #expect(prompt.contains("Exercise 1: Translation Drill (Technical → Sales → Executive)"))
        #expect(prompt.contains("Exercise 10: Trigger Phrase Sales Coaching"))
    }

    @MainActor
    @Test func trainingRecordSessionToolPersistsThroughStore() async throws {
        let container = try ModelContainer(
            for: TrainingSession.self,
            Transcript.self,
            Badge.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let store = TrainingStore(modelContext: container.mainContext)
        let runtime = TrainingToolRuntime(trainingStore: store)
        let skill = UCCommunicationTrainingSkill(runtime: runtime)
        let handlers = skill.makeToolHandlers()

        _ = try await handlers["start_round"]?(
            SkillToolInvocation(
                name: "start_round",
                argumentsJSON: #"{"exerciseId":"exercise-1"}"#
            )
        )

        let result = try await handlers["record_session"]?(
            SkillToolInvocation(
                name: "record_session",
                argumentsJSON: """
                {
                  "exerciseId": "exercise-1",
                  "dimensions": {
                    "clarity": 4,
                    "jargon": 4,
                    "outcome": 4,
                    "delivery": 4
                  },
                  "total": 16,
                  "strongestQuote": "clear",
                  "weakestQuote": "weak",
                  "fix": "shorten it",
                  "durationSec": 60,
                  "transcriptId": "\(UUID().uuidString)"
                }
                """
            )
        )

        let recent = try store.recentSessions(limit: 10)
        let badges = try store.badges()

        #expect(result?.json.contains(#""persisted":true"#) == true)
        #expect(recent.count == 1)
        #expect(recent.first?.exerciseId == "exercise-1")
        #expect(recent.first?.total == 16)
        #expect(Set(badges.map(\.kind)) == [.firstSixteenPlus, .noJargonRound])
    }

    @Test func trainingScoringEngineTotalsFourDimensions() throws {
        let dimensions = TrainingScoreDimensions(
            clarity: 4,
            jargon: 3,
            outcome: 5,
            delivery: 4
        )

        let total = try TrainingScoringEngine().normalizedTotal(for: dimensions)

        #expect(total == 16)
    }

    @Test func trainingScoringEngineRejectsOutOfRangeScores() {
        let dimensions = TrainingScoreDimensions(
            clarity: 0,
            jargon: 3,
            outcome: 5,
            delivery: 4
        )

        do {
            _ = try TrainingScoringEngine().normalizedTotal(for: dimensions)
            Issue.record("Expected out-of-range score to throw.")
        } catch TrainingScoringError.dimensionOutOfRange(let dimension, let score) {
            #expect(dimension == .clarity)
            #expect(score == 0)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func badgeEngineAwardsCoreBadges() {
        let badges = TrainingBadgeEngine().earnedBadges(
            context: TrainingBadgeContext(
                exerciseId: "exercise-9",
                total: 16,
                jargonInterruptionCount: 0,
                wordForWordPhraseRecallCount: 8,
                hasPriorSixteenPlusForExercise: false
            )
        )

        #expect(badges == [.firstSixteenPlus, .phraseRecall, .noJargonRound])
    }

    @Test func badgeEngineDoesNotRepeatSixteenPlusBadge() {
        let badges = TrainingBadgeEngine().earnedBadges(
            context: TrainingBadgeContext(
                exerciseId: "exercise-3",
                total: 18,
                jargonInterruptionCount: 2,
                wordForWordPhraseRecallCount: 0,
                hasPriorSixteenPlusForExercise: true
            )
        )

        #expect(badges.isEmpty)
    }

    @MainActor
    @Test func progressSummaryCalculatesStreakAndLatestSessions() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_000_000)
        let sessionA = TrainingSession(
            exerciseId: "exercise-1",
            startedAt: now,
            dimensions: TrainingScoreDimensions(clarity: 3, jargon: 3, outcome: 3, delivery: 3),
            strongestQuote: "",
            weakestQuote: "",
            fix: ""
        )
        let sessionB = TrainingSession(
            exerciseId: "exercise-2",
            startedAt: now.addingTimeInterval(-86_400),
            dimensions: TrainingScoreDimensions(clarity: 4, jargon: 4, outcome: 4, delivery: 4),
            strongestQuote: "",
            weakestQuote: "",
            fix: ""
        )

        let summary = TrainingProgressSummary(
            sessions: [sessionB, sessionA],
            badges: [],
            now: now,
            calendar: calendar
        )

        #expect(summary.latestTen.map(\.exerciseId) == ["exercise-1", "exercise-2"])
        #expect(summary.streakDaysThisWeek == 2)
    }

    @Test func audioAmplitudeMeterReadsPCM16Level() {
        var samples: [Int16] = [0, Int16.max, 0, -Int16.max]
        let data = Data(bytes: &samples, count: samples.count * MemoryLayout<Int16>.size)

        let level = AudioAmplitudeMeter().normalizedRMSLevel(fromPCM16: data)

        #expect(level > 0.70)
        #expect(level < 0.72)
    }

    @Test func audioAmplitudeMeterReadsFloatBufferLevel() throws {
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 24_000,
            channels: 1,
            interleaved: false
        )
        let unwrappedFormat = try #require(format)
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: unwrappedFormat, frameCapacity: 4))
        buffer.frameLength = 4
        let samples = try #require(buffer.floatChannelData?[0])
        samples[0] = 0
        samples[1] = 1
        samples[2] = 0
        samples[3] = -1

        let level = AudioAmplitudeMeter().normalizedRMSLevel(from: buffer)

        #expect(level > 0.70)
        #expect(level < 0.72)
    }

    @Test func realtimeServerEventParsesCurrentOutputAudioDelta() throws {
        var samples: [Int16] = [0, Int16.max]
        let data = Data(bytes: &samples, count: samples.count * MemoryLayout<Int16>.size)
        let event = try RealtimeServerEvent(
            jsonString: #"{"type":"response.output_audio.delta","delta":"\#(data.base64EncodedString())"}"#
        )

        #expect(event.outputAudioDelta == data)
    }

    @Test func realtimeServerEventParsesLegacyAudioDelta() throws {
        var samples: [Int16] = [0, Int16.max]
        let data = Data(bytes: &samples, count: samples.count * MemoryLayout<Int16>.size)
        let event = try RealtimeServerEvent(
            jsonString: #"{"type":"response.audio.delta","delta":"\#(data.base64EncodedString())"}"#
        )

        #expect(event.outputAudioDelta == data)
    }

    @Test func realtimeServerEventParsesDirectFunctionCallDoneEvent() throws {
        let event = try RealtimeServerEvent(
            jsonString: #"{"type":"response.function_call_arguments.done","call_id":"call_123","name":"record_session","arguments":"{\"exerciseId\":\"exercise-1\"}"}"#
        )

        #expect(
            event.functionToolCall == RealtimeFunctionToolCall(
                callID: "call_123",
                name: "record_session",
                argumentsJSON: #"{"exerciseId":"exercise-1"}"#
            )
        )
    }

    @Test func realtimeServerEventParsesNestedFunctionCallDoneEvent() throws {
        let event = try RealtimeServerEvent(
            jsonString: #"{"type":"response.function_call_arguments.done","item":{"id":"item_123","call_id":"call_456","name":"start_round","arguments":"{\"exerciseId\":\"exercise-2\"}"}}"#
        )

        #expect(
            event.functionToolCall == RealtimeFunctionToolCall(
                callID: "call_456",
                name: "start_round",
                argumentsJSON: #"{"exerciseId":"exercise-2"}"#
            )
        )
    }

    @MainActor
    @Test func realtimeToolCallResponderSendsFunctionOutputAndNextResponse() async throws {
        let transport = SpyRealtimeTransport()
        let responder = RealtimeToolCallResponder(
            handlers: [
                "start_round": { invocation in
                    #expect(invocation.argumentsJSON == #"{"exerciseId":"exercise-2"}"#)
                    return SkillToolResult(json: #"{"status":"started"}"#)
                }
            ],
            transport: transport
        )
        let event = try RealtimeServerEvent(
            jsonString: #"{"type":"response.function_call_arguments.done","call_id":"call_123","name":"start_round","arguments":"{\"exerciseId\":\"exercise-2\"}"}"#
        )

        let handled = try await responder.handle(event)
        let sent = await transport.sentEvents

        #expect(handled)
        #expect(sent == [
            .functionCallOutput(callID: "call_123", output: #"{"status":"started"}"#),
            .responseCreate()
        ])
    }

    @MainActor
    @Test func realtimeSessionControllerConnectsSkillToolsAndStartsMicrophone() async throws {
        let tool = RealtimeToolDefinition(
            name: "start_round",
            description: "Start.",
            parameters: .object(properties: [:], required: [])
        )
        let transport = SpyRealtimeTransport()
        let capture = FakeMicrophoneCapture()
        var levels: [Double] = []
        let controller = RealtimeSessionController(
            authProvider: StaticAuthProvider(apiKey: "sk-test-1234567890"),
            transport: transport,
            activeSkill: TestSkill(id: "skill", tools: [tool]),
            makeMicrophoneCapture: { capture },
            onInputLevel: { levels.append($0) },
            onServerEvent: { _ in }
        )

        try await controller.start()
        capture.emit(Data([0x01]), level: 0.25)
        try await Task.sleep(nanoseconds: 10_000_000)

        #expect(controller.isRunning)
        #expect(capture.startCount == 1)
        #expect(await transport.connectedConfigurations.map(\.tools) == [[tool]])
        #expect(levels == [0.25])

        await controller.stop()

        #expect(capture.stopCount == 1)
        #expect(await transport.disconnectCount == 1)
    }

    @Test func pcm16BufferFactoryConvertsLittleEndianSamplesToFloatBuffer() throws {
        var samples: [Int16] = [0, Int16.max]
        let data = Data(bytes: &samples, count: samples.count * MemoryLayout<Int16>.size)

        let buffer = try PCM16AudioBufferFactory().makeFloatBuffer(fromPCM16: data)
        let channel = try #require(buffer.floatChannelData?[0])

        #expect(buffer.frameLength == 2)
        #expect(channel[0] == 0)
        #expect(channel[1] > 0.99)
    }

    @Test func pcm16AudioConverterConvertsFloatBufferToLittleEndianPCM() throws {
        let format = try #require(AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 24_000,
            channels: 1,
            interleaved: false
        ))
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 2))
        buffer.frameLength = 2
        let channel = try #require(buffer.floatChannelData?[0])
        channel[0] = 0
        channel[1] = 1

        let data = PCM16AudioConverter().pcm16Data(from: buffer)

        #expect(data.count == 4)
        #expect(AudioAmplitudeMeter().normalizedRMSLevel(fromPCM16: data) > 0.70)
    }

    @MainActor
    @Test func realtimeMicrophoneStreamerSendsInputAudioAppendEvents() async throws {
        let data = Data([0x01, 0x02, 0x03])
        let transport = SpyRealtimeTransport()
        var inputLevels: [Double] = []
        let streamer = RealtimeMicrophoneStreamer(
            capture: FakeMicrophoneCapture(),
            transport: transport,
            onInputLevel: { inputLevels.append($0) }
        )

        try await streamer.handleCapturedAudio(data: data, level: 0.42)

        #expect(inputLevels == [0.42])
        #expect(await transport.sentEvents == [
            .inputAudioBufferAppend(audio: data)
        ])
    }

    @MainActor
    @Test func appStateRoutesRealtimeAudioToPlayerAndAmplitudeMeter() throws {
        var samples: [Int16] = [0, Int16.max, 0, -Int16.max]
        let data = Data(bytes: &samples, count: samples.count * MemoryLayout<Int16>.size)
        let player = SpyAudioOutputPlayer()
        let appState = AppState(
            authProvider: StaticAuthProvider(apiKey: "sk-test-1234567890"),
            audioOutputPlayer: player
        )
        let deltaEvent = try RealtimeServerEvent(
            jsonString: #"{"type":"response.output_audio.delta","delta":"\#(data.base64EncodedString())"}"#
        )

        try appState.handleRealtimeServerEvent(deltaEvent)

        #expect(player.playedPCM16 == [data])
        #expect(appState.voicePhase == .speaking)
        #expect(appState.outputLevel > 0.70)
        #expect(appState.outputLevel < 0.72)

        let doneEvent = try RealtimeServerEvent(jsonString: #"{"type":"response.output_audio.done"}"#)
        try appState.handleRealtimeServerEvent(doneEvent)

        #expect(player.stopCount == 1)
        #expect(appState.voicePhase == .idle)
        #expect(appState.outputLevel == 0)
    }

    @MainActor
    @Test func trainingStoreReturnsMostRecentSessionsFirst() throws {
        let container = try ModelContainer(
            for: TrainingSession.self,
            Transcript.self,
            Badge.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let store = TrainingStore(modelContext: container.mainContext)

        try store.insertSession(
            TrainingSession(
                exerciseId: "exercise-1",
                startedAt: Date(timeIntervalSince1970: 1),
                dimensions: TrainingScoreDimensions(
                    clarity: 3,
                    jargon: 3,
                    outcome: 3,
                    delivery: 3
                ),
                strongestQuote: "",
                weakestQuote: "",
                fix: ""
            )
        )
        try store.insertSession(
            TrainingSession(
                exerciseId: "exercise-2",
                startedAt: Date(timeIntervalSince1970: 2),
                dimensions: TrainingScoreDimensions(
                    clarity: 4,
                    jargon: 4,
                    outcome: 4,
                    delivery: 4
                ),
                strongestQuote: "",
                weakestQuote: "",
                fix: ""
            )
        )

        let recent = try store.recentSessions(limit: 10)

        #expect(recent.map(\.exerciseId) == ["exercise-2", "exercise-1"])
    }
}

private struct TestSkill: Skill {
    let id: String
    let displayName: String
    let systemPromptFragment: String
    let tools: [RealtimeToolDefinition]

    init(id: String, tools: [RealtimeToolDefinition] = []) {
        self.id = id
        self.displayName = id
        self.systemPromptFragment = "test"
        self.tools = tools
    }

    func makeToolHandlers() -> [String: SkillToolHandler] {
        [:]
    }
}

private struct StaticAuthProvider: AuthProvider {
    let configuredAPIKey: String?

    init(apiKey: String?) {
        self.configuredAPIKey = apiKey
    }

    func apiKey() throws -> String? {
        configuredAPIKey
    }

    func saveAPIKey(_ apiKey: String) throws {}

    func deleteAPIKey() throws {}
}

@MainActor
private final class SpyAudioOutputPlayer: RealtimeAudioOutputPlaying {
    private(set) var playedPCM16: [Data] = []
    private(set) var stopCount = 0

    func playPCM16(_ data: Data) throws {
        playedPCM16.append(data)
    }

    func stop() {
        stopCount += 1
    }
}

private actor SpyRealtimeTransport: RealtimeTransport {
    private(set) var sentEvents: [RealtimeClientEvent] = []
    private(set) var connectedConfigurations: [RealtimeSessionConfiguration] = []
    private(set) var disconnectCount = 0

    func connect(apiKey: String, configuration: RealtimeSessionConfiguration) async throws {
        connectedConfigurations.append(configuration)
    }

    func send(_ event: RealtimeClientEvent) async throws {
        sentEvents.append(event)
    }

    func nextEvent() async throws -> RealtimeServerEvent {
        throw RealtimeTransportError.disconnected
    }

    func disconnect() async {
        disconnectCount += 1
    }
}

private final class FakeMicrophoneCapture: MicrophoneInputCapturing, @unchecked Sendable {
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private var onAudioChunk: (@Sendable (Data, Double) -> Void)?

    func start(onAudioChunk: @escaping @Sendable (Data, Double) -> Void) throws {
        startCount += 1
        self.onAudioChunk = onAudioChunk
    }

    func stop() {
        stopCount += 1
    }

    func emit(_ data: Data, level: Double) {
        onAudioChunk?(data, level)
    }
}
