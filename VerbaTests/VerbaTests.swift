import Testing
@testable import Verba

struct VerbaTests {
    @Test func realtimeModelIsFixed() {
        #expect(AppConfig.realtimeModel == "gpt-realtime-2")
    }

    @Test func apiKeyMaskOnlyShowsLastFourCharacters() {
        #expect(APIKeyMasker.masked("sk-proj-1234567890") == "configured ...7890")
    }

    @Test func apiKeyMaskShowsUnconfiguredStateForMissingKey() {
        #expect(APIKeyMasker.masked(nil) == "not configured")
        #expect(APIKeyMasker.masked("") == "not configured")
    }

    @Test func instructionComposerAppendsActiveSkillPrompt() {
        let composer = RealtimeInstructionComposer(basePersona: "base")

        #expect(composer.compose(activeSkillPromptFragment: "skill") == "base\n\nskill")
        #expect(composer.compose(activeSkillPromptFragment: nil) == "base")
        #expect(composer.compose(activeSkillPromptFragment: "  ") == "base")
    }

    @Test func sessionUpdateUsesFixedRealtimeModel() throws {
        let configuration = RealtimeSessionConfiguration(instructions: "coach")
        let event = configuration.sessionUpdateEvent()

        #expect(event.type == "session.update")
        #expect(event.session?.model == "gpt-realtime-2")
        #expect(event.session?.instructions == "coach")
    }

    @Test func webSocketRealtimeURLUsesFixedModel() throws {
        let url = try WebSocketRealtimeTransport.realtimeURL(model: AppConfig.realtimeModel)

        #expect(url.absoluteString == "wss://api.openai.com/v1/realtime?model=gpt-realtime-2")
    }
}
