//
//  MetricsKitBridge.swift
//  Debtors
//
//  Created by AlexGod on 24.12.2025.
//


import Foundation
import os

#if canImport(MetricKit)
import MetricKit

@available(iOS 13.0, *)
final class MetricsKitBridge: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricsKitBridge()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Debtors", category: "metrickit")

    func start() {
        MXMetricManager.shared.add(self)
        logger.info("MetricKit subscriber registered")
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        // Упрощённый пример: логируем факт получения метрик
        logger.info("MetricKit payloads received: \(payloads.count, privacy: .public)")
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        logger.info("MetricKit diagnostics received: \(payloads.count, privacy: .public)")
    }
}
#endif
