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
            .background(.gray.opacity(0.3))
            .cornerRadius(10)
            .shadow(radius: 20)
    }
}

extension View {
    func defaultEmptyImageViewModifier() -> some View {
        modifier(EmptyImageViewModifier())
    }
}
