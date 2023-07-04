//
//  Debt.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import Foundation

struct Debt: Identifiable, Codable, Hashable{
    var id = UUID()
    let amount: Double
    var paidAmount: Double?
    let percent: Int
    let period: Int
    let loanDate: Date
    var closeDate: Date?
    let comment: String
    var isActive: Bool
    
    var totalAmount: Double {
        var sum = amount
        var numberOfPeriods = 0
        
        switch period {
        case 1:
            numberOfPeriods = Calendar.current.dateComponents([.day], from: loanDate, to: Date()).day ?? 0
        case 7:
            numberOfPeriods = Calendar.current.dateComponents([.weekOfYear], from: loanDate, to: Date()).weekOfYear ?? 0
        case 30:
            numberOfPeriods = Calendar.current.dateComponents([.month], from: loanDate, to: Date()).month ?? 0
        case 90:
            numberOfPeriods = Calendar.current.dateComponents([.month], from: loanDate, to: Date()).month ?? 0
            numberOfPeriods = numberOfPeriods / 3
        case 365:
            numberOfPeriods = Calendar.current.dateComponents([.year], from: loanDate, to: Date()).year ?? 0
        default:
            numberOfPeriods = 0
        }
        
        if numberOfPeriods > 1 {
            for _ in 1...numberOfPeriods {
                sum = sum + (sum * Double(percent) / 100)
            }
        }
        return sum
    }
    
    var nextPaymentDate: Date {
        let currentDate = Date()
        var paymentDate = loanDate
        while paymentDate < currentDate {
            switch period {
            case 1:
                paymentDate = Calendar.current.date(byAdding: .day, value: 1, to: paymentDate) ?? loanDate
            case 7:
                paymentDate = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: paymentDate) ?? loanDate
            case 30:
                paymentDate = Calendar.current.date(byAdding: .month, value: 1, to: paymentDate) ?? loanDate
            case 90:
                paymentDate = Calendar.current.date(byAdding: .month, value: 3, to: paymentDate) ?? loanDate
            case 365:
                paymentDate = Calendar.current.date(byAdding: .year, value: 1, to: paymentDate) ?? loanDate
            default:
                paymentDate = loanDate
            }
        }
        return paymentDate
    }
}
