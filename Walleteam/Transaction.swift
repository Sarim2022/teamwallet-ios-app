//
//  Transaction.swift
//  Walleteam
//

import Foundation

enum EntryType: String, CaseIterable, Identifiable, Codable {
    case lent = "Lent"
    case borrow = "Borrow"
    case expense = "Expense"
    case earning = "Earning"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .lent: "arrow.up.right.circle.fill"
        case .borrow: "arrow.down.left.circle.fill"
        case .expense: "arrow.down.circle.fill"
        case .earning: "arrow.up.circle.fill"
        }
    }
}

enum EntryCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Food"
    case travel = "Travel"
    case drive = "Drive"
    case gift = "Gift"
    case other = "Other"

    var id: String { rawValue }
}

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var type: EntryType
    var category: EntryCategory?
    var isImportant: Bool
    var dueDate: Date?
    var isBalanceSetup: Bool

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date,
        type: EntryType,
        category: EntryCategory? = nil,
        isImportant: Bool = false,
        dueDate: Date? = nil,
        isBalanceSetup: Bool = false
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
        self.isImportant = isImportant
        self.dueDate = dueDate
        self.isBalanceSetup = isBalanceSetup
    }

    enum CodingKeys: String, CodingKey {
        case id, title, amount, date, type, category, isImportant, dueDate, isBalanceSetup
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        type = try container.decode(EntryType.self, forKey: .type)
        category = try container.decodeIfPresent(EntryCategory.self, forKey: .category)
        isImportant = try container.decodeIfPresent(Bool.self, forKey: .isImportant) ?? false
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        isBalanceSetup = try container.decodeIfPresent(Bool.self, forKey: .isBalanceSetup) ?? false
    }
}
