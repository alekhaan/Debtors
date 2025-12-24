//
//  DebtorView.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct DebtorView: View {
    @EnvironmentObject var debtorStore: DebtorStore
    let debtorId: UUID

    private var debtor: Debtor? {
        debtorStore.debtors.first(where: { $0.id == debtorId })
    }

    private var totalTaken: Double {
        (debtor?.debts ?? []).reduce(0) { $0 + ($1.paidAmount ?? $1.totalAmount) }
    }

    private var activeSum: Double {
        (debtor?.debts ?? []).filter { $0.isActive }.reduce(0) { $0 + $1.totalAmount }
    }

    var body: some View {
        Group {
            if let debtor {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Сводка по должнику")
                                .font(.headline)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Активно")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(AppTheme.currency(activeSum))
                                        .font(.title3).bold()
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Всего взято")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(AppTheme.currency(totalTaken))
                                        .font(.title3).bold()
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    Section("Долги") {
                        ForEach(debtor.debts) { debt in
                            DebtView(debt: debt)
                                .opacity(debt.isActive ? 1.0 : 0.55)
                                .swipeActions {
                                    if debt.isActive {
                                        Button {
                                            debtorStore.deactivateDebt(debt, from: debtor)
                                        } label: {
                                            Label("Закрыть", systemImage: "checkmark.seal")
                                        }
                                        .tint(.green)
                                    }

                                    Button(role: .destructive) {
                                        debtorStore.removeDebt(debt, from: debtor)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(debtor.name)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView("Должник не найден", systemImage: "person.crop.circle.badge.exclamationmark")
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}

struct DebtorView_Previews: PreviewProvider {
    static var previews: some View {
        let store = DebtorStore()
        let d = Debtor(name: "Alex", debts: [Debt(amount: 500, percent: 1, period: 1, loanDate: Date(), comment: "", isActive: true)])
        store.addDebtor(d)
        return NavigationStack {
            DebtorView(debtorId: d.id)
        }
        .environmentObject(store)
    }
}
