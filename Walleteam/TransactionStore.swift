//
//  TransactionStore.swift
//  Walleteam
//

import Foundation
import Observation

@Observable
final class TransactionStore {
    private enum Keys {
        static let transactions = "transactions"
    }

    var transactions: [Transaction] = [] {
        didSet {
            save()
        }
    }

    init() {
        load()
    }

    func addTransaction(
        title: String,
        amount: Double,
        date: Date,
        type: EntryType,
        category: EntryCategory? = nil,
        dueDate: Date? = nil,
        isBalanceSetup: Bool = false
    ) {
        let transaction = Transaction(
            title: title,
            amount: amount,
            date: date,
            type: type,
            category: category,
            dueDate: dueDate,
            isBalanceSetup: isBalanceSetup
        )
        transactions.insert(transaction, at: 0)
    }

    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
    }

    func deleteTransaction(id: UUID) {
        transactions.removeAll { $0.id == id }
    }

    func updateTransaction(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
    }

    func transaction(with id: UUID) -> Transaction? {
        transactions.first { $0.id == id }
    }

    func toggleImportant(transactionId: UUID) {
        guard let index = transactions.firstIndex(where: { $0.id == transactionId }) else { return }
        transactions[index].isImportant.toggle()
    }

    var importantTransactions: [Transaction] {
        transactions.filter(\.isImportant)
    }

    var transactionHistory: [Transaction] {
        transactions
            .filter { !$0.isBalanceSetup }
            .sorted { $0.date > $1.date }
    }

    func transactions(for cardTitle: String) -> [Transaction] {
        switch cardTitle {
        case "Today":
            return transactions
                .filter { !$0.isBalanceSetup && Calendar.current.isDateInToday($0.date) }
                .sorted { $0.date > $1.date }
        case "History":
            return transactionHistory
        case "Earning":
            return transactions.filter { $0.type == .earning }
        case "Expense":
            return transactions.filter { $0.type == .expense }
        case "Due Date":
            return transactions
                .filter { $0.dueDate != nil }
                .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case "Important":
            return importantTransactions
        case "My Lent":
            return transactions.filter { $0.type == .lent }
        case "My Borrow":
            return transactions.filter { $0.type == .borrow }
        default:
            return []
        }
    }

    func count(for cardTitle: String) -> Int {
        transactions(for: cardTitle).count
    }

    var totalLentAmount: Double {
        transactions.filter { $0.type == .lent }.reduce(0) { $0 + $1.amount }
    }

    var totalBorrowedAmount: Double {
        transactions.filter { $0.type == .borrow }.reduce(0) { $0 + $1.amount }
    }

    var monthlyLentAmount: Double {
        transactions
            .filter { $0.type == .lent && Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyBorrowedAmount: Double {
        transactions
            .filter { $0.type == .borrow && Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyLentBorrowNet: Double {
        monthlyBorrowedAmount - monthlyLentAmount
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(transactions) else { return }
        UserDefaults.standard.set(data, forKey: Keys.transactions)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.transactions),
            let decoded = try? JSONDecoder().decode([Transaction].self, from: data)
        else {
            transactions = []
            return
        }
        transactions = decoded
    }
}

extension EntryType {
    var accentColor: (red: Double, green: Double, blue: Double) {
        switch self {
        case .expense: (0.28, 0.28, 0.3)
        case .earning: (1.0, 0.27, 0.23)
        case .lent: (0.68, 0.68, 0.7)
        case .borrow: (1.0, 0.8, 0.0)
        }
    }
}

extension Transaction {
    var accentColor: (red: Double, green: Double, blue: Double) {
        type.accentColor
    }
}
