# Karen Roadmap

## Architecture Decisions

- 2026-05-09: The macOS app display name is `Karen`; the bundle id remains `com.rosswoodhurst.verba`.
- 2026-05-09: `AppConfig.realtimeModel` is hardcoded to `gpt-realtime-2`; OpenAI WebRTC examples also mention `gpt-realtime`, but project scope fixes the canonical model string.
- 2026-05-09: Phase 1 uses a `RealtimeTransport` protocol with WebSocket first via `URLSessionWebSocketTask`; WebRTC remains the intended lower-latency target, but native macOS WebRTC adds dependency and signing risk while the v1 auth model has no backend for ephemeral tokens.
- 2026-05-09: WebSocket audio output supports both `response.output_audio.delta` and legacy `response.audio.delta` server events because current OpenAI Realtime docs and cookbook examples differ on the event name.
- 2026-05-09: Skill packaging uses Option B for v1: internal app folders conforming to a shared `Skill` protocol. Option A, one Swift Package per skill, is cleaner for independently versioned skills later, but is unnecessary overhead while v1 ships exactly one skill.
- 2026-05-09: XcodeGen owns the Xcode project definition so project settings remain reviewable and the generated `.xcodeproj` can be recreated deterministically.

## Phase Plan

### Phase 0: Scaffold

Create the native macOS app shell, generated Xcode project, roadmap, README, MIT license, ignore rules, app settings, and a local build/run script. The scaffold should open in Xcode and build before feature work starts.

### Phase 1: Realtime Spine

Add the direct OpenAI Realtime connection behind `RealtimeTransport`, using the fixed `gpt-realtime-2` model. Store the user-provided API key in Keychain via an `AuthProvider` abstraction. Compose base assistant instructions with the active skill prompt fragment and update sessions with `session.update` when context changes.

### Phase 2: Training Skill

Read `docs/training/UC-AUTOMATION-COMMUNICATION-TRAINING.md` and `docs/training/UC-AUTOMATION-VOICE-AI-EXERCISES.md` in full before implementation. Embed the 10 exercise prompt blocks verbatim in Swift constants, register exactly one v1 skill, expose the required Realtime tools, persist scores and transcripts with SwiftData, and unit-test scoring, registry, and pure transforms.

### Phase 3: Polish & Ship

Finish the one-screen black SwiftUI interface, amplitude-synced voice orb, Progress dashboard, badge rules, app icon, README screenshot, build verification, and final roadmap tick-off.

### Future Phase: Phone PSTN Skill via Twilio

Add outbound PSTN calling through Twilio Voice with a Media Streams bridge into the same Realtime session. This will require a small backend because Twilio webhooks and Realtime session credential minting do not fit the v1 direct BYO-key model.

### Future Phase: Mac Control Skill

Add local Mac actions through Apple Events, AppleScript, and `NSWorkspace` for opening apps, Spotlight-like file actions, and calendar quick-adds. This may require broad entitlements or an unsandboxed distribution path, so sandboxing and user consent need a dedicated design pass.

### Future Phase: Gmail Skill

Add inbox reading, reply drafting, and send actions through Google OAuth and Gmail APIs. The OAuth flow likely needs a backend or a secure local authorization strategy before it can ship.

### Future Phase: Calendar Skill

Add native calendar and reminder actions through EventKit, with Google Calendar API support when Gmail-side calendar data is needed. The skill should keep local EventKit permissions separate from remote Google OAuth.

### Future Phase: Health and Fitness Skill

Add HealthKit-driven workout and diet coaching after the iOS port lands. Health data should sync through shared SwiftData and iCloud, then be injected as constrained context for the Realtime model.

## Task List

- [x] Write pre-scaffold clarification checkpoint.
- [x] Create generated macOS Xcode project scaffold.
- [x] Add app shell with fixed model config and placeholder UI.
- [x] Add MIT license, README, `.gitignore`, and build/run script.
- [x] Verify Phase 0 build from a clean checkout.
- [x] Implement Keychain-backed API key storage.
- [x] Add `AuthProvider` abstraction.
- [x] Implement Realtime transport protocol.
- [x] Implement WebSocket Realtime transport.
- [x] Compose and update Realtime session instructions.
- [x] Add active skill tools to Realtime session configuration.
- [x] Route Realtime function calls to active skill tool handlers.
- [x] Stream microphone input to the Realtime input audio buffer.
- [x] Connect the primary UI action to Realtime session lifecycle.
- [x] Persist live transcript turns during Realtime sessions.
- [x] Add SwiftData model types for training sessions, transcripts, and badges.
- [x] Add SwiftData training store.
- [x] Add fixed-rubric scoring validation.
- [x] Read both canonical training docs in full.
- [x] Implement `Skill` protocol and `SkillRegistry`.
- [x] Register exactly one v1 skill: `UCCommunicationTrainingSkill`.
- [x] Embed all 10 exercise prompt blocks verbatim.
- [x] Implement required training Realtime tools.
- [x] Persist training sessions, transcripts, and badges with SwiftData.
- [x] Unit-test scoring engine.
- [x] Unit-test skill registry.
- [x] Unit-test pure-data transforms.
- [x] Build the voice orb states.
- [x] Sync speaking animation to output audio amplitude.
- [x] Wire Realtime model audio playback into the output amplitude meter.
- [x] Set the visible macOS window and bundle display name to Karen.
- [x] Build the Progress dashboard.
- [x] Implement badge awards.
- [x] Add app icon set.
- [x] Add README orb preview asset.
- [x] Document v1 verification status.
- [ ] Capture a literal README screenshot once macOS Screen Recording permission is available.
- [ ] Verify v1 definition of done.
