//
//  AddEntryView.swift
//  Walleteam
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BalanceStore.self) private var balanceStore
    @Environment(TransactionStore.self) private var transactionStore

    let editingTransaction: Transaction?

    @State private var amount: String
    @State private var title: String
    @State private var date: Date
    @State private var entryType: EntryType
    @State private var category: EntryCategory
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    private let accentBlue = Color(red: 3/255, green: 94/255, blue: 168/255)

    init(editingTransaction: Transaction? = nil) {
        self.editingTransaction = editingTransaction

        _amount = State(initialValue: editingTransaction.map { String(format: "%.0f", $0.amount) } ?? "")
        _title = State(initialValue: editingTransaction?.title ?? "")
        _date = State(initialValue: editingTransaction?.date ?? Date())
        _entryType = State(initialValue: editingTransaction?.type ?? .expense)
        _category = State(initialValue: editingTransaction?.category ?? .other)
        _hasDueDate = State(initialValue: editingTransaction?.dueDate != nil)
        _dueDate = State(initialValue: editingTransaction?.dueDate ?? Date())
    }

    private var isEditing: Bool {
        editingTransaction != nil
    }

    private var parsedAmount: Double? {
        let trimmed = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed)
    }

    private var canSave: Bool {
        parsedAmount != nil && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isEditing ? "Edit Entry" : "New Entry")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Enter amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Enter title", text: $title)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Category", selection: $category) {
                    ForEach(EntryCategory.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Type", selection: $entryType) {
                    ForEach(EntryType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Set Due Date (optional)", isOn: $hasDueDate)
                    .font(.subheadline)

                if hasDueDate {
                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
            }

            Button(action: saveEntry) {
                Text(isEditing ? "Update" : "Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(canSave ? accentBlue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(!canSave)
            .padding(.top, 4)
        }
        .padding(20)
    }

    private func saveEntry() {
        guard let amountValue = parsedAmount else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let updatedTransaction = Transaction(
            id: editingTransaction?.id ?? UUID(),
            title: trimmedTitle,
            amount: amountValue,
            date: date,
            type: entryType,
            category: category,
            isImportant: editingTransaction?.isImportant ?? false,
            dueDate: hasDueDate ? dueDate : nil,
            isBalanceSetup: editingTransaction?.isBalanceSetup ?? false
        )

        if let editingTransaction {
            reverseBalanceEffect(for: editingTransaction)
            transactionStore.updateTransaction(updatedTransaction)
            applyBalanceEffect(for: updatedTransaction, amount: amountValue)
        } else {
            transactionStore.addTransaction(
                title: trimmedTitle,
                amount: amountValue,
                date: date,
                type: entryType,
                category: category,
                dueDate: hasDueDate ? dueDate : nil
            )
            applyBalanceEffect(for: updatedTransaction, amount: amountValue)
        }

        dismiss()
    }

    private func reverseBalanceEffect(for transaction: Transaction) {
        switch transaction.type {
        case .expense:
            balanceStore.currentBalance += transaction.amount
        case .earning:
            balanceStore.currentBalance -= transaction.amount
        case .lent, .borrow:
            break
        }
    }

    private func applyBalanceEffect(for transaction: Transaction, amount: Double) {
        switch transaction.type {
        case .expense:
            balanceStore.currentBalance -= amount
        case .earning:
            balanceStore.currentBalance += amount
        case .lent, .borrow:
            break
        }
    }
}

#Preview {
    AddEntryView()
        .environment(BalanceStore())
        .environment(TransactionStore())
}
