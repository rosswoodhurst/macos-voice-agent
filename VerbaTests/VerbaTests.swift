import Testing
@testable import Verba

struct VerbaTests {
    @Test func realtimeModelIsFixed() {
        #expect(AppConfig.realtimeModel == "gpt-realtime-2")
    }
}
