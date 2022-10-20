//
//  Schedule-CoreDataHelper.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 26/9/2022.
//

import Foundation

extension Schedule {
    var scheduleName: String {
        name ?? "John Doe"
    }

    var scheduleDate: Date {
        date ?? Date.now
    }

    var scheduleDesign: String {
        design ?? "Nothing"
    }

    var scheduleComment: String {
        comment ?? "Nothing"
    }

    var schedulePhotos: [Photo] {
        photos?.allObjects as? [Photo] ?? []
    }

    static var example: Schedule {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let schedule = Schedule(context: viewContext)
        schedule.name = "Example Name"
        schedule.date = Date()
        schedule.comment = "Example Comment"
        schedule.design = "Example Design"

        return schedule
    }
}
