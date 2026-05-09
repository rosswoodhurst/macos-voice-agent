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
}

private struct RealtimeAudioDeltaEvent: Decodable {
    let delta: String
}
