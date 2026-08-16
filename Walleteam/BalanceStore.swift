//
//  BalanceStore.swift
//  Walleteam
//

import Foundation
import Observation

@Observable
final class BalanceStore {
    private enum Keys {
        static let currentBalance = "currentBalance"
    }

    var currentBalance: Double {
        didSet {
            UserDefaults.standard.set(currentBalance, forKey: Keys.currentBalance)
        }
    }

    init() {
        currentBalance = UserDefaults.standard.double(forKey: Keys.currentBalance)
    }

    func updateBalance(_ amount: Double) {
        currentBalance = max(0, amount)
    }
}

enum AppLaunchStorage {
    private static let hasLaunchedBeforeKey = "hasLaunchedBefore"

    static var hasLaunchedBefore: Bool {
        UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)
    }

    static func markLaunched() {
        UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
    }
}

enum HomeLayoutStorage {
    static let layoutKey = "layout"

    enum Layout: String {
        case grid
        case list
    }

    static var layout: Layout {
        get {
            let raw = UserDefaults.standard.string(forKey: layoutKey) ?? Layout.grid.rawValue
            return Layout(rawValue: raw) ?? .grid
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: layoutKey)
        }
    }
}

enum HomeCardVisibilityStorage {
    static let hiddenCardsKey = "hiddenHomeCards"

    static let allCardTitles = [
        "Today",
        "Earning",
        "Expense",
        "Due Date",
        "My Loan",
        "Important",
        "My Lent",
        "My Borrow"
    ]

    static var hiddenCards: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: hiddenCardsKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: hiddenCardsKey)
        }
    }

    static func isVisible(_ title: String) -> Bool {
        !hiddenCards.contains(title)
    }

    static func setVisible(_ title: String, visible: Bool) {
        var hidden = hiddenCards
        if visible {
            hidden.remove(title)
        } else {
            hidden.insert(title)
        }
        hiddenCards = hidden
    }
}
