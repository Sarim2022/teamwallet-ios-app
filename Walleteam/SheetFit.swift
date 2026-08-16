//
//  SheetFit.swift
//  Walleteam
//

import SwiftUI

struct FitSheetContent<Content: View>: View {
    @ViewBuilder let content: () -> Content
    @State private var height: CGFloat = 0

    var body: some View {
        content()
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .top)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                guard newHeight > 0 else { return }
                height = newHeight
            }
            .presentationDetents(height > 0 ? [.height(height)] : [.fraction(0.3)])
            .presentationDragIndicator(.visible)
    }
}
