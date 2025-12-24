//
//  AppTheme.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//


import SwiftUI

enum AppTheme {
    static let accent = Color.accentColor

    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    static let subtleBackground = Color(uiColor: .systemBackground)

    static let cornerRadius: CGFloat = 16

    static func currency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    static func number(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()
}
