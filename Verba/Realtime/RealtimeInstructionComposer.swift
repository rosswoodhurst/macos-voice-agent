import Foundation

struct RealtimeInstructionComposer: Sendable {
    let basePersona: String

    init(basePersona: String = Self.defaultBasePersona) {
        self.basePersona = basePersona
    }

    func compose(activeSkillPromptFragment: String?) -> String {
        let trimmedSkillPrompt = activeSkillPromptFragment?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let trimmedSkillPrompt, !trimmedSkillPrompt.isEmpty else {
            return basePersona
        }

        return [basePersona, trimmedSkillPrompt].joined(separator: "\n\n")
    }

    static let defaultBasePersona = """
    You are Verba, a direct macOS voice assistant for Ross. Speak clearly, keep turns concise, and stay focused on the active skill.
    """
}
