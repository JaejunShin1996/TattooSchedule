//
//  EmptyImageTextViewModifier.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 24/11/2022.
//

import Foundation
import SwiftUI

struct EmptyImageViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .italic()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.thinMaterial)
            .cornerRadius(10)
            .shadow(radius: 10)
    }
}

extension View {
    func defaultEmptyImageViewModifier() -> some View {
        modifier(EmptyImageViewModifier())
    }
}
