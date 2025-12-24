//
//  CurrentDebtors.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct CurrentDebtors: View {
    @EnvironmentObject var debtorStore: DebtorStore

    @State private var searchText: String = ""
    @State private var showAdd = false
    @State private var showNPS = false

    private var activeDebtors: [Debtor] {
        debtorStore.debtors
            .map { debtor in
                Debtor(
                    id: debtor.id,
                    name: debtor.name,
                    debts: debtor.debts.filter { $0.isActive }
                )
            }
            .filter { !$0.debts.isEmpty }
    }

    private var totalActiveAmount: Double {
        activeDebtors.reduce(0) { partial, debtor in
            partial + debtor.debts.filter { $0.isActive }.reduce(0) { $0 + $1.totalAmount }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                headerCard

                if activeDebtors.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(activeDebtors) { debtor in
                            NavigationLink(destination: DebtorView(debtorId: debtor.id)) {
                                debtorRow(debtor)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Активные долги")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Поиск по имени")
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    CreateNewDebtor()
                        .environmentObject(debtorStore)
                        .navigationTitle("Добавить долг")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .sheet(isPresented: $showNPS) {
                NPSPromptView(store: debtorStore)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Сводка")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Активных должников")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(activeDebtors.count)")
                        .font(.title3).bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Сумма активных долгов")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(AppTheme.currency(totalActiveAmount))
                        .font(.title3).bold()
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func debtorRow(_ debtor: Debtor) -> some View {
        let activeDebts = debtor.debts.filter { $0.isActive }
        let sum = activeDebts.reduce(0) { $0 + $1.totalAmount }
        let nextDate = activeDebts.map { $0.nextPaymentDate }.min() ?? Date()

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(debtor.name)
                    .font(.headline)
                Spacer()
                Text(AppTheme.currency(sum))
                    .font(.subheadline).bold()
            }
            HStack(spacing: 10) {
                Label("\(activeDebts.count)", systemImage: "banknote")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(AppTheme.dateFormatter.string(from: nextDate), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text("Пока нет активных долгов")
                .font(.headline)
            Text("Добавьте должника и сумму, чтобы приложение начало вести учёт и напоминать о начислении процентов.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showAdd = true
            } label: {
                Text("Добавить долг")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Spacer(minLength: 0)
        }
        .padding(.top, 24)
    }
}

struct CurrentDebtors_Previews: PreviewProvider {
    static var previews: some View {
        let debtorStore = DebtorStore()
        debtorStore.addDebtor(Debtor(name: "Alex", debts: [Debt(amount: 100, percent: 1, period: 1, loanDate: Date(), comment: "", isActive: true)]))
        return CurrentDebtors().environmentObject(debtorStore)
    }
}
