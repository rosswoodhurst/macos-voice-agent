import Foundation
import SwiftData

@Model
final class Transcript {
    @Attribute(.unique) var id: UUID
    var lines: [TranscriptLine]

    init(id: UUID = UUID(), lines: [TranscriptLine] = []) {
        self.id = id
        self.lines = lines
    }
}

struct TranscriptLine: Codable, Equatable, Sendable {
    let role: TranscriptRole
    let text: String
    let t: TimeInterval
}

enum TranscriptRole: String, Codable, Sendable {
    case user
    case assistant
    case tool
}
