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
        let configuration = RealtimeSessionConfiguration(instructions: "coach")
        let event = configuration.sessionUpdateEvent()

        #expect(event.type == "session.update")
        #expect(event.session?.model == "gpt-realtime-2")
        #expect(event.session?.instructions == "coach")
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

    init(id: String) {
        self.id = id
        self.displayName = id
        self.systemPromptFragment = "test"
        self.tools = []
    }

    func makeToolHandlers() -> [String: SkillToolHandler] {
        [:]
    }
}
