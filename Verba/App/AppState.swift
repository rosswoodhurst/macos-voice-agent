import Foundation
import AVFoundation

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
    private let amplitudeMeter = AudioAmplitudeMeter()
    private let audioOutputPlayer: RealtimeAudioOutputPlaying

    init(
        authProvider: AuthProvider = KeychainAuthProvider(),
        audioOutputPlayer: RealtimeAudioOutputPlaying = RealtimeAudioOutputPlayer()
    ) {
        self.authProvider = authProvider
        self.audioOutputPlayer = audioOutputPlayer
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

    func updateOutputLevel(from buffer: AVAudioPCMBuffer) {
        outputLevel = amplitudeMeter.normalizedRMSLevel(from: buffer)
        voicePhase = .speaking
    }

    func updateOutputLevel(fromPCM16 data: Data) {
        outputLevel = amplitudeMeter.normalizedRMSLevel(fromPCM16: data)
        voicePhase = .speaking
    }

    func handleRealtimeServerEvent(_ event: RealtimeServerEvent) throws {
        if let audioDelta = event.outputAudioDelta {
            try audioOutputPlayer.playPCM16(audioDelta)
            updateOutputLevel(fromPCM16: audioDelta)
            return
        }

        if event.isOutputAudioDone {
            audioOutputPlayer.stop()
            outputLevel = 0
            voicePhase = .idle
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
