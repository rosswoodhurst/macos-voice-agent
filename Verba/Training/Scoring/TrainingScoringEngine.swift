import Foundation

struct TrainingScoringEngine: Sendable {
    func validate(_ dimensions: TrainingScoreDimensions) throws -> TrainingScoreDimensions {
        for dimension in TrainingScoreDimension.allCases {
            let score = score(for: dimension, in: dimensions)
            guard (1.0...5.0).contains(score) else {
                throw TrainingScoringError.dimensionOutOfRange(dimension, score)
            }
        }

        return dimensions
    }

    func normalizedTotal(for dimensions: TrainingScoreDimensions) throws -> Double {
        try validate(dimensions).total
    }

    private func score(
        for dimension: TrainingScoreDimension,
        in dimensions: TrainingScoreDimensions
    ) -> Double {
        switch dimension {
        case .clarity:
            dimensions.clarity
        case .jargon:
            dimensions.jargon
        case .outcome:
            dimensions.outcome
        case .delivery:
            dimensions.delivery
        }
    }
}

enum TrainingScoringError: Error, Equatable {
    case dimensionOutOfRange(TrainingScoreDimension, Double)
}
