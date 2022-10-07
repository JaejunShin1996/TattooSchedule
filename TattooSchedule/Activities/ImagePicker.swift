//
//  PhotoPickerView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 29/9/2022.
//

import SwiftUI
import PhotosUI

@MainActor
class ImagePicker: ObservableObject {
    @Published var image: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection {
                Task {
                    try await loadTransferable(from: imageSelection)
                }
            }
        }
    }

    func loadTransferable(from imageSelection: PhotosPickerItem?) async throws {
        do {
            if let data = try await imageSelection?.loadTransferable(type: Data.self) {
                self.image = UIImage(data: data)
            }
        } catch {
            print("debug: \(error.localizedDescription)")
        }
    }
}
