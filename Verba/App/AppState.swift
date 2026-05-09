import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var apiKeyStatus = "not configured"
    @Published var isSettingsPresented = false
    @Published var settingsError: String?

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

    private func refreshAPIKeyStatus() {
        do {
            apiKeyStatus = APIKeyMasker.masked(try authProvider.apiKey())
        } catch {
            apiKeyStatus = "not configured"
            settingsError = error.localizedDescription
        }
    }
}
