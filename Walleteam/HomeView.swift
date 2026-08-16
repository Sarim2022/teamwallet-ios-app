//
//  HomeView.swift
//  Walleteam
//

import SwiftUI

struct ReminderSmartList: Identifiable {
    let id = UUID()
    let title: String
    let count: Int?
    let amount: Double?
    let icon: String
    let gradient: [Color]
    var showsDayNumber = false
}

struct HomeView: View {
    @Environment(BalanceStore.self) private var balanceStore
    @Environment(TransactionStore.self) private var transactionStore
    @Environment(LoanStore.self) private var loanStore
    @AppStorage(HomeLayoutStorage.layoutKey) private var layout = HomeLayoutStorage.Layout.grid.rawValue
    @State private var hiddenCards = HomeCardVisibilityStorage.hiddenCards
    @State private var showAddSheet = false
    @State private var showSetupSheet = false
    @State private var showHideCardsSheet = false

    private var isListLayout: Bool {
        layout == HomeLayoutStorage.Layout.list.rawValue
    }

    private let accentBlue = Color(red: 3/255, green: 94/255, blue: 168/255)
    private let balanceCardGradient = [
        Color(red: 3/255, green: 94/255, blue: 168/255),
        Color(red: 0.12, green: 0.52, blue: 0.92),
        Color(red: 0.35, green: 0.72, blue: 1.0)
    ]
    private var totalLent: Double {
        transactionStore.totalLentAmount
    }

    private var totalBorrowed: Double {
        transactionStore.totalBorrowedAmount
    }

    private var importantCount: Int {
        transactionStore.importantTransactions.count + loanStore.importantLoans.count
    }

