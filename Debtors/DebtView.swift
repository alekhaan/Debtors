//
//  DebtView.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct DebtView: View {
    let debt: Debt

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(debt.isActive ? "Активный долг" : "Закрытый долг")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(debt.isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()

                Text("\(debt.percent)%")
                    .font(.headline)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(debt.isActive ? "Текущая сумма" : "Выплачено")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    let total = debt.isActive ? debt.totalAmount : (debt.paidAmount ?? debt.totalAmount)
                    Text(AppTheme.currency(total))
                        .font(.title3).bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Сумма взятия")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(AppTheme.currency(debt.amount))
                        .font(.subheadline).bold()
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Взято: \(AppTheme.dateFormatter.string(from: debt.loanDate))", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                if debt.isActive {
                    HStack {
                        Label("Следующее начисление: \(AppTheme.dateFormatter.string(from: debt.nextPaymentDate))", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else if let close = debt.closeDate {
                    HStack {
                        Label("Закрыто: \(AppTheme.dateFormatter.string(from: close))", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }

                HStack {
                    Label(periodTitle(debt.period), systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                if !debt.comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Комментарий: \(debt.comment)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func periodTitle(_ period: Int) -> String {
        switch period {
        case 1: return "Период: 1 день"
        case 7: return "Период: 1 неделя"
        case 30: return "Период: 1 месяц"
        case 90: return "Период: 3 месяца"
        case 365: return "Период: 1 год"
        default: return "Период: \(period)"
        }
    }
}

struct DebtView_Previews: PreviewProvider {
    static var previews: some View {
        DebtView(debt: Debt(amount: 1000, percent: 1, period: 1, loanDate: Date(), comment: "abcds", isActive: true))
    }
}
