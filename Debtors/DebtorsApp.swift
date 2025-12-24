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
            DebtorsHomeView()
                .environmentObject(debtorStore)
                .onAppear {
                    debtorStore.requestNotificationPermission()
                    debtorStore.scheduleNotifications()

                    #if canImport(MetricKit)
                    if #available(iOS 13.0, *) {
                        MetricsKitBridge.shared.start()
                    }
                    #endif

                    Analytics.shared.event("app_started")
                }
        }
    }
}
