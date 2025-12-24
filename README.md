# Debtors 📒💰

**Debtors** is an iOS application built with SwiftUI for tracking debtors and their loans.  
It allows users to store debt information, automatically calculate interest,
and receive notifications when interest is applied.

---

## 🚀 Features

- Add debtors and multiple debts for each debtor
- Support for interest rates with different accrual periods:
  - daily
  - weekly
  - monthly
  - quarterly
  - yearly
- Automatic calculation of the current total debt amount
- Closing a debt with фиксацией the paid amount
- Notifications for upcoming interest accrual dates
- Local data storage using `UserDefaults`
- Modern user interface built with SwiftUI

---

## 🧱 Project Architecture

The project is built using the **MVVM architecture** and `ObservableObject`.

### Core Models

- `Debtor` — represents a debtor (name and list of debts)
- `Debt` — represents a debt (amount, interest rate, period, dates, and status)

### Data Storage

- `DebtorStore`
  - Manages debtors and debts
  - Persists data using `UserDefaults`
  - Schedules local notifications via `UserNotifications`

### Views (SwiftUI)

- `CurrentDebtors` — displays active debts
- `AllDebtors` — shows all debtors
- `CreateNewDebtor` — form for adding a debtor or a debt
- `DebtorView` — detailed view of a specific debtor

---

## 🔔 Notifications

The app uses `UNUserNotificationCenter` to remind users
about upcoming interest accrual dates for active debts.

Notification permission is requested on the first app launch.

---

## 🛠️ Technologies

- Swift
- SwiftUI
- Combine
- UserDefaults
- UserNotifications

---

## 📦 Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/USERNAME/Debtors.git
