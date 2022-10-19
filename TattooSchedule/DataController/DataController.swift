//
//  DataController.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//
import CoreData
import Foundation
import UserNotifications

class DataController: ObservableObject {
    var container = NSPersistentCloudKitContainer(name: "Main")

    let id = UUID().uuidString
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.jaejunshin.TattooSchedule"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading stroe: \(error.localizedDescription)")
            }

            self.container.viewContext.automaticallyMergesChangesFromParent = true
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
        let dataController = DataController(inMemory: true)

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
            schedule.comment = "Example"
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
}
