import Foundation
import SwiftUI
import SwiftData

@main
struct VerbaApp: App {
    var body: some Scene {
        WindowGroup(AppConfig.appDisplayName) {
            if ProcessInfo.processInfo.isRunningXCTest {
                Color.clear
                    .frame(minWidth: 720, minHeight: 800)
            } else {
                ContentView()
                    .frame(minWidth: 720, minHeight: 800)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .modelContainer(for: [
            TrainingSession.self,
            Transcript.self,
            Badge.self
        ])
    }
}

private extension ProcessInfo {
    var isRunningXCTest: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}
