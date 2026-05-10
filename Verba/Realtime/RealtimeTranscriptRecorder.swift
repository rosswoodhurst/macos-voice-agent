import Foundation

@MainActor
final class RealtimeTranscriptRecorder {
    private let trainingStore: TrainingStore?
    private let transcript: Transcript
    private var didInsertTranscript = false

    var transcriptID: UUID {
        transcript.id
    }

    init(trainingStore: TrainingStore? = nil, transcript: Transcript = Transcript()) {
        self.trainingStore = trainingStore
        self.transcript = transcript
    }

    func start() throws {
        guard !didInsertTranscript else {
            return
        }

        if let trainingStore {
            try trainingStore.insertTranscript(transcript)
        }
        didInsertTranscript = true
    }

    func record(_ event: RealtimeServerEvent, timestamp: TimeInterval = Date().timeIntervalSince1970) throws {
        guard let line = event.transcriptLine(timestamp: timestamp) else {
            return
        }

        transcript.lines.append(line)
        try trainingStore?.save()
    }

    func lines() -> [TranscriptLine] {
        transcript.lines
    }
}
