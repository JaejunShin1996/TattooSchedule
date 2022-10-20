//
//  KeyDismissExtension.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 20/10/2022.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
