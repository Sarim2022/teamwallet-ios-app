//
//  LoanDetailView.swift
//  Walleteam
//

import SwiftUI

struct LoanDetailView: View {
    let loanId: UUID

    @Environment(\.dismiss) private var dismiss
    @Environment(LoanStore.self) private var loanStore
    @State private var showEditSheet = false

    private let accentBlue = Color(red: 3/255, green: 94/255, blue: 168/255)

    private var loan: Loan? {
        loanStore.loan(with: loanId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text(loan?.loanTitle ?? "Loan Details")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if loan != nil {
                    Button("Edit") {
                        showEditSheet = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accentBlue)
                }

                if let loan {
                    Button {
                        loanStore.toggleImportant(loanId: loan.id)
                    } label: {
                        Image(systemName: loan.isImportant ? "star.fill" : "star")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(loan.isImportant ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color(.tertiaryLabel))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            if let loan {
                ScrollView {
                    VStack(spacing: 0) {
                        detailRow(title: "Loan Title", value: loan.loanTitle)
                        Divider().padding(.leading, 16)
                        detailRow(title: "App Name", value: loan.appName)
                        Divider().padding(.leading, 16)
                        detailRow(title: "Total Amount", value: loan.totalAmount.formatted(.currency(code: "INR").precision(.fractionLength(0))))
                        Divider().padding(.leading, 16)
                        detailRow(title: "Due Date to Paid", value: loan.dueDate.formatted(date: .abbreviated, time: .omitted))
                        Divider().padding(.leading, 16)
                        detailRow(title: "Bank Name", value: loan.bankName)
                        Divider().padding(.leading, 16)

                        if loan.contacts.isEmpty {
                            detailRow(title: "Contacts", value: "—")
                            Divider().padding(.leading, 16)
                        } else {
                            ForEach(Array(loan.contacts.enumerated()), id: \.element.id) { index, contact in
                                detailRow(
                                    title: "Contact \(index + 1)",
                                    value: "\(contact.name) · \(contact.amount.formatted(.currency(code: "INR").precision(.fractionLength(0))))"
                                )
                                Divider().padding(.leading, 16)
                            }
                        }

                        detailRow(title: "Monthly EMI", value: "\(loan.monthlyEMI)")
                        Divider().padding(.leading, 16)
                        detailRow(title: "Monthly Pay Amount", value: loan.monthlyPayAmount.formatted(.currency(code: "INR").precision(.fractionLength(0))))
                        Divider().padding(.leading, 16)
                        detailRow(title: "Paid Till Now", value: "\(loan.paidTillNow)")
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 16)
                }
            } else {
                Text("Loan not found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            if let loan {
                AddLoanView(editingLoan: loan)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        LoanDetailView(loanId: UUID())
            .environment(LoanStore())
    }
}
