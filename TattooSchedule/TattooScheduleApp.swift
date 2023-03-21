//
//  TattooScheduleApp.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import CoreData
import SwiftUI

@main
struct TattooScheduleApp: App {
    @StateObject private var dataController = DataController()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
    }

    var body: some Scene {
        WindowGroup {
            ScheduleView(dataController: dataController)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onAppear {
                    NotificationManager.instance.requestPermission()
                    NotificationManager.instance.removeDelivered()
                    #if DEBUG
                    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                    #endif
                }
        }
    }
}
