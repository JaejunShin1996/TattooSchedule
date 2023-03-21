//
//  DataController.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let id = UUID().uuidString
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Main")

        container.loadPersistentStores { [self] (_, error) in
            if let error = error {
                fatalError("Fatal error loading stroe: \(error.localizedDescription)")
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
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
