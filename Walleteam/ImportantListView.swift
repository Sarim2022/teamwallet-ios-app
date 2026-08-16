//
//  ImportantListView.swift
//  Walleteam
//

import SwiftUI

struct ImportantListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TransactionStore.self) private var transactionStore
    @Environment(LoanStore.self) private var loanStore
    @State private var editingTransaction: Transaction?

    private var hasItems: Bool {
        !transactionStore.importantTransactions.isEmpty || !loanStore.importantLoans.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text("Important")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            if !hasItems {
                Text("No important items yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        if !transactionStore.importantTransactions.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(transactionStore.importantTransactions.enumerated()), id: \.element.id) { index, transaction in
                                    TransactionRowView(
                                        transaction: transaction,
                                        onEdit: { editingTransaction = transaction }
                                    )

                                    if index < transactionStore.importantTransactions.count - 1 {
                                        Divider().padding(.leading, 62)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        ForEach(loanStore.importantLoans) { loan in
                            NavigationLink(value: loan.id) {
                                LoanRowView(loan: loan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
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
}

#Preview {
    NavigationStack {
        ImportantListView()
            .environment(TransactionStore())
            .environment(LoanStore())
    }
}
