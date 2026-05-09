import Foundation

actor WebSocketRealtimeTransport: RealtimeTransport {
    private let session: URLSession
    private let encoder: JSONEncoder
    private var task: URLSessionWebSocketTask?

    init(session: URLSession = .shared, encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.encoder = encoder
    }

    func connect(apiKey: String, configuration: RealtimeSessionConfiguration) async throws {
        let url = try Self.realtimeURL(model: AppConfig.realtimeModel)
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = session.webSocketTask(with: request)
        self.task = task
        task.resume()

        try await send(configuration.sessionUpdateEvent())
    }

    func send(_ event: RealtimeClientEvent) async throws {
        guard let task else {
            throw RealtimeTransportError.disconnected
        }

        let data = try encoder.encode(event)
        guard let json = String(data: data, encoding: .utf8) else {
            throw RealtimeTransportError.unsupportedMessage
        }

        try await task.send(.string(json))
    }

    func nextEvent() async throws -> RealtimeServerEvent {
        guard let task else {
            throw RealtimeTransportError.disconnected
        }

        let message = try await task.receive()

        switch message {
        case .string(let json):
            return try RealtimeServerEvent(jsonString: json)
        case .data(let data):
            guard let json = String(data: data, encoding: .utf8) else {
                throw RealtimeTransportError.unsupportedMessage
            }
            return try RealtimeServerEvent(jsonString: json)
        @unknown default:
            throw RealtimeTransportError.unsupportedMessage
        }
    }

    func disconnect() async {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    static func realtimeURL(model: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "wss"
        components.host = "api.openai.com"
        components.path = "/v1/realtime"
        components.queryItems = [
            URLQueryItem(name: "model", value: model)
        ]

        guard let url = components.url else {
            throw RealtimeTransportError.invalidURL
        }

        return url
    }
}
