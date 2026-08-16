//
//  LoanStore.swift
//  Walleteam
//

import Foundation
import Observation

@Observable
final class LoanStore {
    private enum Keys {
        static let loans = "loans"
    }

    var loans: [Loan] = [] {
        didSet {
            save()
        }
    }

    init() {
        load()
    }

    func addLoan(_ loan: Loan) {
        loans.insert(loan, at: 0)
    }

    func updateLoan(_ loan: Loan) {
        guard let index = loans.firstIndex(where: { $0.id == loan.id }) else { return }
        loans[index] = loan
    }

    func loan(with id: UUID) -> Loan? {
        loans.first { $0.id == id }
    }

    func toggleImportant(loanId: UUID) {
        guard let index = loans.firstIndex(where: { $0.id == loanId }) else { return }
        loans[index].isImportant.toggle()
    }

    var importantLoans: [Loan] {
        loans.filter(\.isImportant)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(loans) else { return }
        UserDefaults.standard.set(data, forKey: Keys.loans)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.loans),
            let decoded = try? JSONDecoder().decode([Loan].self, from: data)
        else {
            loans = []
            return
        }
        loans = decoded
    }
}
