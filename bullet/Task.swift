import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var notes: String
    var createdAt: Date
    var lastRevivedAt: Date
    var lifespan: TimeInterval
    var killedAt: Date?

    init(title: String,
         notes: String = "",
         createdAt: Date = .now,
         lifespan: TimeInterval = 60 * 60 * 24 * 7) {
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.lastRevivedAt = createdAt
        self.lifespan = lifespan
        self.killedAt = nil
    }

    var expiryDate: Date {
        lastRevivedAt.addingTimeInterval(lifespan)
    }

    func isDead(referenceDate: Date = .now) -> Bool {
        guard killedAt == nil else { return true }
        return referenceDate >= expiryDate
    }

    func decayProgress(referenceDate: Date = .now) -> Double {
        let elapsed = referenceDate.timeIntervalSince(lastRevivedAt)
        guard lifespan > 0 else { return 1 }
        return min(max(elapsed / lifespan, 0), 1)
    }

    func extendLife(now: Date = .now) {
        guard !isDead(referenceDate: now) else { return }
        lifespan *= 2
        lastRevivedAt = now
        killedAt = nil
    }

    func kill(now: Date = .now) {
        killedAt = now
    }
}
