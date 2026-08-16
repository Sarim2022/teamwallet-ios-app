//
//  ContentView.swift
//  Walleteam
//
//  Created by Sarim on 16/08/26.
//

import SwiftUI

struct SplashView: View {
    @State private var goHome = AppLaunchStorage.hasLaunchedBefore

    var body: some View {
        Group {
            if goHome {
                HomeView()
                    .transition(.opacity)
            } else {
                ZStack {
                    Color(red: 3/255, green: 94/255, blue: 168/255)
                        .ignoresSafeArea()

                    Text("Walleteam")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                        AppLaunchStorage.markLaunched()
                        withAnimation { goHome = true }
                    }
                }
            }
        }
    }
}


#Preview {
    SplashView()
        .environment(BalanceStore())
        .environment(TransactionStore())
        .environment(LoanStore())
}
