import Foundation
import SwiftUI

@MainActor
protocol Skill {
    var id: String { get }
    var displayName: String { get }
    var systemPromptFragment: String { get }
    var tools: [RealtimeToolDefinition] { get }

    func makeToolHandlers() -> [String: SkillToolHandler]
    func makeUISurface() -> AnyView?
    func onActivate(context: SkillLifecycleContext) async
    func onDeactivate(context: SkillLifecycleContext) async
}

extension Skill {
    func makeUISurface() -> AnyView? {
        nil
    }

    func onActivate(context: SkillLifecycleContext) async {}
    func onDeactivate(context: SkillLifecycleContext) async {}
}

struct SkillLifecycleContext: Sendable {
    let activatedAt: Date

    init(activatedAt: Date = Date()) {
        self.activatedAt = activatedAt
    }
}

typealias SkillToolHandler = @Sendable (SkillToolInvocation) async throws -> SkillToolResult

struct SkillToolInvocation: Equatable, Sendable {
    let name: String
    let argumentsJSON: String
}

struct SkillToolResult: Equatable, Sendable {
    let json: String

    init(json: String = "{}") {
        self.json = json
    }
}
