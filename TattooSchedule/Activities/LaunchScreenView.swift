//
//  LaunchScreenView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 6/10/2022.
//

import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject var dataController: DataController

    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            ScheduleView(dataController: dataController)
        } else {
            VStack {
                VStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    Text("Tattoo Schedule")
                        .bold()
                        .font(.system(size:26))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
