import Foundation

@MainActor
protocol RealtimeSessionControlling: AnyObject {
    var isRunning: Bool { get }

    func start() async throws
    func stop() async
}

@MainActor
final class RealtimeSessionController: RealtimeSessionControlling {
    private let authProvider: AuthProvider
    private let transport: any RealtimeTransport
    private let activeSkill: any Skill
    private let instructionComposer: RealtimeInstructionComposer
    private let makeMicrophoneCapture: () throws -> any MicrophoneInputCapturing
    private let transcriptRecorder: RealtimeTranscriptRecorder
    private let onInputLevel: (Double) -> Void
    private let onServerEvent: (RealtimeServerEvent) throws -> Void
    private let onError: (Error) -> Void
    private var microphoneStreamer: RealtimeMicrophoneStreamer?
    private var eventTask: Task<Void, Never>?

    private(set) var isRunning = false

    init(
        authProvider: AuthProvider,
        transport: any RealtimeTransport = WebSocketRealtimeTransport(),
        activeSkill: any Skill,
        instructionComposer: RealtimeInstructionComposer = RealtimeInstructionComposer(),
        makeMicrophoneCapture: @escaping () throws -> any MicrophoneInputCapturing = {
            try MicrophoneInputCapture()
        },
        transcriptRecorder: RealtimeTranscriptRecorder = RealtimeTranscriptRecorder(),
        onInputLevel: @escaping (Double) -> Void,
        onServerEvent: @escaping (RealtimeServerEvent) throws -> Void,
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        self.authProvider = authProvider
        self.transport = transport
        self.activeSkill = activeSkill
        self.instructionComposer = instructionComposer
        self.makeMicrophoneCapture = makeMicrophoneCapture
        self.transcriptRecorder = transcriptRecorder
        self.onInputLevel = onInputLevel
        self.onServerEvent = onServerEvent
        self.onError = onError
    }

    func start() async throws {
        guard !isRunning else {
            return
        }

        guard let apiKey = try authProvider.apiKey(), !apiKey.isEmpty else {
            throw AuthProviderError.invalidAPIKey
        }

        try transcriptRecorder.start()
        let instructions = instructionComposer.compose(
            activeSkillPromptFragment: activeSkill.systemPromptFragment
        ) + "\n\nWhen you call record_session, set transcriptId to \"\(transcriptRecorder.transcriptID.uuidString)\"."
        let configuration = RealtimeSessionConfiguration(
            instructions: instructions,
            tools: activeSkill.tools
        )

        try await transport.connect(apiKey: apiKey, configuration: configuration)
        await activeSkill.onActivate(context: SkillLifecycleContext())

        let toolResponder = RealtimeToolCallResponder(
            handlers: activeSkill.makeToolHandlers(),
            transport: transport
        )
        let microphoneStreamer = RealtimeMicrophoneStreamer(
            capture: try makeMicrophoneCapture(),
            transport: transport,
            onInputLevel: onInputLevel,
            onError: onError
        )
        try microphoneStreamer.start()
        self.microphoneStreamer = microphoneStreamer
        isRunning = true

        eventTask = Task { [weak self] in
            await self?.receiveEvents(toolResponder: toolResponder)
        }
    }

    func stop() async {
        guard isRunning else {
            return
        }

        eventTask?.cancel()
        eventTask = nil
        microphoneStreamer?.stop()
        microphoneStreamer = nil
        await transport.disconnect()
        await activeSkill.onDeactivate(context: SkillLifecycleContext())
        isRunning = false
    }

    private func receiveEvents(toolResponder: RealtimeToolCallResponder) async {
        while !Task.isCancelled {
            do {
                let event = try await transport.nextEvent()
                if try await toolResponder.handle(event) {
                    continue
                }

                try transcriptRecorder.record(event)
                try onServerEvent(event)
            } catch {
                if !Task.isCancelled {
                    onError(error)
                }
                return
            }
        }
    }
}
