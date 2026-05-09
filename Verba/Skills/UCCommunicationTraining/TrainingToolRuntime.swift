import Foundation

actor TrainingToolRuntime {
    private let trainingStore: TrainingStore?
    private let scoringEngine: TrainingScoringEngine
    private let badgeEngine: TrainingBadgeEngine
    private var roundStartsByExerciseID: [String: Date] = [:]
    private var jargonInterruptionsByExerciseID: [String: [String]] = [:]
    private var phraseRecallResults: [Int: PhraseRecallVerdict] = [:]
    private var activeExerciseID: String?

    init(
        trainingStore: TrainingStore? = nil,
        scoringEngine: TrainingScoringEngine = TrainingScoringEngine(),
        badgeEngine: TrainingBadgeEngine = TrainingBadgeEngine()
    ) {
        self.trainingStore = trainingStore
        self.scoringEngine = scoringEngine
        self.badgeEngine = badgeEngine
    }

    func startRound(argumentsJSON: String) throws -> SkillToolResult {
        let arguments = try decode(StartRoundArguments.self, from: argumentsJSON)
        activeExerciseID = arguments.exerciseId
        roundStartsByExerciseID[arguments.exerciseId] = Date()
        jargonInterruptionsByExerciseID[arguments.exerciseId] = []
        phraseRecallResults.removeAll()
        return try jsonResult(StartRoundResult(status: "started", exerciseId: arguments.exerciseId))
    }

    func recordSession(argumentsJSON: String) async throws -> SkillToolResult {
        let arguments = try decode(RecordSessionArguments.self, from: argumentsJSON)
        let dimensions = try scoringEngine.validate(arguments.dimensions)
        let endedAt = Date()
        let startedAt = roundStartsByExerciseID[arguments.exerciseId]
            ?? endedAt.addingTimeInterval(-arguments.durationSec)
        let transcriptRef = UUID(uuidString: arguments.transcriptId)
        let jargonInterruptionCount = jargonInterruptionsByExerciseID[arguments.exerciseId, default: []].count
        let wordForWordPhraseRecallCount = phraseRecallResults.values.filter { $0 == .wordForWord }.count

        let sessionID: UUID
        let awardedBadges: [BadgeKind]
        if let trainingStore {
            let persisted = try await MainActor.run {
                let hasPriorSixteenPlus = try trainingStore.recentSessions(limit: 1_000).contains {
                    $0.exerciseId == arguments.exerciseId && $0.total >= 16
                }
                let earnedBadges = badgeEngine.earnedBadges(
                    context: TrainingBadgeContext(
                        exerciseId: arguments.exerciseId,
                        total: dimensions.total,
                        jargonInterruptionCount: jargonInterruptionCount,
                        wordForWordPhraseRecallCount: wordForWordPhraseRecallCount,
                        hasPriorSixteenPlusForExercise: hasPriorSixteenPlus
                    )
                )
                let session = TrainingSession(
                    exerciseId: arguments.exerciseId,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    dimensions: dimensions,
                    strongestQuote: arguments.strongestQuote,
                    weakestQuote: arguments.weakestQuote,
                    fix: arguments.fix,
                    transcriptRef: transcriptRef
                )
                try trainingStore.insertSession(session)
                for badgeKind in earnedBadges {
                    try trainingStore.insertBadge(
                        Badge(kind: badgeKind, sessionRef: session.id)
                    )
                }
                return (session.id, earnedBadges)
            }
            sessionID = persisted.0
            awardedBadges = persisted.1
        } else {
            sessionID = UUID()
            awardedBadges = badgeEngine.earnedBadges(
                context: TrainingBadgeContext(
                    exerciseId: arguments.exerciseId,
                    total: dimensions.total,
                    jargonInterruptionCount: jargonInterruptionCount,
                    wordForWordPhraseRecallCount: wordForWordPhraseRecallCount,
                    hasPriorSixteenPlusForExercise: false
                )
            )
        }

        roundStartsByExerciseID[arguments.exerciseId] = nil
        activeExerciseID = nil

        return try jsonResult(
            RecordSessionResult(
                status: "recorded",
                sessionId: sessionID.uuidString,
                persisted: trainingStore != nil,
                total: dimensions.total,
                badges: awardedBadges.map(\.rawValue)
            )
        )
    }

    func flagJargonInterruption(argumentsJSON: String) throws -> SkillToolResult {
        let arguments = try decode(FlagJargonInterruptionArguments.self, from: argumentsJSON)
        let exerciseID = arguments.exerciseId ?? activeExerciseID ?? "active"
        jargonInterruptionsByExerciseID[exerciseID, default: []].append(arguments.word)
        return try jsonResult(
            FlagJargonInterruptionResult(
                status: "flagged",
                word: arguments.word,
                count: jargonInterruptionsByExerciseID[exerciseID, default: []].count
            )
        )
    }

    func recallPhraseResult(argumentsJSON: String) throws -> SkillToolResult {
        let arguments = try decode(RecallPhraseResultArguments.self, from: argumentsJSON)
        phraseRecallResults[arguments.phraseIndex] = arguments.verdict
        return try jsonResult(
            RecallPhraseResultResult(
                status: "recorded",
                phraseIndex: arguments.phraseIndex,
                verdict: arguments.verdict
            )
        )
    }

    func getRecentScores(argumentsJSON: String) async throws -> SkillToolResult {
        let arguments = try decode(GetRecentScoresArguments.self, from: argumentsJSON)
        let scores: [RecentScoreSummary]

        if let trainingStore {
            scores = try await MainActor.run {
                try trainingStore.recentSessions(limit: arguments.limit).map(RecentScoreSummary.init)
            }
        } else {
            scores = []
        }

        return try jsonResult(GetRecentScoresResult(scores: scores))
    }

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    private func jsonResult<T: Encodable>(_ payload: T) throws -> SkillToolResult {
        let data = try JSONEncoder().encode(payload)
        return SkillToolResult(json: String(decoding: data, as: UTF8.self))
    }
}

