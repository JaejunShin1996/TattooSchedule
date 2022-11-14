//
//  DataController.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//
import CoreData
import Foundation

class DataController: ObservableObject {
    var container = NSPersistentContainer(name: "Main")

    let id = UUID().uuidString

    init() {
        container = NSPersistentContainer(name: "Main", managedObjectModel: Self.model)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading stroe: \(error.localizedDescription)")
            }

            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    static let preview: DataController = {
        let dataController = DataController()

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("fatal error loading preview, \(error.localizedDescription)")
        }

        return dataController
    }()

    func createSampleData() throws {
        let viewContext = container.viewContext

        for _ in 1...5 {
            let schedule = Schedule(context: viewContext)
            schedule.name = "Example"
            schedule.date = Date()
            schedule.price = "100"
            schedule.design = "Example"

        }
        try viewContext.save()
    }

    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func delete(_ object: Schedule) {
        container.viewContext.delete(object)
        save()
    }

    func deletePhoto(_ object: Photo) {
        container.viewContext.delete(object)
        save()
    }
}
