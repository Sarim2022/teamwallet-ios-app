//
//  CardDetailView.swift
//  Walleteam
//

import SwiftUI

struct CardDetailView: View {
    let title: String

    @Environment(\.dismiss) private var dismiss
    @Environment(TransactionStore.self) private var transactionStore
    @State private var editingTransaction: Transaction?

    private var filteredTransactions: [Transaction] {
        transactionStore.transactions(for: title)
    }

    private var allowsSwipeDelete: Bool {
        title == "My Lent" || title == "My Borrow"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            if filteredTransactions.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                Spacer()
            } else {
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(
                            transaction: transaction,
                            preferDueDate: title == "Due Date",
                            onEdit: { editingTransaction = transaction }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if allowsSwipeDelete {
                                Button(role: .destructive) {
                                    transactionStore.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $editingTransaction) { transaction in
            FitSheetContent {
                AddEntryView(editingTransaction: transaction)
            }
        }
    }

    private var emptyMessage: String {
        switch title {
        case "Due Date": "No due dates yet"
        case "Today": "Nothing done today"
        default: "No transactions yet"
        }
    }
}

struct TransactionRowView: View {
    @Environment(TransactionStore.self) private var transactionStore
    let transaction: Transaction
    var showsChevron: Bool = true
    var preferDueDate: Bool = false
    var onEdit: (() -> Void)? = nil

    private var amountColor: Color {
        transaction.type == .earning ? Color(red: 0.15, green: 0.55, blue: 0.35) : .secondary
    }

    private var formattedAmount: String {
        let value = transaction.amount.formatted(.currency(code: "INR").precision(.fractionLength(0)))
        return transaction.type == .earning ? "+\(value)" : value
    }

    private var subtitleDate: Date {
        if preferDueDate, let dueDate = transaction.dueDate {
            return dueDate
        }
        return transaction.date
    }

    private var subtitlePrefix: String {
        preferDueDate && transaction.dueDate != nil ? "Due " : ""
    }

    private var subtitleText: String {
        let dateText = "\(subtitlePrefix)\(subtitleDate.formatted(date: .abbreviated, time: .omitted))"
        if let category = transaction.category {
            return "\(category.rawValue) · \(dateText)"
        }
        return dateText
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        Color(
                            red: transaction.accentColor.red,
                            green: transaction.accentColor.green,
                            blue: transaction.accentColor.blue
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: transaction.type.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitleText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(formattedAmount)
                .font(.body)
                .foregroundStyle(amountColor)

            Button {
                transactionStore.toggleImportant(transactionId: transaction.id)
            } label: {
                Image(systemName: transaction.isImportant ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(transaction.isImportant ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit?()
        }
    }
}

#Preview {
    NavigationStack {
        CardDetailView(title: "Expense")
            .environment(TransactionStore())
    }
}
