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
                Text("No photos selected.")
                    .italic()
            } else if imagePicker.images.isEmpty {
                LazyVGrid(columns: columns) {
                    ForEach(photos) { photo in
                        if let data = photo.designPhoto {
                            if let uiImage = UIImage(data: data) {
                                RoundedRectangle(cornerRadius: 15.0)
                                    .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15,
                                           height: 150)
                                    .overlay {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 150)
                                            .cornerRadius(15.0)
                                            .allowsHitTesting(false)
                                    }
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
                        RoundedRectangle(cornerRadius: 15.0)
                            .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 150)
                            .overlay {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 150)
                                    .cornerRadius(15.0)
                                    .allowsHitTesting(false)
                            }
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
