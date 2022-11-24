//
//  GridPhotoView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 15/11/2022.
//

import SwiftUI
import PhotosUI

struct GridPhotoView: View {
    var isEditing = false

    let columns = [GridItem(.adaptive(minimum: 100))]

    var colorScheme: ColorScheme

    @ObservedObject var imagePicker: ImagePicker
    @Binding var photos: [Photo]
    @Binding var selectedPhoto: Image
    @Binding var showingImageViewer: Bool

    var body: some View {
        VStack {
            HStack {
                Text("Photo")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PhotosPicker(
                    selection: $imagePicker.imageSelections,
                    maxSelectionCount: 10,
                    matching: .images,
                    preferredItemEncoding: .automatic,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.stack")
                        .font(.title)
                        .foregroundColor(isEditing ? .blue : .secondary)
                }
                .allowsHitTesting(isEditing)
            }

            if photos.isEmpty && imagePicker.images.isEmpty {
                ZStack {
                    Text("No photos selected.")
                }
                .defaultEmptyImageViewModifier()

            } else if imagePicker.images.isEmpty {
                LazyVGrid(columns: columns) {
                    ForEach(photos) { photo in
                        if let data = photo.designPhoto {
                            if let uiImage = UIImage(data: data) {
                                PreviewableGridImageView(image: uiImage)
                                .onTapGesture {
                                    selectedPhoto = Image(uiImage: uiImage)
                                    showingImageViewer.toggle()
                                }
                            }
                        }
                    }
                }
            } else if !imagePicker.images.isEmpty {
                LazyVGrid(columns: columns) {
                    ForEach(imagePicker.images, id: \.self) { photo in
                        PreviewableGridImageView(image: photo)
                        .onTapGesture {
                            selectedPhoto = Image(uiImage: photo)
                            showingImageViewer.toggle()
                        }
                    }
                }
            }
        }
    }
}
