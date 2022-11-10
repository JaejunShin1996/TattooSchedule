//
//  LongPressButton.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 8/11/2022.
//

import SwiftUI

struct LongPressButton: View {
    @State private var isComplete = false
    @State private var isSuccesse = false

    var saveAction: () -> Void

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(isSuccesse ? .green : .blue)
                .frame(maxWidth: isComplete ? UIScreen.main.bounds.width - 20 : 0)
                .frame(height: 22)
                .frame(maxWidth: UIScreen.main.bounds.width - 20, alignment: .leading)
                .background(.gray)
                .cornerRadius(10.0)

            Button {
                saveAction()
            } label: {
                Text("Save")
                    .foregroundColor(.white)
                    .padding()
                    .background(.black)
                    .frame(height: 44)
                    .cornerRadius(10.0)
                    .onLongPressGesture(minimumDuration: 2.0, maximumDistance: 50) { (isPressing) in
                        if isPressing {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                isComplete.toggle()
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if !isSuccesse {
                                    isComplete = false
                                }
                            }
                        }
                    } perform: {
                        withAnimation(.easeInOut) {
                            isSuccesse.toggle()
                        }
                    }
            }
        }
    }
}

struct LongPressButton_Previews: PreviewProvider {
    static let longPressed = {}
    static var previews: some View {
        LongPressButton(saveAction: longPressed)
    }
}
