import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(hex: 0x000000)
                .ignoresSafeArea()

            VStack(spacing: 48) {
                HeaderView()

                Spacer()

                VoiceOrbView()
                    .frame(width: 260, height: 260)

                Text("Which exercise?")
                    .font(.system(size: 44, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer()

                FooterView()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
}

private struct HeaderView: View {
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

            Button(action: {}) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
    }
}

private struct VoiceOrbView: View {
    @State private var isBreathing = false

    var body: some View {
        Circle()
            .fill(.white)
            .scaleEffect(isBreathing ? 1.04 : 0.98)
            .animation(
                .easeInOut(duration: 2.6).repeatForever(autoreverses: true),
                value: isBreathing
            )
            .onAppear {
                isBreathing = true
            }
    }
}

private struct FooterView: View {
    var body: some View {
        HStack {
            Spacer()

            Button("tap to talk", action: {})
                .buttonStyle(.plain)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)

            Spacer()

            Button(action: {}) {
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
