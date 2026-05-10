import Foundation

struct RealtimeSessionConfiguration: Equatable, Sendable {
    var instructions: String
    var voice: String
    var inputAudioRate: Int
    var outputAudioRate: Int
    var tools: [RealtimeToolDefinition]

    init(
        instructions: String,
        voice: String = "marin",
        inputAudioRate: Int = 24_000,
        outputAudioRate: Int = 24_000,
        tools: [RealtimeToolDefinition] = []
    ) {
        self.instructions = instructions
        self.voice = voice
        self.inputAudioRate = inputAudioRate
        self.outputAudioRate = outputAudioRate
        self.tools = tools
    }

    func sessionUpdateEvent() -> RealtimeClientEvent {
        RealtimeClientEvent(
            type: "session.update",
            session: .init(
                type: "realtime",
                model: AppConfig.realtimeModel,
                outputModalities: ["audio"],
                audio: .init(
                    input: .init(
                        format: .init(type: "audio/pcm", rate: inputAudioRate),
                        turnDetection: .init(type: "semantic_vad")
                    ),
                    output: .init(
                        format: .init(type: "audio/pcm", rate: outputAudioRate),
                        voice: voice
                    )
                ),
                instructions: instructions,
                tools: tools
            )
        )
    }
}

struct RealtimeClientEvent: Encodable, Equatable, Sendable {
    let type: String
    let session: RealtimeSessionPayload?
    let item: RealtimeConversationItemPayload?
    let response: RealtimeResponseCreatePayload?

    init(
        type: String,
        session: RealtimeSessionPayload? = nil,
        item: RealtimeConversationItemPayload? = nil,
        response: RealtimeResponseCreatePayload? = nil
    ) {
        self.type = type
        self.session = session
        self.item = item
        self.response = response
    }

    static func functionCallOutput(callID: String, output: String) -> RealtimeClientEvent {
        RealtimeClientEvent(
            type: "conversation.item.create",
            item: .init(
                type: "function_call_output",
                callID: callID,
                output: output
            )
        )
    }

    static func responseCreate() -> RealtimeClientEvent {
        RealtimeClientEvent(type: "response.create", response: .init())
    }
}

struct RealtimeSessionPayload: Encodable, Equatable, Sendable {
    let type: String
    let model: String
    let outputModalities: [String]
    let audio: RealtimeAudioConfiguration
    let instructions: String
    let tools: [RealtimeToolDefinition]

    enum CodingKeys: String, CodingKey {
        case type
        case model
        case outputModalities = "output_modalities"
        case audio
        case instructions
        case tools
    }
}

struct RealtimeConversationItemPayload: Encodable, Equatable, Sendable {
    let type: String
    let callID: String
    let output: String

    enum CodingKeys: String, CodingKey {
        case type
        case callID = "call_id"
        case output
    }
}

struct RealtimeResponseCreatePayload: Encodable, Equatable, Sendable {}

struct RealtimeAudioConfiguration: Encodable, Equatable, Sendable {
    let input: RealtimeInputAudioConfiguration
    let output: RealtimeOutputAudioConfiguration
}

struct RealtimeInputAudioConfiguration: Encodable, Equatable, Sendable {
    let format: RealtimeAudioFormat
    let turnDetection: RealtimeTurnDetection

    enum CodingKeys: String, CodingKey {
        case format
        case turnDetection = "turn_detection"
    }
}

struct RealtimeOutputAudioConfiguration: Encodable, Equatable, Sendable {
    let format: RealtimeAudioFormat
    let voice: String
}

struct RealtimeAudioFormat: Encodable, Equatable, Sendable {
    let type: String
    let rate: Int?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(rate, forKey: .rate)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case rate
    }
}

struct RealtimeTurnDetection: Encodable, Equatable, Sendable {
    let type: String
}
