//
//  Notifications.swift
//  Jam
//
//  Created by Maula Izza Azizi on 06/09/26.
//

import Foundation
import UserNotifications

private final class ForegroundPresenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}

enum Notifications {

    private static var center: UNUserNotificationCenter { .current() }
    private static let presenter = ForegroundPresenter()

    @discardableResult
    static func requestIfNeeded() async -> Bool {
        center.delegate = presenter
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        default:
            return false
        }
    }

    // MARK: Timer

    static func scheduleCountdown(id: String, after seconds: TimeInterval, label: String) async {
        guard seconds > 0, await requestIfNeeded() else { return }

        let content = UNMutableNotificationContent()
        content.title = label.isEmpty ? "Timer selesai" : label
        content.body = "Waktunya habis."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        try? await center.add(
            UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        )
    }

    // MARK: Alarm

    static func scheduleAlarm(_ alarm: Alarm) async {
        cancel(prefix: alarm.id.uuidString)
        guard alarm.isEnabled, await requestIfNeeded() else { return }

        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "Alarm" : alarm.label
        content.body = TimeFormat.clock(hour: alarm.hour, minute: alarm.minute)
        content.sound = .default

        if alarm.weekdays.isEmpty {
            var components = DateComponents()
            components.hour = alarm.hour
            components.minute = alarm.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try? await center.add(
                UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)-once",
                    content: content,
                    trigger: trigger
                )
            )
            return
        }

        for weekday in alarm.weekdays.sorted() {
            var components = DateComponents()
            components.hour = alarm.hour
            components.minute = alarm.minute
            components.weekday = weekday

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            try? await center.add(
                UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)-\(weekday)",
                    content: content,
                    trigger: trigger
                )
            )
        }
    }

    // MARK: Batal

    static func cancel(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    static func cancel(prefix: String) {
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            guard !ids.isEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
