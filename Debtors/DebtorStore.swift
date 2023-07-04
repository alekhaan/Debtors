//
//  DebtorStore.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import Foundation
import UserNotifications

class DebtorStore: ObservableObject {
    
    @Published var debtors: [Debtor] = []
    
    private let key = "DebtorsKey"
    
    init() {
        loadDebtors()
    }
    
    func addDebt(_ debt: Debt, to debtor: Debtor) {
        if let index = debtors.firstIndex(where: { $0.id == debtor.id}) {
            debtors[index].debts.append(debt)
        }
        saveDebtors()
        scheduleNotifications()
    }
    
    func addDebtor(_ debtor: Debtor) {
        if var existingDebtor = debtors.first(where: { $0.name == debtor.name}) {
            existingDebtor.debts.append(contentsOf: debtor.debts)
        } else {
            debtors.append(debtor)
        }
        saveDebtors()
        scheduleNotifications()
    }
    
    func removeDebt(_ debt: Debt, from debtor: Debtor) {
        if let debtorIndex = debtors.firstIndex(where: { $0.id == debtor.id }),
           let debtIndex = debtors[debtorIndex].debts.firstIndex(where: { $0.id == debt.id }) {
            debtors[debtorIndex].debts.remove(at: debtIndex)
            saveDebtors()
        }
        scheduleNotifications()
    }
    
    func removeDebtor(_ debtor: Debtor) {
        if let index = debtors.firstIndex(where: {
            $0.id == debtor.id
        }) {
            debtors.remove(at: index)
            saveDebtors()
        }
        scheduleNotifications()
    }
    
    func deactivateDebt(_ debt: Debt, from debtor: Debtor) {
        if let debtorIndex = debtors.firstIndex(where: { $0.id == debtor.id }) {
            if let debtIndex = debtors[debtorIndex].debts.firstIndex(where: { $0.id == debt.id}) {
                debtors[debtorIndex].debts[debtIndex].isActive = false
                debtors[debtorIndex].debts[debtIndex].closeDate = Date()
                debtors[debtorIndex].debts[debtIndex].paidAmount = debtors[debtorIndex].debts[debtIndex].totalAmount
                saveDebtors()
            }
        }
        scheduleNotifications()
    }
    
    private func saveDebtors() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(debtors)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save debtors: \(error)")
        }
    }
    
    private func loadDebtors() {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let loadedDebtors = try decoder.decode([Debtor].self, from: data)
                debtors = loadedDebtors
            } catch {
                print("Failed to load debtors: \(error)")
            }
        }
    }
    
    private func scheduleNotification(for debt: Debt, debtorName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Пора проверить долг"
        content.body = "У должника \(debtorName) сегодня начисляется процент"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: debt.nextPaymentDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        let identifier = debt.id.uuidString

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for debtor in debtors {
            for debt in debtor.debts where debt.isActive {
                scheduleNotification(for: debt, debtorName: debtor.name)
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
}

