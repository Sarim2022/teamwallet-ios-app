//
//  WalleteamApp.swift
//  Walleteam
//
//  Created by Sarim on 16/08/26.
//

import SwiftUI

@main
struct WalleteamApp: App {
    @State private var balanceStore = BalanceStore()
    @State private var transactionStore = TransactionStore()
    @State private var loanStore = LoanStore()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(balanceStore)
                .environment(transactionStore)
                .environment(loanStore)
        }
    }
}
