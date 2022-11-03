//
//  ScheduleViewModel.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 4/10/2022.
//

import CoreData
import Foundation
import SwiftUI
import Collections

typealias ScheduleGroup = OrderedDictionary<String, [Schedule]>

class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    let dataController: DataController

    private let schedulesController: NSFetchedResultsController<Schedule>

    @AppStorage("lastChecked") private var lastChecked = Date.now.timeIntervalSinceReferenceDate

    @Published var schedules = [Schedule]()

    @Published var showingNotificationsError = false
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

            if scheduleDate >= tomorrow || Calendar.current.isDateInTomorrow(scheduleDate) {
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

            if (scheduleDate <= yesterday) || Calendar.current.isDateInYesterday(scheduleDate) {
                pastSchedules.append(schedule)
            }
        }

        return pastSchedules.sorted { $0.scheduleDate > $1.scheduleDate }
    }

    // Sorts images in the nssset of coredata
    func sortedImages(_ schedule: Schedule) -> [Photo] {
        schedule.schedulePhotos.sorted { $0.photoCreationTime < $1.photoCreationTime }
    }

    // Schedules for Search View
    func filteredSchedules(searchString: String) -> [Schedule] {
        var filtered = [Schedule]()

        for schedule in schedules where schedule.scheduleName.contains(searchString) {
            filtered.append(schedule)
        }

        return filtered
    }

    // Groups schedules by month.
    func groupSchedulesByMonth() -> ScheduleGroup {
        guard !schedules.isEmpty else { return [:] }

        let groupedSchedules = ScheduleGroup(grouping: pastSchedules()) { $0.month }

        return groupedSchedules
    }

    func reload() {
        DispatchQueue.global(qos: .background).async {
            do {
                try self.schedulesController.performFetch()

                DispatchQueue.main.async {
                    self.schedules = self.schedulesController.fetchedObjects ?? []
                }
            } catch {
                print("debug: Failed to load coredata")
            }
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
