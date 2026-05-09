import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var apiKey = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("settings")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)

            SecureField("OpenAI API key", text: $apiKey)
                .textFieldStyle(.plain)
                .font(.caption)
                .foregroundStyle(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                )

            Text(appState.apiKeyStatus)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            if let settingsError = appState.settingsError {
                Text(settingsError)
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            HStack {
                Button("clear", action: appState.clearAPIKey)
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                Button("save", action: save)
                    .buttonStyle(.plain)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
        }
        .padding(28)
        .frame(width: 420)
        .background(Color(hex: 0x000000))
    }

    private func save() {
        appState.saveAPIKey(apiKey)
        apiKey = ""
    }
}
