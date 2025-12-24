//
//  AllDebtors.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct AllDebtors: View {
    @EnvironmentObject var debtorStore: DebtorStore
    @State private var searchText: String = ""

    private var filtered: [Debtor] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return debtorStore.debtors
        }
        return debtorStore.debtors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { debtor in
                    NavigationLink(destination: DebtorView(debtorId: debtor.id)) {
                        HStack {
                            Text(debtor.name)
                                .font(.headline)
                            Spacer()
                            let total = debtor.debts.reduce(0) { $0 + ($1.paidAmount ?? $1.totalAmount) }
                            Text(AppTheme.currency(total))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            debtorStore.removeDebtor(debtor)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Все должники")
            .searchable(text: $searchText, prompt: "Поиск по имени")
        }
    }
}

struct AllDebtors_Previews: PreviewProvider {
    static var previews: some View {
        let debtoreStore = DebtorStore()
        debtoreStore.addDebtor(Debtor(name: "Alex", debts: [Debt(amount: 500, percent: 5, period: 1, loanDate: Date(), comment: "", isActive: false)]))
        return AllDebtors().environmentObject(debtoreStore)
    }
}
