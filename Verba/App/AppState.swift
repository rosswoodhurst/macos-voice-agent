import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var apiKeyStatus = "not configured"
    @Published var isSettingsPresented = false
    @Published var isProgressPresented = false
    @Published var settingsError: String?
    @Published var voicePhase: VoiceOrbPhase = .idle
    @Published var inputLevel = 0.0
    @Published var outputLevel = 0.0

    private let authProvider: AuthProvider

    init(authProvider: AuthProvider = KeychainAuthProvider()) {
        self.authProvider = authProvider
        refreshAPIKeyStatus()
        isSettingsPresented = apiKeyStatus == "not configured"
    }

    func saveAPIKey(_ apiKey: String) {
        do {
            try authProvider.saveAPIKey(apiKey)
            refreshAPIKeyStatus()
            settingsError = nil
            isSettingsPresented = false
        } catch {
            settingsError = error.localizedDescription
        }
    }

    func clearAPIKey() {
        do {
            try authProvider.deleteAPIKey()
            refreshAPIKeyStatus()
            settingsError = nil
            isSettingsPresented = true
        } catch {
            settingsError = error.localizedDescription
        }
    }

    func handlePrimaryAction() {
        switch voicePhase {
        case .idle:
            voicePhase = .listening
            inputLevel = 0.34
        case .listening:
            voicePhase = .thinking
            inputLevel = 0
        case .thinking:
            voicePhase = .speaking
            outputLevel = 0.42
        case .speaking:
            voicePhase = .idle
            outputLevel = 0
        }
    }

    private func refreshAPIKeyStatus() {
        do {
            apiKeyStatus = APIKeyMasker.masked(try authProvider.apiKey())
        } catch {
            apiKeyStatus = "not configured"
            settingsError = error.localizedDescription
        }
    }
}
