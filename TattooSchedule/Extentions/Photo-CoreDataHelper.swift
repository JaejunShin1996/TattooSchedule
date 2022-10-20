//
//  Photo-CoreDataHelper.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 18/10/2022.
//

import Foundation

extension Photo {
    var schedulePhoto: Data {
        designPhoto ?? Data()
    }

    var photoCreationTime: Date {
        creationTime ?? Date.now
    }
}
