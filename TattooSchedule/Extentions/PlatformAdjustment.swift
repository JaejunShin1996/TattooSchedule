//
//  PlatformAdjustment.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 20/3/2023.
//

import SwiftUI
import Foundation

struct StackNavigationView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationView(content: content)
            .navigationViewStyle(.stack)
    }
}

extension Section where Parent: View, Content: View, Footer: View {
    func disableCollapsing() -> some View {
        self
    }
}
