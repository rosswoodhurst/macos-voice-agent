import Foundation

struct TrainingScoreDimensions: Codable, Equatable, Sendable {
    let clarity: Double
    let jargon: Double
    let outcome: Double
    let delivery: Double

    var total: Double {
        clarity + jargon + outcome + delivery
    }
}

enum TrainingScoreDimension: String, CaseIterable, Codable, Sendable {
    case clarity
    case jargon
    case outcome
    case delivery
}
