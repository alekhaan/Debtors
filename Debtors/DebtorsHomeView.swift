//
//  DebtorsHomeView.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//


import SwiftUI

struct DebtorsHomeView: View {
    @EnvironmentObject var debtorStore: DebtorStore

    var body: some View {
        TabView {
            CurrentDebtors()
                .tabItem { Label("Активные", systemImage: "list.bullet.rectangle") }

            AllDebtors()
                .tabItem { Label("Все", systemImage: "person.3") }

            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gear") }
        }
    }
}
