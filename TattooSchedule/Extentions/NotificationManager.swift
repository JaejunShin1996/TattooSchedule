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

    var id: String = ""

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

    func scheduleNotification(stringID: String, name: String, time: String, weekday: Int) {
        self.id = stringID
        let content = UNMutableNotificationContent()
        content.title = "\(Date.now.formatted(date: .abbreviated, time: .omitted))"
        content.subtitle = "\(name) at \(time)"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        dateComponents.weekday = weekday
        print(weekday)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: stringID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(notificationId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
    }

    func removeDelivered() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
