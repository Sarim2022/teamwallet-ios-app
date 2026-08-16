//
//  AddLoanView.swift
//  Walleteam
//

import SwiftUI

private struct DraftContact: Identifiable {
    let id: UUID
    var name: String
    var amount: String

    init(id: UUID = UUID(), name: String = "", amount: String = "") {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

struct AddLoanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LoanStore.self) private var loanStore

    let editingLoan: Loan?

    @State private var loanTitle: String
    @State private var appName: String
    @State private var totalAmountText: String
    @State private var dueDate: Date
    @State private var bankName: String
    @State private var contacts: [DraftContact]
    @State private var monthlyEMI: Int
    @State private var monthlyPayAmountText: String
    @State private var paidTillNow: Int

    private let accentBlue = Color(red: 3/255, green: 94/255, blue: 168/255)
    private let emiOptions = Array(0...10)

    init(editingLoan: Loan? = nil) {
        self.editingLoan = editingLoan

        _loanTitle = State(initialValue: editingLoan?.loanTitle ?? "")
        _appName = State(initialValue: editingLoan?.appName ?? "")
        _totalAmountText = State(initialValue: editingLoan.map { String(format: "%.0f", $0.totalAmount) } ?? "")
        _dueDate = State(initialValue: editingLoan?.dueDate ?? Date())
        _bankName = State(initialValue: editingLoan?.bankName ?? "")
        _contacts = State(initialValue: {
            if let editingLoan, !editingLoan.contacts.isEmpty {
                return editingLoan.contacts.map {
                    DraftContact(
                        id: $0.id,
                        name: $0.name,
                        amount: String(format: "%.0f", $0.amount)
                    )
                }
            }
            return [DraftContact()]
        }())
        _monthlyEMI = State(initialValue: editingLoan?.monthlyEMI ?? 0)
        _monthlyPayAmountText = State(initialValue: editingLoan.map { String(format: "%.0f", $0.monthlyPayAmount) } ?? "")
        _paidTillNow = State(initialValue: editingLoan?.paidTillNow ?? 0)
    }

    private var isEditing: Bool {
        editingLoan != nil
    }

    private var parsedTotalAmount: Double? {
        Double(totalAmountText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var parsedMonthlyPayAmount: Double? {
        Double(monthlyPayAmountText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var canSave: Bool {
        !loanTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !appName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && parsedTotalAmount != nil
            && !bankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && parsedMonthlyPayAmount != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(isEditing ? "Edit Loan" : "Add Loan")
                    .font(.headline)

                loanField(title: "Loan Title", placeholder: "Enter loan title", text: $loanTitle)
                loanField(title: "App Name", placeholder: "Enter app name", text: $appName)
                loanField(title: "Total Amount", placeholder: "Enter total amount", text: $totalAmountText, keyboard: .decimalPad)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date to Paid")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }

                loanField(title: "Bank Name", placeholder: "Enter bank name", text: $bankName)

                contactsSection

                pickerField(title: "Monthly EMI", selection: $monthlyEMI, options: emiOptions)
                loanField(title: "Monthly Pay Amount", placeholder: "Enter monthly amount", text: $monthlyPayAmountText, keyboard: .decimalPad)
                pickerField(title: "Paid Till Now", selection: $paidTillNow, options: emiOptions)

                Button(action: saveLoan) {
                    Text(isEditing ? "Update" : "Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(canSave ? accentBlue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!canSave)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.visible)
        .scrollDismissesKeyboard(.interactively)
    }

    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Add Contact")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Add") {
                    contacts.append(DraftContact())
                }
                .font(.subheadline.weight(.semibold))
            }

            ForEach($contacts) { $contact in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("Contact name", text: $contact.name)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        if contacts.count > 1 {
                            Button {
                                contacts.removeAll { $0.id == contact.id }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.85))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    TextField("Contact amount", text: $contact.amount)
                        .keyboardType(.decimalPad)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    private func loanField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func pickerField(title: String, selection: Binding<Int>, options: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func saveLoan() {
        guard
            let totalAmount = parsedTotalAmount,
            let monthlyPayAmount = parsedMonthlyPayAmount
        else { return }

        let savedContacts = contacts.compactMap { draft -> LoanContact? in
            let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return nil }
            let amount = Double(draft.amount.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            return LoanContact(id: draft.id, name: name, amount: amount)
        }

        let loan = Loan(
            id: editingLoan?.id ?? UUID(),
            loanTitle: loanTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            appName: appName.trimmingCharacters(in: .whitespacesAndNewlines),
            totalAmount: totalAmount,
            dueDate: dueDate,
            bankName: bankName.trimmingCharacters(in: .whitespacesAndNewlines),
            contacts: savedContacts,
            monthlyEMI: monthlyEMI,
            monthlyPayAmount: monthlyPayAmount,
            paidTillNow: paidTillNow,
            isImportant: editingLoan?.isImportant ?? false
        )

        if isEditing {
            loanStore.updateLoan(loan)
        } else {
            loanStore.addLoan(loan)
        }

        dismiss()
    }
}

#Preview {
    AddLoanView()
        .environment(LoanStore())
}
