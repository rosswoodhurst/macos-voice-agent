import SwiftUI

@main
struct VerbaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 800)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
