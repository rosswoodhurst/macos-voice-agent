import Foundation
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
