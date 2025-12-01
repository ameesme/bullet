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
    var isPersistent: Bool

    init(title: String,
         notes: String = "",
         createdAt: Date = .now,
         lifespan: TimeInterval = 60 * 60 * 24 * 7,
         isPersistent: Bool = false) {
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.lastRevivedAt = createdAt
        self.lifespan = lifespan
        self.isPersistent = isPersistent
        self.killedAt = nil
    }

    var expiryDate: Date {
        lastRevivedAt.addingTimeInterval(lifespan)
    }

    func isDead(referenceDate: Date = .now) -> Bool {
        guard killedAt == nil else { return !isPersistent }
        guard !isPersistent else { return false }
        return referenceDate >= expiryDate
    }

    func decayProgress(referenceDate: Date = .now) -> Double {
        guard !isPersistent else { return 0 }
        let elapsed = referenceDate.timeIntervalSince(lastRevivedAt)
        guard lifespan > 0 else { return 1 }
        return min(max(elapsed / lifespan, 0), 1)
    }

    func revive(now: Date = .now) {
        guard !isPersistent else { return }
        lifespan *= 2
        lastRevivedAt = now
        killedAt = nil
    }

    func kill(now: Date = .now) {
        guard !isPersistent else { return }
        killedAt = now
    }
}
