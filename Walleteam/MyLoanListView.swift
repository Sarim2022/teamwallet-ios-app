//
//  MyLoanListView.swift
//  Walleteam
//

import SwiftUI

struct MyLoanListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LoanStore.self) private var loanStore
    @State private var showAddLoanSheet = false

    private let accentBlue = Color(red: 3/255, green: 94/255, blue: 168/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text("My Loan")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                Button {
                    showAddLoanSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(accentBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            if loanStore.loans.isEmpty {
                Text("No loans yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(loanStore.loans) { loan in
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
        .sheet(isPresented: $showAddLoanSheet) {
            AddLoanView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct LoanRowView: View {
    @Environment(LoanStore.self) private var loanStore
    let loan: Loan

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.68, green: 0.68, blue: 0.7))
                    .frame(width: 36, height: 36)

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(loan.loanTitle)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("My Loan · \(loan.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(loan.totalAmount, format: .currency(code: "INR").precision(.fractionLength(0)))
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                loanStore.toggleImportant(loanId: loan.id)
            } label: {
                Image(systemName: loan.isImportant ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(loan.isImportant ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        MyLoanListView()
            .environment(LoanStore())
    }
}
