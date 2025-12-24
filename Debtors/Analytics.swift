//
//  Analytics.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//


import Foundation
import os

final class Analytics {
    static let shared = Analytics()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Debtors", category: "analytics")

    private init() {}

    func event(_ name: String, _ params: [String: String] = [:]) {
        if params.isEmpty {
            logger.info("event=\(name, privacy: .public)")
        } else {
            logger.info("event=\(name, privacy: .public) params=\(params.description, privacy: .public)")
        }
    }

    func error(_ name: String, _ message: String) {
        logger.error("error=\(name, privacy: .public) message=\(message, privacy: .public)")
    }
}
