import Foundation

enum VoiceOrbPhase: Equatable, Sendable {
    case idle
    case listening
    case thinking
    case speaking

    var primaryActionTitle: String {
        switch self {
        case .idle:
            "tap to talk"
        case .listening:
            "listening..."
        case .thinking:
            "end round"
        case .speaking:
            "show score"
        }
    }
}
