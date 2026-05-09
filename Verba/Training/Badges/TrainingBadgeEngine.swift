import Foundation

struct TrainingBadgeEngine: Sendable {
    func earnedBadges(context: TrainingBadgeContext) -> [BadgeKind] {
        var badges: [BadgeKind] = []

        if context.total >= 16, !context.hasPriorSixteenPlusForExercise {
            badges.append(.firstSixteenPlus)
        }

        if context.exerciseId == "exercise-9",
           context.wordForWordPhraseRecallCount >= 8 {
            badges.append(.phraseRecall)
        }

        if context.jargonInterruptionCount == 0 {
            badges.append(.noJargonRound)
        }

        return badges
    }
}

struct TrainingBadgeContext: Equatable, Sendable {
    let exerciseId: String
    let total: Double
    let jargonInterruptionCount: Int
    let wordForWordPhraseRecallCount: Int
    let hasPriorSixteenPlusForExercise: Bool
}
