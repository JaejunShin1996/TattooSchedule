//
//  ScheduleViewModel.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 4/10/2022.
//

import CoreData
import Foundation
import SwiftUI

extension ScheduleView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController

        private let schedulesController: NSFetchedResultsController<Schedule>

        @AppStorage("lastChecked") private var lastChecked = Date.now.timeIntervalSinceReferenceDate

        @Published var schedules = [Schedule]()

        @Published var showingAddSchedule = false
        @Published var showingNotificationsError = false

        init(dataController: DataController) {
            self.dataController = dataController

            let request: NSFetchRequest<Schedule> = Schedule.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Schedule.date, ascending: true)]

            schedulesController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            schedulesController.delegate = self

            do {
                try schedulesController.performFetch()
                schedules = schedulesController.fetchedObjects ?? []
            } catch {
                print("debug: Failed to load coredata")
            }
        }

        func reload() {
            do {
                try schedulesController.performFetch()
                schedules = schedulesController.fetchedObjects ?? []
            } catch {
                print("debug: Failed to load coredata")
            }
        }

        func checkForReload() {
            let lastChecked = Date(timeIntervalSinceReferenceDate: lastChecked)

            if Calendar.current.isDateInToday(lastChecked) == false {
                reload()
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newSchedules = controller.fetchedObjects as? [Schedule] {
                schedules = newSchedules
            }
        }
    }
}
