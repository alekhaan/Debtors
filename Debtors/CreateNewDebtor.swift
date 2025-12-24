//
//  CreateNewDebtor.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct CreateNewDebtor: View {
    @Environment(\.dismiss) private var dismiss

    let percents = [0, 1, 5, 10, 20, 50]
    let periods = [1, 7, 30, 90, 365]

    @EnvironmentObject var debtorStore: DebtorStore
    @State private var debtorName: String = ""
    @State private var selectedDebtor: Debtor?
    @State private var debtAmount: String = ""
    @State private var selectedPercent = 1
    @State private var selectedPeriod = 1
    @State private var loanDate: Date = Date()
    @State private var comment: String = ""

    @State private var showAlert = false
    @State private var alertText = "Введите корректные данные"
    @State private var filteredDebtors: [Debtor] = []

    private func parseAmount(_ s: String) -> Double? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Поддержка “1,23” и “1.23”
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func addDebtor() {
        let name = debtorName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            alertText = "Введите имя должника"
            showAlert = true
            return
        }

        guard let amount = parseAmount(debtAmount), amount.isFinite, amount > 0 else {
            alertText = "Введите сумму долга больше 0"
            showAlert = true
            return
        }

        // Заём не должен быть “в будущем” — иначе nextPaymentDate / начисления будут странными
        if loanDate > Date() {
            alertText = "Дата взятия долга не может быть в будущем"
            showAlert = true
            return
        }

        let newDebt = Debt(amount: amount,
                           percent: selectedPercent,
                           period: selectedPeriod,
                           loanDate: loanDate,
                           comment: comment,
                           isActive: true)

        if let existing = selectedDebtor {
            debtorStore.addDebt(newDebt, to: existing)
            Analytics.shared.event("debt_added_existing")
        } else {
            let newDebtor = Debtor(name: name, debts: [newDebt])
            debtorStore.addDebtor(newDebtor)
            Analytics.shared.event("debtor_created_and_debt_added")
        }

        dismiss()
    }

    var body: some View {
        Form {
            Section("Данные должника") {
                TextField("Имя должника", text: $debtorName)
                    .textInputAutocapitalization(.words)
                    .onChange(of: debtorName) { newName in
                        if let selected = selectedDebtor,
                           selected.name.caseInsensitiveCompare(newName) == .orderedSame {
                            filteredDebtors = []
                            return
                        }

                        if !newName.trimmingCharacters(in: .whitespaces).isEmpty {
                            filteredDebtors = debtorStore.debtors
                                .filter {
                                    $0.name.localizedCaseInsensitiveContains(newName) && $0.id != selectedDebtor?.id
                                }
                        } else {
                            filteredDebtors = []
                        }
                    }


                if !filteredDebtors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Похожие имена")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(filteredDebtors.prefix(5)) { debtor in
                            Button {
                                selectedDebtor = debtor
                                debtorName = debtor.name
                            } label: {
                                HStack {
                                    Image(systemName: "person.crop.circle")
                                    Text(debtor.name)
                                    Spacer()
                                    Text("выбрать")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                TextField("Сумма долга", text: $debtAmount)
                    .keyboardType(.decimalPad)

                Picker("Процент", selection: $selectedPercent) {
                    ForEach(percents, id: \.self) { p in
                        Text("\(p)%").tag(p)
                    }
                }

                Picker("Период начисления", selection: $selectedPeriod) {
                    ForEach(periods, id: \.self) { period in
                        Text(periodTitle(period)).tag(period)
                    }
                }

                DatePicker("Дата взятия долга", selection: $loanDate, displayedComponents: .date)
                TextField("Комментарий (необязательно)", text: $comment)
            }

            Button {
                addDebtor()
            } label: {
                Text("Сохранить")
                    .frame(maxWidth: .infinity)
            }
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertText)
        }
    }

    private func periodTitle(_ period: Int) -> String {
        switch period {
        case 1: return "1 день"
        case 7: return "1 неделя"
        case 30: return "1 месяц"
        case 90: return "3 месяца"
        case 365: return "1 год"
        default: return "Период: \(period)"
        }
    }
}

struct CreateNewDebtor_Previews: PreviewProvider {
    static var previews: some View {
        let debtorStore = DebtorStore()
        debtorStore.addDebtor(Debtor(name: "Alex", debts: [Debt(amount: 100, percent: 1, period: 1, loanDate: Date(), comment: "", isActive: true)]))
        return CreateNewDebtor().environmentObject(debtorStore)
    }
}
