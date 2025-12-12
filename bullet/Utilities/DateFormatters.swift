//
//  DateFormatters.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import Foundation

enum DateFormatters {
    // MARK: - Custom Time Formatting

    /// Formats a time interval with custom abbreviations (e.g., "2 hrs", "3 days")
    private static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let absInterval = abs(interval)

        let minutes = Int(absInterval / 60)
        let hours = Int(absInterval / 3600)
        let days = Int(absInterval / 86400)
        let weeks = Int(absInterval / 604800)
        let months = Int(absInterval / 2592000) // Approx 30 days

        if months > 0 {
            let remainder = (absInterval - Double(months * 2592000))
            let remainderWeeks = Int(remainder / 604800)
            if remainderWeeks > 0 {
                return "\(months) \(months == 1 ? "month" : "months"), \(remainderWeeks) \(remainderWeeks == 1 ? "week" : "weeks")"
            }
            return "\(months) \(months == 1 ? "month" : "months")"
        } else if weeks > 0 {
            let remainder = (absInterval - Double(weeks * 604800))
            let remainderDays = Int(remainder / 86400)
            if remainderDays > 0 {
                return "\(weeks) \(weeks == 1 ? "week" : "weeks"), \(remainderDays) \(remainderDays == 1 ? "day" : "days")"
            }
            return "\(weeks) \(weeks == 1 ? "week" : "weeks")"
        } else if days > 0 {
            let remainder = (absInterval - Double(days * 86400))
            let remainderHours = Int(remainder / 3600)
            if remainderHours > 0 {
                return "\(days) \(days == 1 ? "day" : "days"), \(remainderHours) \(remainderHours == 1 ? "hr" : "hrs")"
            }
            return "\(days) \(days == 1 ? "day" : "days")"
        } else if hours > 0 {
            let remainder = (absInterval - Double(hours * 3600))
            let remainderMins = Int(remainder / 60)
            if remainderMins > 0 {
                return "\(hours) \(hours == 1 ? "hr" : "hrs"), \(remainderMins) \(remainderMins == 1 ? "min" : "mins")"
            }
            return "\(hours) \(hours == 1 ? "hr" : "hrs")"
        } else {
            // Less than an hour
            return "soon"
        }
    }

    // MARK: - Relative Deadline Formatting

    /// Formats a deadline relative to now (e.g., "Dead in 2 hrs" or "3 days")
    static func relativeDeadline(from deadline: Date) -> String {
        let now = Date()
        let interval = deadline.timeIntervalSince(now)
        let text = formatTimeInterval(interval)

        // Prefix for future deadlines
        if deadline > now {
            // Special case for "soon"
            if text == "soon" {
                return "Dead soon"
            }
            return "Dead in \(text)"
        } else {
            return text
        }
    }

    // MARK: - Lifespan Formatting

    /// Formats a time interval as a lifespan (e.g., "Lived for 2 days, 3 hrs")
    static func formattedLifespan(_ interval: TimeInterval) -> String {
        return "Lived for \(formatTimeInterval(interval))"
    }

    // MARK: - Lifetime Formatting

    /// Formats a lifetime interval (e.g., "2 days, 3 hrs")
    static func formattedLifetime(_ interval: TimeInterval) -> String {
        let absInterval = abs(interval)

        let minutes = Int(absInterval / 60)
        let hours = Int(absInterval / 3600)
        let days = Int(absInterval / 86400)
        let weeks = Int(absInterval / 604800)
        let months = Int(absInterval / 2592000)

        if months > 0 {
            let remainder = (absInterval - Double(months * 2592000))
            let remainderWeeks = Int(remainder / 604800)
            if remainderWeeks > 0 {
                return "\(months) \(months == 1 ? "month" : "months"), \(remainderWeeks) \(remainderWeeks == 1 ? "week" : "weeks")"
            }
            return "\(months) \(months == 1 ? "month" : "months")"
        } else if weeks > 0 {
            let remainder = (absInterval - Double(weeks * 604800))
            let remainderDays = Int(remainder / 86400)
            if remainderDays > 0 {
                return "\(weeks) \(weeks == 1 ? "week" : "weeks"), \(remainderDays) \(remainderDays == 1 ? "day" : "days")"
            }
            return "\(weeks) \(weeks == 1 ? "week" : "weeks")"
        } else if days > 0 {
            let remainder = (absInterval - Double(days * 86400))
            let remainderHours = Int(remainder / 3600)
            if remainderHours > 0 {
                return "\(days) \(days == 1 ? "day" : "days"), \(remainderHours) \(remainderHours == 1 ? "hr" : "hrs")"
            }
            return "\(days) \(days == 1 ? "day" : "days")"
        } else if hours > 0 {
            let remainder = (absInterval - Double(hours * 3600))
            let remainderMins = Int(remainder / 60)
            if remainderMins > 0 {
                return "\(hours) \(hours == 1 ? "hr" : "hrs"), \(remainderMins) \(remainderMins == 1 ? "min" : "mins")"
            }
            return "\(hours) \(hours == 1 ? "hr" : "hrs")"
        } else {
            // Less than an hour - show minutes
            if minutes > 0 {
                return "\(minutes) \(minutes == 1 ? "min" : "mins")"
            } else {
                return "less than a min"
            }
        }
    }

    // MARK: - Age Formatting

    /// Formats the age of a task (time since creation)
    static func formattedAge(from start: Date, to end: Date = Date()) -> String {
        let interval = end.timeIntervalSince(start)
        let absInterval = abs(interval)

        let minutes = Int(absInterval / 60)
        let hours = Int(absInterval / 3600)
        let days = Int(absInterval / 86400)
        let weeks = Int(absInterval / 604800)
        let months = Int(absInterval / 2592000)

        if months > 0 {
            let remainder = (absInterval - Double(months * 2592000))
            let remainderWeeks = Int(remainder / 604800)
            if remainderWeeks > 0 {
                return "\(months) \(months == 1 ? "month" : "months"), \(remainderWeeks) \(remainderWeeks == 1 ? "week" : "weeks")"
            }
            return "\(months) \(months == 1 ? "month" : "months")"
        } else if weeks > 0 {
            let remainder = (absInterval - Double(weeks * 604800))
            let remainderDays = Int(remainder / 86400)
            if remainderDays > 0 {
                return "\(weeks) \(weeks == 1 ? "week" : "weeks"), \(remainderDays) \(remainderDays == 1 ? "day" : "days")"
            }
            return "\(weeks) \(weeks == 1 ? "week" : "weeks")"
        } else if days > 0 {
            let remainder = (absInterval - Double(days * 86400))
            let remainderHours = Int(remainder / 3600)
            if remainderHours > 0 {
                return "\(days) \(days == 1 ? "day" : "days"), \(remainderHours) \(remainderHours == 1 ? "hr" : "hrs")"
            }
            return "\(days) \(days == 1 ? "day" : "days")"
        } else if hours > 0 {
            let remainder = (absInterval - Double(hours * 3600))
            let remainderMins = Int(remainder / 60)
            if remainderMins > 0 {
                return "\(hours) \(hours == 1 ? "hr" : "hrs"), \(remainderMins) \(remainderMins == 1 ? "min" : "mins")"
            }
            return "\(hours) \(hours == 1 ? "hr" : "hrs")"
        } else {
            // Less than an hour - show minutes
            if minutes > 0 {
                return "\(minutes) \(minutes == 1 ? "min" : "mins")"
            } else {
                return "less than a min"
            }
        }
    }

    // MARK: - Relative Time

    /// Formats relative time from a date (e.g., "2 Hrs", "3 Days")
    static func relativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        return formatTimeInterval(interval)
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
