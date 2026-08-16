//
//  Loan.swift
//  Walleteam
//

import Foundation

struct LoanContact: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var amount: Double

    init(id: UUID = UUID(), name: String, amount: Double) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

struct Loan: Identifiable, Codable, Hashable {
    let id: UUID
    var loanTitle: String
    var appName: String
    var totalAmount: Double
    var dueDate: Date
    var bankName: String
    var contacts: [LoanContact]
    var monthlyEMI: Int
    var monthlyPayAmount: Double
    var paidTillNow: Int
    var isImportant: Bool

    init(
        id: UUID = UUID(),
        loanTitle: String,
        appName: String,
        totalAmount: Double,
        dueDate: Date,
        bankName: String,
        contacts: [LoanContact] = [],
        monthlyEMI: Int = 0,
        monthlyPayAmount: Double,
        paidTillNow: Int = 0,
        isImportant: Bool = false
    ) {
        self.id = id
        self.loanTitle = loanTitle
        self.appName = appName
        self.totalAmount = totalAmount
        self.dueDate = dueDate
        self.bankName = bankName
        self.contacts = contacts
        self.monthlyEMI = monthlyEMI
        self.monthlyPayAmount = monthlyPayAmount
        self.paidTillNow = paidTillNow
        self.isImportant = isImportant
    }

    enum CodingKeys: String, CodingKey {
        case id, loanTitle, appName, totalAmount, dueDate, bankName, contact, contacts
        case monthlyEMI, monthlyPayAmount, paidTillNow, isImportant
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        loanTitle = try container.decode(String.self, forKey: .loanTitle)
        appName = try container.decode(String.self, forKey: .appName)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        bankName = try container.decode(String.self, forKey: .bankName)
        monthlyEMI = try container.decode(Int.self, forKey: .monthlyEMI)
        monthlyPayAmount = try container.decode(Double.self, forKey: .monthlyPayAmount)
        paidTillNow = try container.decode(Int.self, forKey: .paidTillNow)
        isImportant = try container.decodeIfPresent(Bool.self, forKey: .isImportant) ?? false

        if let decodedContacts = try container.decodeIfPresent([LoanContact].self, forKey: .contacts) {
            contacts = decodedContacts
        } else if let legacyContact = try container.decodeIfPresent(String.self, forKey: .contact),
                  !legacyContact.isEmpty {
            contacts = [LoanContact(name: legacyContact, amount: 0)]
        } else {
            contacts = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(loanTitle, forKey: .loanTitle)
        try container.encode(appName, forKey: .appName)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(bankName, forKey: .bankName)
        try container.encode(contacts, forKey: .contacts)
        try container.encode(monthlyEMI, forKey: .monthlyEMI)
        try container.encode(monthlyPayAmount, forKey: .monthlyPayAmount)
        try container.encode(paidTillNow, forKey: .paidTillNow)
        try container.encode(isImportant, forKey: .isImportant)
    }
}
