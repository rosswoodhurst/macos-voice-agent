# Clarifications Needed Before Phase 0

Date: 2026-05-09

I will stop after writing this file and wait for answers before creating the first scaffold commit.

## Blocking Questions

1. Confirm the GitHub repo remote.
   - I detect `origin` as `https://github.com/rosswoodhurst/macos-voice-agent.git`.
   - Should I use this as the private repo and push the initial scaffold to `main` there?

2. Confirm the bundle identifier prefix.
   - Proposed bundle id: `com.rosswoodhurst.verba`.
   - Proposed Keychain service: `com.rosswoodhurst.verba.openai`.
   - If you prefer a different author/company prefix, provide it before I scaffold the Xcode project.

3. Confirm the app display name.
   - Recommendation: use `Verba`.
   - This keeps the app name short and neutral while the skill roadmap grows.

4. Confirm the Realtime transport for v1.
   - OpenAI's Realtime WebRTC guide recommends WebRTC over WebSockets for client/mobile-style connections because it gives more consistent performance.
   - Native macOS does not provide a built-in `RTCPeerConnection` API, so WebRTC means adding a native WebRTC dependency and handling packaging/signing risk.
   - Recommendation: build Phase 1 behind a `RealtimeTransport` protocol and use native WebSocket first via `URLSessionWebSocketTask` for v1, because it preserves the no-backend BYO-key model and keeps the scaffold shippable. If you want WebRTC in v1 despite the dependency cost, I will use WebRTC and document the dependency in `AGENTS.md`.

5. Confirm the skill packaging format.
   - Option A: one Swift Package per skill. This is cleaner once skills become independently versioned, but it adds package boundaries early.
   - Option B: internal folders/modules in the main app target, using the same `Skill` protocol. This is simpler for a one-skill v1 and still keeps the protocol boundary for later extraction.
   - Recommendation: choose Option B for v1, with `Skills/UCCommunicationTraining/` inside the app target. Revisit Option A when a second shipped skill is ready.

6. Add the canonical training docs before Phase 2 design starts.
   - Missing now: `docs/training/UC-AUTOMATION-COMMUNICATION-TRAINING.md`.
   - Missing now: `docs/training/UC-AUTOMATION-VOICE-AI-EXERCISES.md`.
   - I can scaffold Phase 0 before these exist, but I will not design or implement the training skill until I have read both in full.

## Notes From OpenAI Docs Check

- The WebRTC docs recommend WebRTC over WebSockets for client/mobile-style Realtime connections.
- The WebSocket and session update docs show `gpt-realtime-2`; the WebRTC examples also contain `gpt-realtime` in some snippets. Per the project brief, I will use `AppConfig.realtimeModel = "gpt-realtime-2"` exactly and record any model-string discrepancy in `AGENTS.md`.
- `session.update` is the right event for updating runtime instructions when the active skill changes.

Reference docs checked:

- https://developers.openai.com/api/docs/guides/realtime-webrtc
- https://developers.openai.com/api/docs/guides/realtime-websocket#connect-via-websocket
- https://developers.openai.com/api/docs/guides/realtime-conversations#session-lifecycle-events