private struct StartRoundArguments: Decodable {
    let exerciseId: String
}

private struct StartRoundResult: Encodable {
    let status: String
    let exerciseId: String
}

private struct RecordSessionArguments: Decodable {
    let exerciseId: String
    let dimensions: TrainingScoreDimensions
    let total: Double
    let strongestQuote: String
    let weakestQuote: String
    let fix: String
    let durationSec: TimeInterval
    let transcriptId: String
}

private struct RecordSessionResult: Encodable {
    let status: String
    let sessionId: String
    let persisted: Bool
    let total: Double
    let badges: [String]
}

private struct FlagJargonInterruptionArguments: Decodable {
    let exerciseId: String?
    let word: String
}

private struct FlagJargonInterruptionResult: Encodable {
    let status: String
    let word: String
    let count: Int
}

private struct RecallPhraseResultArguments: Decodable {
    let phraseIndex: Int
    let verdict: PhraseRecallVerdict
}

private enum PhraseRecallVerdict: String, Codable {
    case wordForWord
    case paraphrased
    case wrong
}

private struct RecallPhraseResultResult: Encodable {
    let status: String
    let phraseIndex: Int
    let verdict: PhraseRecallVerdict
}

private struct GetRecentScoresArguments: Decodable {
    let limit: Int
}

private struct GetRecentScoresResult: Encodable {
    let scores: [RecentScoreSummary]
}

private struct RecentScoreSummary: Encodable {
    let exerciseId: String
    let clarity: Double
    let jargon: Double
    let outcome: Double
    let delivery: Double
    let total: Double
    let fix: String

    init(session: TrainingSession) {
        self.exerciseId = session.exerciseId
        self.clarity = session.dimensions.clarity
        self.jargon = session.dimensions.jargon
        self.outcome = session.dimensions.outcome
        self.delivery = session.dimensions.delivery
        self.total = session.total
        self.fix = session.fix
    }
}
