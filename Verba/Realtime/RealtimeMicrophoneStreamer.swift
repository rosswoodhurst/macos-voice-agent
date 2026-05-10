import Foundation

@MainActor
final class RealtimeMicrophoneStreamer {
    private let capture: any MicrophoneInputCapturing
    private let transport: any RealtimeTransport
    private let onInputLevel: (Double) -> Void
    private let onError: (Error) -> Void

    init(
        capture: any MicrophoneInputCapturing,
        transport: any RealtimeTransport,
        onInputLevel: @escaping (Double) -> Void,
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        self.capture = capture
        self.transport = transport
        self.onInputLevel = onInputLevel
        self.onError = onError
    }

    func start() throws {
        try capture.start { [weak self] data, level in
            Task { @MainActor in
                guard let self else {
                    return
                }

                do {
                    try await self.handleCapturedAudio(data: data, level: level)
                } catch {
                    self.onError(error)
                }
            }
        }
    }

    func stop() {
        capture.stop()
        onInputLevel(0)
    }

    func handleCapturedAudio(data: Data, level: Double) async throws {
        onInputLevel(level)
        try await transport.send(.inputAudioBufferAppend(audio: data))
    }
}
