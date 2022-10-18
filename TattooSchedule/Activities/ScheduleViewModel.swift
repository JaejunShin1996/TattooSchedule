//
//  ScheduleViewModel.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 4/10/2022.
//

import CoreData
import Foundation
import SwiftUI

class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    let dataController: DataController

    private let schedulesController: NSFetchedResultsController<Schedule>

    @AppStorage("lastChecked") private var lastChecked = Date.now.timeIntervalSinceReferenceDate

    @Published var schedules = [Schedule]()

    @Published var showingAddSchedule = false
    @Published var showingNotificationsError = false
    @Published var showingSearchView = false
    @Published var showingPastSchedule = false

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

    // Divide Sections for the main view
    func todaySchedules() -> [Schedule] {
        var todaySchedules = [Schedule]()

        for schedule in schedules {
            let scheduleDate = schedule.scheduleDate

            if Calendar.current.isDateInToday(scheduleDate) {
                todaySchedules.append(schedule)
            }
        }

        return todaySchedules
    }

    func upcomingSchedules() -> [Schedule] {
        var upcomingSchedules = [Schedule]()

        let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!

        for schedule in schedules {
            let scheduleDate = schedule.scheduleDate

            if scheduleDate >= tomorrow {
                upcomingSchedules.append(schedule)
            }
        }

        return upcomingSchedules
    }

    func pastSchedules() -> [Schedule] {
        var pastSchedules = [Schedule]()

        let yesterday = Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!

        for schedule in schedules {
            let scheduleDate = schedule.scheduleDate

            if (scheduleDate <= yesterday) {
                pastSchedules.append(schedule)
            }
        }

        return pastSchedules
    }

    // Schedules for Search View
    func filteredSchedules(searchString: String) -> [Schedule] {
        var filtered = [Schedule]()

        for schedule in schedules {
            if schedule.scheduleName.contains(searchString) {
                filtered.append(schedule)
            }
        }

        return filtered
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
