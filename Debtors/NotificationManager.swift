//
//  NotificationManager.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import Foundation
import UserNotifications

class NotificationManager {
    func scheduleNotification(for debt: Debt, debtorName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Повышение долга у \(debtorName)"
        content.body = "У \(debtorName) завтра повысится долг на \(debt.percent)%"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let nextPaymentDate = debt.nextPaymentDate
        let notificationDate = calendar.date(byAdding: .day, value: -1, to: nextPaymentDate)!
           
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
           
        let request = UNNotificationRequest(identifier: "DebtIncreaseNotification", content: content, trigger: trigger)
           
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Не удалось добавить уведомление: \(error.localizedDescription)")
            }
        }
    }
}
