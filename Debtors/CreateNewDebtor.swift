//
//  CreateNewDebtor.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import SwiftUI

struct CreateNewDebtor: View {
    @Environment(\.presentationMode) var presentationMode
    
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
    @State private var activeAlert: ActiveAlert = .wrongData
    @State private var filteredDebtors: [Debtor] = []
    
    func addDebtor() -> Bool {
        if debtorName.isEmpty && debtAmount.isEmpty {
            self.activeAlert = .wrongData
            self.showAlert = true
            return false
        }

        guard let amount = Double(debtAmount),
              amount.isFinite,
              amount > 0
        else {
            self.activeAlert = .wrongData
            self.showAlert = true
            return false
        }

        if let existingDebtor = selectedDebtor {
            let newDebt = Debt(amount: amount, percent: selectedPercent, period: selectedPeriod, loanDate: loanDate, comment: comment, isActive: true)
            debtorStore.addDebt(newDebt, to: existingDebtor)
        } else {
            let newDebtor = Debtor(name: debtorName, debts: [Debt(amount: amount, percent: selectedPercent, period: selectedPeriod, loanDate: loanDate, comment: comment, isActive: true)])
            debtorStore.addDebtor(newDebtor)
        }

        // очистка полей — ок
        debtorName = ""
        selectedDebtor = nil
        debtAmount = ""
        selectedPercent = 1
        selectedPeriod = 1
        loanDate = Date()
        comment = ""

        return true
    }
    
    var body: some View {
        Form {
            Section(header: Text("Данные должника")) {
                TextField("Имя должника", text: $debtorName)
                    .onChange(of: debtorName) { newName in
                        if !newName.isEmpty {
                            filteredDebtors = debtorStore.debtors.filter ({ $0.name.localizedCaseInsensitiveContains(newName) })
                        } else {
                            filteredDebtors = []
                        }
                    }
                if !filteredDebtors.isEmpty {
                    Text("Похожие имена:")
                        .font(.headline)
                    ForEach(filteredDebtors.prefix(5)) { debtor in
                        Button(action: {
                            selectedDebtor = debtor
                            debtorName = debtor.name
                        }) {
                            Text(debtor.name)
                        }
                    }
                }
                
                TextField("Сумма долга", text: $debtAmount).keyboardType(.decimalPad)
                
                HStack {
                    Picker("Процент", selection: $selectedPercent) {
                        ForEach(percents, id: \.self) { percent in
                            Text("\(percent)%")
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                    
                    Spacer()
                    
                    Picker("Период", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            switch period {
                            case 1:
                                Text("1 день")
                            case 7:
                                Text("1 неделя")
                            case 30:
                                Text("1 месяц")
                            case 90:
                                Text("3 месяца")
                            case 365:
                                Text("1 год")
                            default:
                                Text("")
                            }
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                }
                DatePicker("Дата взятия долга", selection: $loanDate, displayedComponents: .date)
                TextField("Комментарий", text: $comment)
            }
            
            Button("Добавить") {
                let ok = addDebtor()
                if ok {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .wrongData:
                return Alert(title: Text("Ошибка"), message: Text("Введите корректные данные"))
            case .successfulAdd:
                return Alert(title: Text("Должник добавлен"))
            }
        }
        
        Spacer()
    }
}

struct CreateNewDebtor_Previews: PreviewProvider {
    static var previews: some View {
        let debtorStore = DebtorStore()
        debtorStore.addDebtor(Debtor(name: "Alex", debts: [Debt(amount: 100, percent: 1, period: 1, loanDate: Date(), comment: "", isActive: true)]))
        return CreateNewDebtor().environmentObject(debtorStore)
    }
}
