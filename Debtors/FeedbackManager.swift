//
//  FeedbackManager.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//

import Foundation

final class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()

    @Published private(set) var npsVersion: Int = 0

    private let defaults = UserDefaults.standard
    private let npsHistoryKey = "feedback.npsHistory"

    private init() {}

    func submitNPS(score: Int) {
        var history = (defaults.array(forKey: npsHistoryKey) as? [Int]) ?? []
        history.append(score)
        defaults.set(history, forKey: npsHistoryKey)
        npsVersion += 1
    }

    func npsSummary() -> (count: Int, avg: Double)? {
        let history = (defaults.array(forKey: npsHistoryKey) as? [Int]) ?? []
        guard !history.isEmpty else { return nil }

        let avg = Double(history.reduce(0, +)) / Double(history.count)
        return (history.count, avg)
    }
}
