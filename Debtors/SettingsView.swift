//
//  SettingsView.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//

import UIKit
import SwiftUI
import UserNotifications

private var notificationStatusText: String {
    let center = UNUserNotificationCenter.current()
    var status = "Определяется…"

    center.getNotificationSettings { settings in
        DispatchQueue.main.async {
            switch settings.authorizationStatus {
            case .authorized:
                status = "Разрешены"
            case .denied:
                status = "Запрещены"
            case .notDetermined:
                status = "Не запрошены"
            default:
                status = "Неизвестно"
            }
        }
    }
    return status
}

func hapticSuccess() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SettingsView: View {
    @EnvironmentObject var debtorStore: DebtorStore
    @ObservedObject private var feedback = FeedbackManager.shared

    @State private var notificationsEnabled = false
    @State private var showNPS = false
    @State private var showShare = false
    @State private var exportText: String = ""

    @State private var toastText: String?
    @State private var toastIcon: String = "checkmark.circle.fill"

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(notificationsEnabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)

                                Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                                    .foregroundColor(notificationsEnabled ? .green : .gray)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Уведомления")
                                    .font(.headline)
                                Text(notificationsEnabled ? "Включены" : "Выключены")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { notificationsEnabled },
                                set: { toggleNotifications($0) }
                            ))
                            .labelsHidden()
                        }
                        .padding(.vertical, 6)
                    } header: {
                        Text("Уведомления")
                    }
                    Section {
                        Button {
                            showNPS = true
                        } label: {
                            Label("Оценить приложение", systemImage: "star.fill")
                        }
                    } header: {
                        Text("Оценка")
                    }
                    Section {
                        if let summary = feedback.npsSummary() {
                            HStack {
                                Text("Средняя оценка")
                                Spacer()
                                Text(String(format: "%.2f", summary.avg))
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Количество оценок")
                                Spacer()
                                Text("\(summary.count)")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("Оценок пока нет")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Качество сервиса")
                    }
                    Section {
                        Button {
                            exportText = debtorStore.exportAsText()
                            showShare = true
                            showToast("Данные подготовлены", icon: "square.and.arrow.up")
                        } label: {
                            Label("Экспорт данных", systemImage: "square.and.arrow.up")
                        }
                    } header: {
                        Text("Данные")
                    }
                    Section {
                        infoRow("Версия", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
                        infoRow("Сборка", Bundle.main.infoDictionary?["CFBundleVersion"] as? String)
                    } header: {
                        Text("О приложении")
                    }
                }
                .navigationTitle("Настройки")
                
                if let toastText {
                    VStack {
                        ToastView(text: toastText, systemImage: toastIcon)
                            .padding(.top, 16)
                        Spacer()
                    }
                }
            }
            .onAppear(perform: loadNotificationState)
            .sheet(isPresented: $showNPS) {
                NPSPromptView(store: debtorStore)
            }
            .sheet(isPresented: $showShare) {
                ShareSheet(activityItems: [exportText])
            }
        }
    }

    // MARK: - 🔔 Уведомления логика

    private func loadNotificationState() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled

        if enabled {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async {
                        if granted {
                            debtorStore.scheduleNotifications()
                            notificationsEnabled = true
                            showToast("Уведомления включены", icon: "bell.fill")
                        } else {
                            notificationsEnabled = false
                            openSystemSettings()
                            showToast("Разрешите уведомления в настройках iOS", icon: "exclamationmark.triangle")
                        }
                    }
                }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            showToast("Уведомления выключены", icon: "bell.slash.fill")
        }
    }

    // MARK: - Helpers

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func showToast(_ text: String, icon: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        toastIcon = icon
        toastText = text

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                toastText = nil
            }
        }
    }

    private func infoRow(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value ?? "-")
                .foregroundStyle(.secondary)
        }
    }
}
