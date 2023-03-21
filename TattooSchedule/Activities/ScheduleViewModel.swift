//
//  ScheduleViewModel.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 4/10/2022.
//

import CoreData
import Collections
import Foundation
import SwiftUI

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

    // schedules for each views.
    func todaySchedules() -> [Schedule] {
        var todaySchedules = [Schedule]()

        for schedule in schedules {
            if Calendar.current.isDateInToday(schedule.scheduleDate) {
                todaySchedules.append(schedule)
            }
        }

        return todaySchedules
    }

    func upcomingSchedules() -> ScheduleGroup {
        var upcomingSchedules = [Schedule]()

        for schedule in schedules {
            if !schedule.scheduleDate.isInToday && schedule.scheduleDate.isInTheFuture {
                upcomingSchedules.append(schedule)
            }
        }
        guard !upcomingSchedules.isEmpty else { return [:] }
        
        return ScheduleGroup(grouping: upcomingSchedules.sorted { $0.scheduleDate < $1.scheduleDate }) { $0.week }
    }

    func pastSchedules() -> ScheduleGroup {
        var pastSchedules = [Schedule]()

        for schedule in schedules {
            if !schedule.scheduleDate.isInToday && schedule.scheduleDate.isInThePast {
                pastSchedules.append(schedule)

                NotificationManager.instance.cancelNotification(notificationId: schedule.scheduleStringID)
            }
        }
        guard !pastSchedules.isEmpty else { return [:] }
        
        return ScheduleGroup(grouping: pastSchedules.sorted { $0.scheduleDate > $1.scheduleDate }) { $0.month }
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

    func reload() {
        DispatchQueue.main.async {
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

        if !lastChecked.isInToday {
            reload()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let newSchedules = controller.fetchedObjects as? [Schedule] {
            schedules = newSchedules
        }
    }
}
