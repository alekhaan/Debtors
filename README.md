# Debtors 📒💰

**Debtors** is an iOS application built with SwiftUI for tracking debtors and their loans.  
It allows users to store debt information, automatically calculate interest,
and receive notifications about upcoming interest accruals.

---

## 🚀 Features

- Add debtors and manage multiple debts for each debtor
- Support for interest rates with different accrual periods:
  - daily
  - weekly
  - monthly
  - quarterly
  - yearly
- Automatic calculation of the current total debt amount
- Ability to close a debt with the paid amount recorded
- Local notifications before interest is applied
- Local data persistence using `UserDefaults`
- Clean and modern user interface built with SwiftUI

---

## 🧱 Project Architecture

The project follows the **MVVM architecture** pattern and makes use of `ObservableObject`
for state management.

### Core Models

- `Debtor` — represents a debtor (name and list of debts)
- `Debt` — represents a single debt, including:
  - initial amount
  - interest rate
  - accrual period
  - loan date
  - calculated total amount
  - status (active / closed)

---

## 🗄️ Data & Business Logic

### DebtorStore

- Central data store for all debtors and debts
- Handles:
  - adding and removing debtors
  - adding, closing, and deleting debts
  - automatic recalculation of debt amounts
- Persists data locally using `UserDefaults`
- Schedules local notifications for active debts

### NotificationManager

- Encapsulates notification scheduling logic
- Creates local notifications to remind users
  about upcoming interest increases

---

## 🎨 User Interface (SwiftUI Views)

- `CurrentDebtors` — displays all active debts grouped by debtor
- `AllDebtors` — list of all debtors
- `CreateNewDebtor` — form for creating a new debtor or adding a debt
- `DebtorView` — detailed view of a debtor and all associated debts
- `DebtView` — reusable view for displaying a single debt:
  - active or closed state
  - dates, interest rate, and calculated amounts
  - optional user comments

---

## 🔔 Notifications

The app uses `UNUserNotificationCenter` to notify users
about upcoming interest accruals for active debts.

Notification permission is requested on the first app launch.

Notifications are scheduled automatically based on the debt’s accrual period.

---

## 🛠️ Technologies

- Swift
- SwiftUI
- Combine
- UserDefaults
- UserNotifications

---

## 📦 Installation & Run

Clone the repository:
   ```bash
   git clone https://github.com/USERNAME/Debtors.git
