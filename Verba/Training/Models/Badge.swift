import Foundation
import SwiftData

@Model
final class Badge {
    @Attribute(.unique) var id: UUID
    var kind: BadgeKind
    var earnedAt: Date
    var sessionRef: UUID?

    init(
        id: UUID = UUID(),
        kind: BadgeKind,
        earnedAt: Date = Date(),
        sessionRef: UUID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.earnedAt = earnedAt
        self.sessionRef = sessionRef
    }
}

enum BadgeKind: String, Codable, Sendable {
    case firstSixteenPlus
    case phraseRecall
    case noJargonRound
}
