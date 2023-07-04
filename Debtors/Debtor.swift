//
//  Debtor.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import Foundation

struct Debtor: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    var debts: [Debt]
}
