import SwiftUI
import SwiftData

@main
struct VerbaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 800)
        }
        .windowStyle(.hiddenTitleBar)
        .modelContainer(for: [
            TrainingSession.self,
            Transcript.self,
            Badge.self
        ])
    }
}