    private var smartLists: [ReminderSmartList] {
        [
            ReminderSmartList(
                title: "Today",
                count: transactionStore.count(for: "Today"),
                amount: nil,
                icon: "calendar",
                gradient: [Color(red: 0.0, green: 0.65, blue: 0.62), Color(red: 0.0, green: 0.52, blue: 0.55)],
                showsDayNumber: true
            ),
            ReminderSmartList(
                title: "Earning",
                count: transactionStore.count(for: "Earning"),
                amount: nil,
                icon: "arrow.up.circle",
                gradient: [Color(red: 1.0, green: 0.27, blue: 0.23), Color(red: 0.95, green: 0.2, blue: 0.25)]
            ),
            ReminderSmartList(
                title: "Expense",
                count: transactionStore.count(for: "Expense"),
                amount: nil,
                icon: "arrow.down.circle",
                gradient: [Color(red: 0.28, green: 0.28, blue: 0.3), Color(red: 0.18, green: 0.18, blue: 0.2)]
            ),
            ReminderSmartList(
                title: "Due Date",
                count: transactionStore.count(for: "Due Date"),
                amount: nil,
                icon: "calendar.badge.clock",
                gradient: [Color(red: 1.0, green: 0.58, blue: 0.0), Color(red: 0.95, green: 0.45, blue: 0.0)]
            ),
            ReminderSmartList(
                title: "My Loan",
                count: loanStore.loans.count,
                amount: nil,
                icon: "arrow.up.right.circle",
                gradient: [Color(red: 0.68, green: 0.68, blue: 0.7), Color(red: 0.58, green: 0.58, blue: 0.6)]
            ),
            ReminderSmartList(
                title: "Important",
                count: importantCount,
                amount: nil,
                icon: "star.fill",
                gradient: [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 0.95, green: 0.72, blue: 0.0)]
            ),
            ReminderSmartList(
                title: "My Lent",
                count: transactionStore.count(for: "My Lent"),
                amount: nil,
                icon: "arrow.up.right.circle",
                gradient: [Color(red: 0.45, green: 0.28, blue: 0.78), Color(red: 0.35, green: 0.2, blue: 0.68)]
            ),
            ReminderSmartList(
                title: "My Borrow",
                count: transactionStore.count(for: "My Borrow"),
                amount: nil,
                icon: "arrow.down.left.circle",
                gradient: [Color(red: 0.0, green: 0.55, blue: 0.68), Color(red: 0.0, green: 0.42, blue: 0.58)]
            ),
        ]
    }

    private var visibleSmartLists: [ReminderSmartList] {
        smartLists.filter { !hiddenCards.contains($0.title) }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            homeContent
                .navigationDestination(for: String.self) { title in
                    if title == "My Loan" {
                        MyLoanListView()
                    } else if title == "Important" {
                        ImportantListView()
                    } else {
                        CardDetailView(title: title)
                    }
                }
                .navigationDestination(for: UUID.self) { loanId in
                    LoanDetailView(loanId: loanId)
                }
        }
    }

    private var homeContent: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Date(), format: .dateTime.month(.wide).year())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(Date(), format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                        }

                        Spacer(minLength: 8)

                        Menu {
                            if isListLayout {
                                Button("Change to grid") {
                                    layout = HomeLayoutStorage.Layout.grid.rawValue
                                }
                            } else {
                                Button("Change to list") {
                                    layout = HomeLayoutStorage.Layout.list.rawValue
                                }
                            }

                            Button("Hide card") {
                                showHideCardsSheet = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(accentBlue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    CurrentBalanceCard(
                        balance: balanceStore.currentBalance,
                        totalLent: totalLent,
                        totalBorrowed: totalBorrowed,
                        monthlyNet: transactionStore.monthlyLentBorrowNet,
                        gradient: balanceCardGradient,
                        onSetup: { showSetupSheet = true }
                    )

                    if visibleSmartLists.isEmpty {
                        Text("No cards visible")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    } else if isListLayout {
                        categoryListSection
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(visibleSmartLists) { list in
                                NavigationLink(value: list.title) {
                                    ReminderCategoryCard(list: list)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(accentBlue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .padding(20)
        }
        .sheet(isPresented: $showAddSheet) {
            FitSheetContent {
                AddEntryView()
            }
        }
        .sheet(isPresented: $showSetupSheet) {
            FitSheetContent {
                SetupBalanceView(balanceStore: balanceStore)
            }
        }
        .sheet(isPresented: $showHideCardsSheet) {
            HideCardsSheet(hiddenCards: $hiddenCards)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var categoryListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Lists")
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(visibleSmartLists.enumerated()), id: \.element.id) { index, list in
                    NavigationLink(value: list.title) {
                        ReminderCategoryListRow(list: list)
                    }
                    .buttonStyle(.plain)

                    if index < visibleSmartLists.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct HideCardsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hiddenCards: Set<String>

    var body: some View {
        NavigationStack {
            List {
                ForEach(HomeCardVisibilityStorage.allCardTitles, id: \.self) { title in
                    Toggle(isOn: visibilityBinding(for: title)) {
                        Text(title)
                            .font(.body)
                    }
                }
            }
            .navigationTitle("Show Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func visibilityBinding(for title: String) -> Binding<Bool> {
        Binding(
            get: { !hiddenCards.contains(title) },
            set: { isVisible in
                if isVisible {
                    hiddenCards.remove(title)
                } else {
                    hiddenCards.insert(title)
                }
                HomeCardVisibilityStorage.hiddenCards = hiddenCards
            }
        )
    }
}

struct CurrentBalanceCard: View {
    let balance: Double
    let totalLent: Double
    let totalBorrowed: Double
    let monthlyNet: Double
    let gradient: [Color]
    let onSetup: () -> Void

    private var profitLossText: String? {
        guard monthlyNet != 0 else { return nil }
        let amount = abs(monthlyNet)
        let formatted = amount.formatted(.currency(code: "INR").precision(.fractionLength(0)))
        return monthlyNet > 0 ? "Profit \(formatted)" : "Loss \(formatted)"
    }

    private var profitLossColor: Color {
        monthlyNet > 0 ? Color(red: 0.35, green: 0.95, blue: 0.45) : Color(red: 1.0, green: 0.35, blue: 0.35)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(balance, format: .currency(code: "INR").precision(.fractionLength(0)))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)

                        if let profitLossText {
                            Text(profitLossText)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(profitLossColor)
                        }
                    }
                }

                Spacer(minLength: 8)

                Button(action: onSetup) {
                    Text("Set up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 3/255, green: 94/255, blue: 168/255))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }

            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(height: 1)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lent")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(totalLent, format: .currency(code: "INR").precision(.fractionLength(0)))
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Borrowed")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(totalBorrowed, format: .currency(code: "INR").precision(.fractionLength(0)))
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct ReminderCategoryCard: View {
    let list: ReminderSmartList

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: list.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    cardIcon
                    Spacer(minLength: 0)
                    if let amount = list.amount {
                        Text(amount, format: .currency(code: "INR").precision(.fractionLength(0)))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    } else if let count = list.count {
                        Text("\(count)")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                Text(list.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(14)
        }
        .frame(height: 88)
    }

    @ViewBuilder
    private var cardIcon: some View {
        if list.showsDayNumber {
            ZStack {
                Image(systemName: list.icon)
                    .font(.system(size: 22, weight: .medium))
                Text("\(Calendar.current.component(.day, from: Date()))")
                    .font(.system(size: 9, weight: .bold))
                    .offset(y: 3)
            }
            .foregroundStyle(.white)
        } else {
            Image(systemName: list.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

struct ReminderCategoryListRow: View {
    let list: ReminderSmartList

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(list.gradient[0])
                    .frame(width: 36, height: 36)

                listIcon
            }

            Text(list.title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer(minLength: 8)

            if let count = list.count {
                Text("\(count)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var listIcon: some View {
        if list.showsDayNumber {
            ZStack {
                Image(systemName: list.icon)
                    .font(.system(size: 16, weight: .semibold))
                Text("\(Calendar.current.component(.day, from: Date()))")
                    .font(.system(size: 8, weight: .bold))
                    .offset(y: 3)
            }
            .foregroundStyle(.white)
        } else {
            Image(systemName: list.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    HomeView()
        .environment(BalanceStore())
        .environment(TransactionStore())
        .environment(LoanStore())
}
