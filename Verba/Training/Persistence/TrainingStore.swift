import Foundation
import SwiftData

@MainActor
final class TrainingStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insertTranscript(_ transcript: Transcript) throws {
        modelContext.insert(transcript)
        try modelContext.save()
    }

    func insertSession(_ session: TrainingSession) throws {
        modelContext.insert(session)
        try modelContext.save()
    }

    func insertBadge(_ badge: Badge) throws {
        modelContext.insert(badge)
        try modelContext.save()
    }

    func recentSessions(limit: Int) throws -> [TrainingSession] {
        var descriptor = FetchDescriptor<TrainingSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
}
