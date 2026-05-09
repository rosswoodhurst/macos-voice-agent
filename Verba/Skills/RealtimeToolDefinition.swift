import Foundation

struct RealtimeToolDefinition: Codable, Equatable, Sendable {
    let type: String
    let name: String
    let description: String
    let parameters: JSONSchema

    init(
        name: String,
        description: String,
        parameters: JSONSchema
    ) {
        self.type = "function"
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

indirect enum JSONSchema: Codable, Equatable, Sendable {
    case object(properties: [String: JSONSchema], required: [String])
    case string(enumValues: [String]? = nil)
    case number
    case integer
    case boolean
    case array(items: JSONSchema)

    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case required
        case enumValues = "enum"
        case items
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .object(let properties, let required):
            try container.encode("object", forKey: .type)
            try container.encode(properties, forKey: .properties)
            try container.encode(required, forKey: .required)
        case .string(let enumValues):
            try container.encode("string", forKey: .type)
            try container.encodeIfPresent(enumValues, forKey: .enumValues)
        case .number:
            try container.encode("number", forKey: .type)
        case .integer:
            try container.encode("integer", forKey: .type)
        case .boolean:
            try container.encode("boolean", forKey: .type)
        case .array(let items):
            try container.encode("array", forKey: .type)
            try container.encode(items, forKey: .items)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "object":
            self = .object(
                properties: try container.decode([String: JSONSchema].self, forKey: .properties),
                required: try container.decodeIfPresent([String].self, forKey: .required) ?? []
            )
        case "string":
            self = .string(enumValues: try container.decodeIfPresent([String].self, forKey: .enumValues))
        case "number":
            self = .number
        case "integer":
            self = .integer
        case "boolean":
            self = .boolean
        case "array":
            self = .array(items: try container.decode(JSONSchema.self, forKey: .items))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported JSON schema type: \(type)"
            )
        }
    }
}
