import Foundation

@MainActor
enum DefaultSkillRegistry {
    static func make() throws -> SkillRegistry {
        let registry = SkillRegistry()
        try registry.register(UCCommunicationTrainingSkill())
        return registry
    }
}
