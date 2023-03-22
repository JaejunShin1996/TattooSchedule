//
//  DateAndTimeView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 15/11/2022.
//

import SwiftUI

struct DateAndTimeView: View {
    var isEditing = true
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
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 30
                    }
                    .padding([.horizontal, .vertical])
            }
            .tint(
                colorScheme == .light ?
                  isEditing ? .blue : .primary
                : isEditing ? .blue : .secondary
            )
            .background(.thinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .padding(.top)
    }
}

struct DateAndTimeView_Previews: PreviewProvider {
    static var previews: some View {
        DateAndTimeView(colorScheme: .dark, date: .constant(.now))
    }
}
