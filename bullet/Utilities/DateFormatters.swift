//
//  DateFormatters.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import Foundation

enum DateFormatters {
    // MARK: - Relative Deadline Formatting

    /// Formats a deadline relative to now (e.g., "Dead in 2 hours" or "3 days ago")
    static func relativeDeadline(from deadline: Date) -> String {
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day, .weekOfYear]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2

        let raw = formatter.string(from: now, to: deadline) ?? ""

        // Remove leading "in "
        var text = raw
        if text.hasPrefix("in ") {
            text.removeFirst(3)
        }

        // Prefix for future deadlines
        if deadline > now {
            return "Dead in \(text)"
        } else {
            return text
        }
    }

    // MARK: - Lifespan Formatting

    /// Formats a time interval as a lifespan (e.g., "Lived for 2 days, 3 hours")
    static func formattedLifespan(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfYear, .day, .hour, .minute]
        formatter.maximumUnitCount = 2
        return "Lived for \(formatter.string(from: interval) ?? "")"
    }

    // MARK: - Age Formatting

    /// Formats the age of a task (time since creation)
    static func formattedAge(from start: Date, to end: Date = Date()) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfYear, .day, .hour, .minute]
        formatter.maximumUnitCount = 2
        return formatter.string(from: start, to: end) ?? ""
    }

    // MARK: - Standard Date Formatting

    /// Formats a date in medium style with time (e.g., "Dec 12, 2025 at 3:45 PM")
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
