//
//  NotificationManager.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 11/11/2022.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()

    func requestPermission() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { _, error in
            if let error = error {
                print("Notification error, \(error.localizedDescription)")
            } else {
                print("Notification permissioned")
            }
        }
    }

    func scheduleNotification(name: String, time: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(Date.now.formatted(date: .abbreviated, time: .omitted))"
        content.subtitle = "\(name) at \(time)"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 12
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
