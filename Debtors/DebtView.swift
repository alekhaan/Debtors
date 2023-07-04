//
//  DebtView.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct DebtView: View {
    let debt: Debt
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack {
                if debt.isActive {
                    Text("Активная сумма: \(String(format: "%0.2f", debt.totalAmount))")
                } else {
                    Text("Выплаченная сумма \(dateFormatter.string(from: debt.closeDate ?? Date())): \(String(format: "%0.2f", debt.paidAmount ?? debt.totalAmount))")
                }
                Spacer()
            }
            HStack {
                Text("Сумма взятия: \(String(format: "%0.2f", debt.amount))")
                Spacer()
                Text("\(debt.percent)%")
            }
            HStack {
                Text("Дата взятия: \(dateFormatter.string(from: debt.loanDate))")
                Spacer()
                switch debt.period {
                case 1:
                    Text("Период: 1 день")
                case 7:
                    Text("Период: 1 неделя")
                case 30:
                    Text("Период: 1 месяц")
                case 90:
                    Text("Период: 3 месяца")
                case 365:
                    Text("Период: 1 год")
                default:
                    Text("Без периода, потому что ты его любишь")
                }
            }
            if (!debt.comment.isEmpty) {
                Text("Комментарий: " + debt.comment)
            }
        }
    }
}

struct DebtView_Previews: PreviewProvider {
    static var previews: some View {
        DebtView(debt: Debt(amount: 1000, percent: 1, period: 1, loanDate: Date(), comment: "abcds", isActive: true))
    }
}
