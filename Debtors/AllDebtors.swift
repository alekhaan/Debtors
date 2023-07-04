//
//  AllDebtors.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct AllDebtors: View {
    @EnvironmentObject var debtorStore: DebtorStore
    
    var body: some View {
        List {
            ForEach(debtorStore.debtors) { debtor in
                NavigationLink(destination: DebtorView(debtor: debtor)) {
                    Text(debtor.name)
                }
                .swipeActions {
                    Button(action: {
                        debtorStore.removeDebtor(debtor)
                    }) {
                        Label("Удалить", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .navigationTitle("Все должники")
    }
}

struct AllDebtors_Previews: PreviewProvider {
    static var previews: some View {
        let debtoreStore = DebtorStore()
        debtoreStore.addDebtor(Debtor(name: "Alex", debts: [Debt(amount: 500, percent: 5, period: 1, loanDate: Date(), comment: "", isActive: false)]))
        return AllDebtors().environmentObject(debtoreStore)
    }
}
