//
//  DebtorsApp.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

@main
struct DebtorsApp: App {
    @StateObject private var debtorStore = DebtorStore()

    var body: some Scene {
        WindowGroup {
            CurrentDebtors()
                .environmentObject(debtorStore)
                .onAppear {
                    debtorStore.requestNotificationPermission()
                    debtorStore.scheduleNotifications()
                }
        }
    }
}
