//
//  Item.swift
//  bullet
//
//  Created by Mees on 01/12/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class CategoryItem {
    @Attribute(.unique) var name: String

    var colorName: String?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.category)
    var tasks: [TaskItem] = []

    static let accentPalette: [String] = [
        "blue", "green", "orange", "pink", "purple", "red",
        "teal", "yellow", "indigo", "mint", "cyan", "brown", "gray"
    ]

    init(name: String, colorName: String? = nil) {
        self.name = name
        if let colorName {
            self.colorName = colorName
        } else {
            self.colorName = Self.accentPalette.randomElement()
        }
    }

    // Convenience accessor for SwiftUI
    var color: Color {
        guard let colorName else { return .accentColor }
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        case "teal": return .teal
        case "yellow": return .yellow
        case "indigo": return .indigo
        case "mint": return .mint
        case "cyan": return .cyan
        case "brown": return .brown
        case "gray": return .gray
        default: return .accentColor
        }
    }
}

@Model
final class TaskItem {
    var title: String
    var creationDate: Date
    var deadlineDate: Date

    // Marks a task as "dead" manually (soft delete)
    var isCompleted: Bool = false

    @Relationship(deleteRule: .nullify)
    var category: CategoryItem?

    // Plain text notes
    var notes: String = ""

    init(
        title: String,
        creationDate: Date = .now,
        deadlineDate: Date? = nil,
        category: CategoryItem? = nil,
        isCompleted: Bool = false,
        notes: String = ""
    ) {
        self.title = title
        self.creationDate = creationDate

        // If no deadline provided, default to 48 hours from creationDate
        if let deadlineDate {
            self.deadlineDate = deadlineDate
        } else {
            self.deadlineDate = Calendar.current.date(byAdding: .hour, value: 24, to: creationDate) ?? creationDate.addingTimeInterval(48 * 3600)
        }

        self.category = category
        self.isCompleted = isCompleted
        self.notes = notes
    }

    var lifespan: TimeInterval {
        max(0, deadlineDate.timeIntervalSince(creationDate))
    }

    // Dead when completed OR past deadline.
    var isAlive: Bool {
        !isCompleted && Date() < deadlineDate
    }

    // Mark as manually dead (soft delete). Do not touch deadline.
    func markDead() {
        isCompleted = true
    }

    // Unmark completion (if any) and extend deadline by twice the current length (compounding).
    // Order matters: update deadline first, then clear completion so the item
    // exits the "dead" list immediately in a single predicate flip.
    func revive() {
        let newDeadline = creationDate.addingTimeInterval(lifespan * 2)
        deadlineDate = newDeadline
        isCompleted = false
    }
}
