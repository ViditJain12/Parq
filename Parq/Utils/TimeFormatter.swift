import Foundation

enum TimeFormatter {
    static func timeRemainingString(from interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(ceil(interval)))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m left"
        } else if totalSeconds >= 60 {
            return "\(minutes)m left"
        } else {
            return "\(seconds)s left"
        }
    }

    static func walkingTimeString(from interval: TimeInterval) -> String {
        let totalMinutes = max(1, Int(ceil(interval / 60)))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0, minutes > 0 {
            return "\(hours) hr \(minutes) min walk back"
        } else if hours > 0 {
            return "\(hours) hr walk back"
        } else {
            return "\(totalMinutes) min walk back"
        }
    }

    static func shortDurationString(from interval: TimeInterval) -> String {
        let totalMinutes = max(1, Int(round(interval / 60)))
        return "\(totalMinutes) min buffer"
    }

    static func clockTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
