//
//  DebtorView.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct DebtorView: View {
    @EnvironmentObject var debtorStore: DebtorStore
    let debtor: Debtor
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var body: some View {
        List {
            Text("Всего взято на: \(String(format: "%0.2f", debtor.debts.reduce(0) { $0 + ($1.paidAmount ?? $1.totalAmount) }))")
            Section {
                ForEach(debtor.debts, content: { debt in
                    DebtView(debt: debt)
                        .opacity(debt.isActive ? 1.0 : 0.6)
                        .swipeActions(content: {
                            Button(action: {
                                debtorStore.removeDebt(debt, from: debtor)
                            }) {
                                Label("Удалить", systemImage: "trash")
                            }
                            .tint(.red)
                        })
                })
            }
        }
        .navigationBarTitle(debtor.name)
    }
}

struct DebtorView_Previews: PreviewProvider {
    static var previews: some View {
        let debtorStore = DebtorStore()
        return DebtorView(debtor: Debtor(name: "Alex", debts: [Debt(amount: 500, percent: 1, period: 1, loanDate: Date(), comment: "", isActive: true)])).environmentObject(debtorStore)
    }
}
