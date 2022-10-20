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
    // Single image picker
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

    // Multiple images picker
    @Published var images: [UIImage] = []

    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            if !imageSelections.isEmpty {
                Task {
                    try await loadTransferable(from: imageSelections)
//                    imageSelections = []
                }
            }
        }
    }

    func loadTransferable(from imageSelections: [PhotosPickerItem]) async throws {
        do {
            images.removeAll(keepingCapacity: true)
            for imageSelection in imageSelections {
                if let data = try await imageSelection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        self.images.append(uiImage)
                    }
                }
            }
        } catch {
            print("debug: \(error.localizedDescription)")
        }
    }
}
