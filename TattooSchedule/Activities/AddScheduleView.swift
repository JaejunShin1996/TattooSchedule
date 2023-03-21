//
//  AddScheduleView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import ImageViewer
import SwiftUI
import PhotosUI

struct AddScheduleView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataController: DataController

    @FocusState private var focusedField: Field?

    @StateObject var imagePicker = ImagePicker()
    @State private var selectedPhoto = Image(systemName: "flame.fill")
    @State private var showingImageViewer = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    @State private var name = ""
    @State private var price = ""
    @State private var comment = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    NameAndDetailView(name: $name, price: $price, comment: $comment)

                    photoSelectionBlock

                    DateAndTimeView(colorScheme: colorScheme, date: $date)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Back")
                            .tint(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addNewSchedule()
                    } label: {
                        Text("Save")
                    }
                }
            }
            .overlay(
                ImageViewer(
                    image: $selectedPhoto,
                    viewerShown: $showingImageViewer,
                    closeButtonTopRight: true
                )
            )
        }
    }

    func addNewSchedule() {
        let newSchedule = Schedule(context: dataController.container.viewContext)
        newSchedule.id = UUID()
        newSchedule.name = name == "" ? "John Doe" : name
        newSchedule.date = date
        newSchedule.comment = comment == "" ? "No comments" : comment
        newSchedule.price = price == "" ? "0" : price
        if !(imagePicker.images.isEmpty) {
            for image in imagePicker.images {
                if let data = image.jpegData(compressionQuality: 1.0) {
                    let newPhoto = Photo(context: dataController.container.viewContext)
                    newPhoto.designPhoto = data
                    newPhoto.creationTime = Date.now
                    newPhoto.schedule = newSchedule
                }
            }
        }

        NotificationManager.instance.scheduleNotification(
            stringID: newSchedule.scheduleStringID,
            name: newSchedule.scheduleName,
            time: newSchedule.scheduleDate.formatted(date: .omitted, time: .shortened),
            weekday: Calendar.current.component(.weekday, from: newSchedule.scheduleDate)
        )

        dataController.save()
        dismiss()
    }
}

extension AddScheduleView {
    var photoSelectionBlock: some View {
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
                        .foregroundColor(.blue)
                }
            }
            
            GeometryReader { geometry in
                if imagePicker.images.isEmpty {
                    ZStack {
                        Text("Up to 10 photos.")
                    }
                    .defaultEmptyImageViewModifier()

                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(imagePicker.images, id: \.self) { photo in
                            PreviewableGridImageView(image: photo, geometry: geometry)
                                .onTapGesture {
                                    selectedPhoto = Image(uiImage: photo)
                                    showingImageViewer.toggle()
                                }
                        }
                    }
                }
            }
            .frame(height:
                    imagePicker.images.isEmpty ?
                   50 : 150 * CGFloat(optimiseHeight(imagesCount: imagePicker.images.count))
            )
        }
    }
    
    func optimiseHeight(imagesCount: Int) -> Int {
        if imagesCount <= 3 {
            return 1
        } else if imagesCount <= 6 {
            return 2
        } else {
            return 3
        }
    }
}

struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
    }
}
