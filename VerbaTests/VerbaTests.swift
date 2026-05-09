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
}
