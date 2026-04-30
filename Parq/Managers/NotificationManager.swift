import Foundation
import UserNotifications

final class NotificationManager {
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            }

            print("Notification permission granted:", granted)
        }
    }

    func scheduleParkingNotifications(
        expiresAt: Date,
        walkingTime: TimeInterval? = nil,
        leaveByTime: Date? = nil
    ) {
        cancelParkingNotifications()

        let fifteenMinuteWarningDate = expiresAt.addingTimeInterval(-15 * 60)

        if let walkingTime, let leaveByTime {
            let notificationDate = leaveByTime <= .now ? Date().addingTimeInterval(1) : leaveByTime
            let walkingMinutes = max(1, Int(ceil(walkingTime / 60)))

            if fifteenMinuteWarningDate > .now, fifteenMinuteWarningDate < notificationDate {
                scheduleNotification(
                    id: "parking_15_min_warning",
                    title: "Parking expires soon",
                    body: "You have 15 minutes left on your parking timer.",
                    fireDate: fifteenMinuteWarningDate
                )
            }

            scheduleNotification(
                id: "parking_leave_now",
                title: "Leave now",
                body: "You are about \(walkingMinutes) min away from your car. Leave now to avoid your parking expiring.",
                fireDate: notificationDate
            )
        } else {
            scheduleNotification(
                id: "parking_15_min_warning",
                title: "Parking expires soon",
                body: "You have 15 minutes left on your parking timer.",
                fireDate: fifteenMinuteWarningDate
            )

            scheduleNotification(
                id: "parking_5_min_warning",
                title: "Parking expires soon",
                body: "You have 5 minutes left on your parking timer.",
                fireDate: expiresAt.addingTimeInterval(-5 * 60)
            )
        }

        scheduleNotification(
            id: "parking_expired",
            title: "Parking expired",
            body: "Your parking timer has expired.",
            fireDate: expiresAt
        )
    }

    func cancelParkingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "parking_leave_now",
            "parking_15_min_warning",
            "parking_5_min_warning",
            "parking_expired"
        ])
    }

    private func scheduleNotification(id: String, title: String, body: String, fireDate: Date) {
        let seconds = fireDate.timeIntervalSinceNow

        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error:", error.localizedDescription)
            }
        }
    }
}
