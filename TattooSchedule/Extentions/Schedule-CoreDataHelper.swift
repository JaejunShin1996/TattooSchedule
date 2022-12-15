//
//  Schedule-CoreDataHelper.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 26/9/2022.
//

import ClockKit
import Foundation

extension Schedule {
    var scheduleStringID: String {
        id?.uuidString ?? UUID().uuidString
    }

    var scheduleName: String {
        name ?? "John Doe"
    }

    var scheduleDate: Date {
        date ?? Date.now
    }

    var scheduleDesign: String {
        design ?? "Nothing"
    }

    var schedulePrice: String {
        price ?? "100"
    }

    var schedulePhotos: [Photo] {
        photos?.allObjects as? [Photo] ?? []
    }

    var month: String {
        scheduleDate.formatted(.dateTime.year().month(.wide))
    }

    var week: String {
        if scheduleDate.isInThisWeek {
            return "This week"
        } else {
            return "Next weeks"
        }
    }

    static var example: Schedule {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let schedule = Schedule(context: viewContext)
        schedule.name = "Jaejun Shin"
        schedule.date = Date()
        schedule.design = "Neo traditional"
        schedule.price = "100"

        return schedule
    }
}
