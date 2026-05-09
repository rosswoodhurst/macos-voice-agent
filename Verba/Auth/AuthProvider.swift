import Foundation

protocol AuthProvider: Sendable {
    func apiKey() throws -> String?
    func saveAPIKey(_ apiKey: String) throws
    func deleteAPIKey() throws
}

enum AuthProviderError: LocalizedError, Equatable {
    case invalidAPIKey
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            "Enter a valid OpenAI API key."
        case .unhandledStatus(let status):
            "Keychain returned status \(status)."
        }
    }
}

enum APIKeyMasker {
    static func masked(_ apiKey: String?) -> String {
        guard let apiKey, !apiKey.isEmpty else {
            return "not configured"
        }

        let suffix = apiKey.suffix(4)
        return "configured ...\(suffix)"
    }
}
