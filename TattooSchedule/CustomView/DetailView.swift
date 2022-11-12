//
//  DetailView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 12/11/2022.
//

import SwiftUI

struct DetailView: View {
    @State private var date = Date.now
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    ZStack {
                        Color.gray.opacity(0.5)

                        DatePicker("Date", selection: $date)
                            .datePickerStyle(.graphical)
                            .colorMultiply(.red)
                            .allowsHitTesting(false)
                    }
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(.horizontal)

                    
                }
            }
            .navigationTitle("Jay")
            .toolbar {
                ToolbarItem {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
