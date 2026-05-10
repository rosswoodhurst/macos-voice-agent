import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack {
            Color(hex: 0x000000)
                .ignoresSafeArea()

            VStack(spacing: 48) {
                HeaderView(appState: appState)

                Spacer()

                VoiceOrbView(
                    phase: appState.voicePhase,
                    inputLevel: appState.inputLevel,
                    outputLevel: appState.outputLevel
                )
                    .frame(width: 260, height: 260)

                Text("Which exercise?")
                    .font(.system(size: 44, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer()

                FooterView(appState: appState)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $appState.isSettingsPresented) {
            SettingsView(appState: appState)
        }
        .sheet(isPresented: $appState.isProgressPresented) {
            ProgressDashboardView()
        }
        .onAppear {
            appState.configureTrainingStore(TrainingStore(modelContext: modelContext))
        }
    }
}

private struct HeaderView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        HStack {
            Text("uc communication training")
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(.white)

            Spacer()

            Button(action: {}) {
                Image(systemName: "mic")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)

            Button(action: {
                appState.isSettingsPresented = true
            }) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
    }
}

private struct VoiceOrbView: View {
    let phase: VoiceOrbPhase
    let inputLevel: Double
    let outputLevel: Double

    @State private var isBreathing = false
    @State private var ringRotation = 0.0

    var body: some View {
        ZStack {
            if phase == .thinking {
                Circle()
                    .trim(from: 0.08, to: 0.32)
                    .stroke(.white.opacity(0.82), lineWidth: 2)
                    .rotationEffect(.degrees(ringRotation))
                    .frame(width: 286, height: 286)
            }

            Circle()
                .fill(fillColor)
                .scaleEffect(scale)
        }
        .animation(.easeInOut(duration: 0.22), value: phase)
        .animation(.easeInOut(duration: 0.22), value: inputLevel)
        .animation(.easeInOut(duration: 0.12), value: outputLevel)
        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: isBreathing)
        .animation(.linear(duration: 2.8).repeatForever(autoreverses: false), value: ringRotation)
        .onAppear {
            isBreathing = true
            ringRotation = 360
        }
    }

    private var fillColor: Color {
        switch phase {
        case .listening:
            Color(red: 0.82, green: 0.92, blue: 1.0)
        default:
            .white
        }
    }

    private var scale: Double {
        switch phase {
        case .idle:
            isBreathing ? 1.04 : 0.98
        case .listening:
            1.0 + min(max(inputLevel, 0), 1) * 0.10
        case .thinking:
            1.0
        case .speaking:
            1.0 + min(max(outputLevel, 0), 1) * 0.16
        }
    }
}

private struct FooterView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                appState.handlePrimaryAction()
            }) {
                Text(appState.voicePhase.primaryActionTitle)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)

            Spacer()

            Button(action: {
                appState.isProgressPresented = true
            }) {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    ContentView()
}
