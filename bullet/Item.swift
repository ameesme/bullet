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

    @Relationship(deleteRule: .nullify)
    var category: CategoryItem?

    init(
        title: String,
        creationDate: Date = .now,
        deadlineDate: Date? = nil,
        category: CategoryItem? = nil
    ) {
        self.title = title
        self.creationDate = creationDate

        // If no deadline provided, default to 48 hours from creationDate
        if let deadlineDate {
            self.deadlineDate = deadlineDate
        } else {
            self.deadlineDate = Calendar.current.date(byAdding: .hour, value: 48, to: creationDate) ?? creationDate.addingTimeInterval(48 * 3600)
        }

        self.category = category
    }

    var lifespan: TimeInterval {
        max(0, deadlineDate.timeIntervalSince(creationDate))
    }

    var isAlive: Bool {
        Date() < deadlineDate
    }

    func revive() {
        let newLifespan = max(0, lifespan) * 2
        deadlineDate = creationDate.addingTimeInterval(newLifespan)
    }
}
