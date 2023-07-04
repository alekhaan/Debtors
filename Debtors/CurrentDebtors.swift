//
//  CurrentDebtors.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct CurrentDebtors: View {
    @EnvironmentObject var debtorStore: DebtorStore
    @State private var showAllDebtors = false
    @State private var addNewDebtor = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(debtorStore.debtors.filter { debtor in debtor.debts.contains(where: { $0.isActive })}) { debtor in
                    DisclosureGroup {
                        ForEach(debtor.debts.filter { $0.isActive }) { debt in
                            VStack {
                                HStack {
                                    Text("Текущая сумма: \(String(format: "%.2f", debt.totalAmount))")
                                        .font(.body)
                                    Spacer()
                                    Text("\(String(debt.percent))%")
                                        .font(.body)
                                }
                                HStack {
                                    Text("Взятие долга: \(dateFormatter.string(from: debt.loanDate))")
                                        .font(.body)
                                    Spacer()
                                }
                                HStack {
                                    Text("Следующее начисление процента: \(dateFormatter.string(from: debt.nextPaymentDate))")
                                        .font(.body)
                                    Spacer()
                                }
                            }
                            .swipeActions {
                                Button(action: {
                                    debtorStore.deactivateDebt(debt, from: debtor)
                                }) {
                                    Label("Завершить", systemImage: "banknote")
                                }
                                .tint(.green)
                            }
                        }
                    } label: {
                        HStack {
                            Text(debtor.name)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f", debtor.debts.filter { $0.isActive }.reduce(0) { $0 + $1.totalAmount }))
                                .font(.body)
                        }
                    }
                }
                .navigationBarTitle("Список должников").font(.title)
                
                NavigationLink(destination: CreateNewDebtor().environmentObject(debtorStore), label: {
                    Text("Добавить")
                })
                .buttonStyle(.borderedProminent)
                
                NavigationLink(destination: AllDebtors().environmentObject(debtorStore), label: {
                    Text("Показать всех")
                })
                .buttonStyle(.bordered)
            }
        }
    }
}

struct CurrentDebtors_Previews: PreviewProvider {
    static var previews: some View {
        let debtorStore = DebtorStore()
        debtorStore.addDebtor(Debtor(name: "Alex", debts: [Debt(amount: 100, percent: 1, period: 1, loanDate: Date(), comment: "", isActive: true)]))
        return CurrentDebtors().environmentObject(debtorStore)
    }
}
