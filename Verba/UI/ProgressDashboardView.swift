import Charts
import SwiftData
import SwiftUI

struct ProgressDashboardView: View {
    @Query(sort: \TrainingSession.startedAt, order: .reverse)
    private var sessions: [TrainingSession]

    @Query(sort: \Badge.earnedAt, order: .reverse)
    private var badges: [Badge]

    var body: some View {
        let summary = TrainingProgressSummary(sessions: sessions, badges: badges)

        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("progress")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(summary.streakDaysThisWeek) days practised this week")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
            }

            latestSessions(summary.latestTen)

            scoreTrend(summary.latestTen.reversed())

            dimensionBars(summary.sevenDayComparison)

            milestoneTargets(summary.milestoneTargets)

            badgeRow
        }
        .padding(28)
        .frame(minWidth: 680, minHeight: 620)
        .background(Color(hex: 0x000000))
    }

    private func latestSessions(_ sessions: [TrainingSession]) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
            GridRow {
                tableHeader("date")
                tableHeader("exercise")
                tableHeader("scores")
                tableHeader("total")
                tableHeader("fix")
            }

            ForEach(sessions, id: \.id) { session in
                GridRow {
                    tableCell(session.startedAt.formatted(date: .numeric, time: .omitted))
                    tableCell(exerciseLabel(session.exerciseId))
                    tableCell(scoreLabel(session.dimensions))
                    tableCell("\(Int(session.total))/20")
                    tableCell(session.fix.isEmpty ? "-" : session.fix)
                }
            }

            if sessions.isEmpty {
                GridRow {
                    tableCell("no sessions yet")
                    tableCell("-")
                    tableCell("-")
                    tableCell("-")
                    tableCell("-")
                }
            }
        }
    }

    private func scoreTrend(_ sessions: ReversedCollection<[TrainingSession]>) -> some View {
        Chart(Array(sessions.enumerated()), id: \.element.id) { index, session in
            LineMark(
                x: .value("session", index + 1),
                y: .value("total", session.total)
            )
            PointMark(
                x: .value("session", index + 1),
                y: .value("total", session.total)
            )
        }
        .chartYScale(domain: 0...20)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 5, 10, 15, 20])
        }
        .foregroundStyle(.white)
        .frame(height: 150)
    }

    private func dimensionBars(_ comparisons: [DimensionComparison]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(comparisons, id: \.dimension) { comparison in
                HStack(spacing: 10) {
                    Text(comparison.dimension.rawValue)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .frame(width: 72, alignment: .leading)

                    bar(value: comparison.priorAverage, opacity: 0.28)
                    bar(value: comparison.currentAverage, opacity: 0.82)
                }
            }
        }
    }

    private func milestoneTargets(_ targets: [MilestoneTarget]) -> some View {
        HStack(spacing: 18) {
            ForEach(targets) { target in
                VStack(alignment: .leading, spacing: 4) {
                    Text("week \(target.week)")
                    Text("\(Int(target.targetTotal))/20")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.78))
            }
        }
    }

    private var badgeRow: some View {
        HStack(spacing: 12) {
            badgeCount(.firstSixteenPlus, label: "16+")
            badgeCount(.phraseRecall, label: "phrase recall")
            badgeCount(.noJargonRound, label: "no jargon")
        }
    }

    private func badgeCount(_ kind: BadgeKind, label: String) -> some View {
        Text("\(badges.filter { $0.kind == kind }.count) \(label)")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.78))
    }

    private func bar(value: Double, opacity: Double) -> some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(.white.opacity(opacity))
                .frame(width: proxy.size.width * min(max(value / 5.0, 0), 1))
        }
        .frame(height: 6)
    }

    private func tableHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
    }

    private func tableCell(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.white.opacity(0.72))
    }

    private func exerciseLabel(_ id: String) -> String {
        id.replacingOccurrences(of: "exercise-", with: "")
    }

    private func scoreLabel(_ dimensions: TrainingScoreDimensions) -> String {
        [
            dimensions.clarity,
            dimensions.jargon,
            dimensions.outcome,
            dimensions.delivery
        ]
        .map { String(Int($0)) }
        .joined(separator: " · ")
    }
}
