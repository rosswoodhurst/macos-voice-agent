import Foundation
import SwiftData

@Model
final class TrainingSession {
    @Attribute(.unique) var id: UUID
    var exerciseId: String
    var startedAt: Date
    var endedAt: Date?
    var dimensions: TrainingScoreDimensions
    var total: Double
    var strongestQuote: String
    var weakestQuote: String
    var fix: String
    var transcriptRef: UUID?

    init(
        id: UUID = UUID(),
        exerciseId: String,
        startedAt: Date,
        endedAt: Date? = nil,
        dimensions: TrainingScoreDimensions,
        strongestQuote: String,
        weakestQuote: String,
        fix: String,
        transcriptRef: UUID? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.dimensions = dimensions
        self.total = dimensions.total
        self.strongestQuote = strongestQuote
        self.weakestQuote = weakestQuote
        self.fix = fix
        self.transcriptRef = transcriptRef
    }
}
