import Foundation

@MainActor
final class SkillRegistry {
    private var skillsByID: [String: any Skill] = [:]
    private var orderedIDs: [String] = []

    var allSkills: [any Skill] {
        orderedIDs.compactMap { skillsByID[$0] }
    }

    func register(_ skill: any Skill) throws {
        guard skillsByID[skill.id] == nil else {
            throw SkillRegistryError.duplicateSkillID(skill.id)
        }

        skillsByID[skill.id] = skill
        orderedIDs.append(skill.id)
    }

    func skill(id: String) -> (any Skill)? {
        skillsByID[id]
    }

    func requireSkill(id: String) throws -> any Skill {
        guard let skill = skillsByID[id] else {
            throw SkillRegistryError.unknownSkillID(id)
        }

        return skill
    }
}

enum SkillRegistryError: Error, Equatable {
    case duplicateSkillID(String)
    case unknownSkillID(String)
}
