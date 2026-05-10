import Foundation

protocol RealtimeTransport: Sendable {
    func connect(apiKey: String, configuration: RealtimeSessionConfiguration) async throws
    func send(_ event: RealtimeClientEvent) async throws
    func nextEvent() async throws -> RealtimeServerEvent
    func disconnect() async
}

enum RealtimeTransportError: Error, Equatable {
    case disconnected
    case invalidURL
    case unsupportedMessage
    case missingEventType
}

struct RealtimeServerEvent: Equatable, Sendable {
    let type: String
    let rawJSON: String

    init(type: String, rawJSON: String) {
        self.type = type
        self.rawJSON = rawJSON
    }

    init(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8),
              let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = object["type"] as? String
        else {
            throw RealtimeTransportError.missingEventType
        }

        self.type = type
        self.rawJSON = jsonString
    }

    var outputAudioDelta: Data? {
        guard type == "response.output_audio.delta" || type == "response.audio.delta",
              let data = rawJSON.data(using: .utf8),
              let event = try? JSONDecoder().decode(RealtimeAudioDeltaEvent.self, from: data)
        else {
            return nil
        }

        return Data(base64Encoded: event.delta)
    }

    var isOutputAudioDone: Bool {
        type == "response.output_audio.done" || type == "response.audio.done" || type == "response.done"
    }

    var functionToolCall: RealtimeFunctionToolCall? {
        guard type == "response.function_call_arguments.done",
              let data = rawJSON.data(using: .utf8),
              let event = try? JSONDecoder().decode(RealtimeFunctionToolCallDoneEvent.self, from: data),
              let callID = event.resolvedCallID,
              let name = event.resolvedName,
              let argumentsJSON = event.resolvedArguments
        else {
            return nil
        }

        return RealtimeFunctionToolCall(
            callID: callID,
            name: name,
            argumentsJSON: argumentsJSON
        )
    }
}

private struct RealtimeAudioDeltaEvent: Decodable {
    let delta: String
}

struct RealtimeFunctionToolCall: Equatable, Sendable {
    let callID: String
    let name: String
    let argumentsJSON: String
}

private struct RealtimeFunctionToolCallDoneEvent: Decodable {
    let callID: String?
    let name: String?
    let arguments: String?
    let item: RealtimeFunctionToolCallItem?

    var resolvedCallID: String? {
        callID ?? item?.callID ?? item?.id
    }

    var resolvedName: String? {
        name ?? item?.name
    }

    var resolvedArguments: String? {
        arguments ?? item?.arguments
    }

    enum CodingKeys: String, CodingKey {
        case callID = "call_id"
        case name
        case arguments
        case item
    }
}

private struct RealtimeFunctionToolCallItem: Decodable {
    let id: String?
    let callID: String?
    let name: String?
    let arguments: String?

    enum CodingKeys: String, CodingKey {
        case id
        case callID = "call_id"
        case name
        case arguments
    }
}
