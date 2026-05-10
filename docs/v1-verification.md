# v1 Verification Status

Date: 2026-05-10

## Verified

- `xcodebuild -project Verba.xcodeproj -scheme Verba -configuration Debug -derivedDataPath build/DerivedData -destination 'platform=macOS,arch=arm64' test -quiet`
- `./script/build_and_run.sh --verify`
- The built app bundle name and process name are `Karen`.
- The fixed Realtime model remains `gpt-realtime-2`.
- Unit coverage includes scoring, registry behavior, tool schemas, tool handlers, badge awards, audio amplitude, PCM conversion, Realtime tool-call routing, microphone streaming events, session lifecycle wiring, and transcript persistence.

## Not Yet Fully Verified

- Literal README screenshot capture is blocked until macOS Screen Recording permission is granted to the shell/Codex runner.
- Live Realtime end-to-end role-play requires a manual app run with a valid OpenAI API key, microphone permission, speaker output, and network access.
- WebRTC remains a documented future transport target; v1 currently uses the documented WebSocket fallback path.
