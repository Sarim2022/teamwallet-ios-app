//
//  TransactionHistoryView.swift
//  Walleteam
//

import SwiftUI

struct TransactionHistoryView: View {
    @Environment(TransactionStore.self) private var transactionStore
    @State private var editingTransaction: Transaction?

    private var history: [Transaction] {
        transactionStore.transactions(for: "History")
    }

    var body: some View {
        Group {
            if history.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your past transactions will appear here.")
                )
            } else {
                List {
                    ForEach(history) { transaction in
                        TransactionRowView(
                            transaction: transaction,
                            onEdit: { editingTransaction = transaction }
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingTransaction) { transaction in
            FitSheetContent {
                AddEntryView(editingTransaction: transaction)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionHistoryView()
            .environment(TransactionStore())
    }
}
