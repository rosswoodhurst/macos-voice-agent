import Foundation

struct TrainingProgressSummary {
    let sessions: [TrainingSession]
    let badges: [Badge]
    let now: Date
    let calendar: Calendar

    init(
        sessions: [TrainingSession],
        badges: [Badge],
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        self.sessions = sessions
        self.badges = badges
        self.now = now
        self.calendar = calendar
    }

    var latestTen: [TrainingSession] {
        Array(sortedSessions.prefix(10))
    }

    var streakDaysThisWeek: Int {
        let days = Set(
            sessions
                .filter { calendar.isDate($0.startedAt, equalTo: now, toGranularity: .weekOfYear) }
                .map { calendar.startOfDay(for: $0.startedAt) }
        )
        return days.count
    }

    var milestoneTargets: [MilestoneTarget] {
        [
            MilestoneTarget(week: 1, targetTotal: 11),
            MilestoneTarget(week: 2, targetTotal: 13),
            MilestoneTarget(week: 3, targetTotal: 15),
            MilestoneTarget(week: 4, targetTotal: 16)
        ]
    }

    var sevenDayComparison: [DimensionComparison] {
        TrainingScoreDimension.allCases.map { dimension in
            DimensionComparison(
                dimension: dimension,
                currentAverage: averageScore(for: dimension, daysBack: 7, offsetDays: 0),
                priorAverage: averageScore(for: dimension, daysBack: 7, offsetDays: 7)
            )
        }
    }

    private var sortedSessions: [TrainingSession] {
        sessions.sorted { $0.startedAt > $1.startedAt }
    }

    private func averageScore(
        for dimension: TrainingScoreDimension,
        daysBack: Int,
        offsetDays: Int
    ) -> Double {
        guard let end = calendar.date(byAdding: .day, value: -offsetDays, to: now),
              let start = calendar.date(byAdding: .day, value: -daysBack, to: end)
        else {
            return 0
        }

        let scoped = sessions.filter { $0.startedAt >= start && $0.startedAt < end }
        guard !scoped.isEmpty else {
            return 0
        }

        let total = scoped.reduce(0.0) { partial, session in
            partial + session.dimensions.score(for: dimension)
        }
        return total / Double(scoped.count)
    }
}

struct DimensionComparison: Equatable {
    let dimension: TrainingScoreDimension
    let currentAverage: Double
    let priorAverage: Double
}

struct MilestoneTarget: Equatable, Identifiable {
    var id: Int { week }
    let week: Int
    let targetTotal: Double
}

extension TrainingScoreDimensions {
    func score(for dimension: TrainingScoreDimension) -> Double {
        switch dimension {
        case .clarity:
            clarity
        case .jargon:
            jargon
        case .outcome:
            outcome
        case .delivery:
            delivery
        }
    }
}
