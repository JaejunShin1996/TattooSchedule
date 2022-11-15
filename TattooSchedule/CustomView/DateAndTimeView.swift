//
//  DateAndTimeView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 15/11/2022.
//

import SwiftUI

struct DateAndTimeView: View {
    var isEditing = false
    var colorScheme: ColorScheme
    @Binding var date: Date

    var body: some View {
        VStack {
            Text("Date & Time")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                DatePicker("Date", selection: $date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 30
                    }
            }
            .tint(
                colorScheme == .light ?
                  isEditing ? .blue : .primary
                : isEditing ? .blue : .secondary
            )
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .padding(.top)
    }
}
