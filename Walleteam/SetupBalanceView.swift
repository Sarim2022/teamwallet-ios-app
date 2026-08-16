//
//  SetupBalanceView.swift
//  Walleteam
//

import SwiftUI

struct SetupBalanceView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var balanceStore: BalanceStore

    @State private var amountText = ""
    @State private var showHistorySheet = false

    private let accentBlue = Color(red: 3/255, green: 94/255, blue: 168/255)

    private var parsedAmount: Double? {
        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set Balance")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Enter balance", text: $amountText)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Button {
                if let amount = parsedAmount {
                    balanceStore.updateBalance(amount)
                }
                dismiss()
            } label: {
                Text("Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(parsedAmount == nil ? Color.gray : accentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(parsedAmount == nil)

            Button {
                showHistorySheet = true
            } label: {
                Text("Show History")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(accentBlue)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(20)
        .sheet(isPresented: $showHistorySheet) {
            NavigationStack {
                TransactionHistoryView()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if balanceStore.currentBalance > 0 {
                amountText = String(format: "%.0f", balanceStore.currentBalance)
            }
        }
    }
}

#Preview {
    SetupBalanceView(balanceStore: BalanceStore())
        .environment(TransactionStore())
}
