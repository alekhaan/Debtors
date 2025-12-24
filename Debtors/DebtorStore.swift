//
//  DebtorStore.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import Foundation
import UserNotifications

final class DebtorStore: ObservableObject {

    @Published var debtors: [Debtor] = []

    // Старый ключ для миграции
    private let legacyKey = "DebtorsKey"

    // Новое файловое хранилище
    private let fileName = "debtors.json"

    init() {
        loadDebtors()
    }

    // MARK: - CRUD

    func addDebt(_ debt: Debt, to debtor: Debtor) {
        if let index = debtors.firstIndex(where: { $0.id == debtor.id }) {
            debtors[index].debts.append(debt)
            persist()
            scheduleNotifications()
        }
    }

    func addDebtor(_ debtor: Debtor) {
        // ВАЖНО: фикс бага (struct copy). Ищем индекс и меняем массив напрямую.
        if let index = debtors.firstIndex(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
            .localizedCaseInsensitiveCompare(debtor.name.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame }) {

            debtors[index].debts.append(contentsOf: debtor.debts)
        } else {
            debtors.append(debtor)
        }

        persist()
        scheduleNotifications()
    }

    func removeDebt(_ debt: Debt, from debtor: Debtor) {
        if let debtorIndex = debtors.firstIndex(where: { $0.id == debtor.id }),
           let debtIndex = debtors[debtorIndex].debts.firstIndex(where: { $0.id == debt.id }) {
            debtors[debtorIndex].debts.remove(at: debtIndex)
            persist()
        }
        scheduleNotifications()
        Analytics.shared.event("debt_removed")
    }

    func removeDebtor(_ debtor: Debtor) {
        if let index = debtors.firstIndex(where: { $0.id == debtor.id }) {
            debtors.remove(at: index)
            persist()
        }
        scheduleNotifications()
        Analytics.shared.event("debtor_removed")
    }

    func deactivateDebt(_ debt: Debt, from debtor: Debtor) {
        if let debtorIndex = debtors.firstIndex(where: { $0.id == debtor.id }),
           let debtIndex = debtors[debtorIndex].debts.firstIndex(where: { $0.id == debt.id }) {

            debtors[debtorIndex].debts[debtIndex].isActive = false
            debtors[debtorIndex].debts[debtIndex].closeDate = Date()
            debtors[debtorIndex].debts[debtIndex].paidAmount = debtors[debtorIndex].debts[debtIndex].totalAmount

            persist()
            scheduleNotifications()

            Analytics.shared.event("debt_closed")
        }
    }

    // MARK: - Notifications

    private func scheduleNotification(for debt: Debt, debtorName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Пора проверить долг"
        content.body = "У должника \(debtorName) сегодня начисляется процент"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day],
                                                         from: debt.nextPaymentDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let identifier = debt.id.uuidString

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Analytics.shared.error("notification_schedule_failed", error.localizedDescription)
            }
        }
    }

    func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for debtor in debtors {
            for debt in debtor.debts where debt.isActive {
                scheduleNotification(for: debt, debtorName: debtor.name)
            }
        }
        Analytics.shared.event("notifications_scheduled")
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Analytics.shared.error("notification_permission_error", error.localizedDescription)
            } else {
                Analytics.shared.event("notification_permission_result", ["granted": "\(granted)"])
            }
        }
    }

    // MARK: - Persistence

    private func persist() {
        do {
            let data = try JSONEncoder().encode(debtors)
            try writeProtectedFile(data)
            Analytics.shared.event("persist_ok")
        } catch {
            Analytics.shared.error("persist_failed", "\(error)")
        }
    }

    private func loadDebtors() {
        // 1) Пытаемся загрузить из нового файла
        if let data = try? readProtectedFile(),
           let loaded = try? JSONDecoder().decode([Debtor].self, from: data) {
            debtors = loaded
            Analytics.shared.event("load_ok_file")
            return
        }

        // 2) Миграция со старого UserDefaults (если есть)
        if let data = UserDefaults.standard.data(forKey: legacyKey),
           let loaded = try? JSONDecoder().decode([Debtor].self, from: data) {
            debtors = loaded
            persist() // сохраняем уже в файл
            UserDefaults.standard.removeObject(forKey: legacyKey)
            Analytics.shared.event("load_ok_migrated_from_userdefaults")
            return
        }

        debtors = []
        Analytics.shared.event("load_empty")
    }

    private func storageURL() throws -> URL {
        let base = try FileManager.default.url(for: .applicationSupportDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: true)
        return base.appendingPathComponent(fileName)
    }

    private func writeProtectedFile(_ data: Data) throws {
        let url = try storageURL()
        // completeFileProtection — защита данных при заблокированном устройстве
        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    private func readProtectedFile() throws -> Data {
        let url = try storageURL()
        return try Data(contentsOf: url)
    }

    // MARK: - Export

    func exportAsText() -> String {
        var lines: [String] = []
        lines.append("Debtors export — \(Date())")
        lines.append("Всего должников: \(debtors.count)")
        lines.append("")

        for d in debtors {
            lines.append("Должник: \(d.name)")
            for debt in d.debts {
                let status = debt.isActive ? "АКТИВНЫЙ" : "ЗАКРЫТ"
                let total = debt.isActive ? debt.totalAmount : (debt.paidAmount ?? debt.totalAmount)
                lines.append("  • \(status), сумма: \(AppTheme.number(total)), %: \(debt.percent), период: \(debt.period), дата: \(AppTheme.dateFormatter.string(from: debt.loanDate))")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
