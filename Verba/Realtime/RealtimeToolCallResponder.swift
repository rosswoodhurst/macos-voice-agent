import Foundation

@MainActor
final class RealtimeToolCallResponder {
    private let handlers: [String: SkillToolHandler]
    private let transport: any RealtimeTransport

    init(handlers: [String: SkillToolHandler], transport: any RealtimeTransport) {
        self.handlers = handlers
        self.transport = transport
    }

    func handle(_ event: RealtimeServerEvent) async throws -> Bool {
        guard let toolCall = event.functionToolCall else {
            return false
        }

        let output: String
        if let handler = handlers[toolCall.name] {
            let result = try await handler(
                SkillToolInvocation(
                    name: toolCall.name,
                    argumentsJSON: toolCall.argumentsJSON
                )
            )
            output = result.json
        } else {
            output = #"{"error":"unknown_tool"}"#
        }

        try await transport.send(
            .functionCallOutput(
                callID: toolCall.callID,
                output: output
            )
        )
        try await transport.send(.responseCreate())
        return true
    }
}
