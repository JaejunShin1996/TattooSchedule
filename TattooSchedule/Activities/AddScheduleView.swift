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

    let columns = [GridItem(.adaptive(minimum: 100))]

    @State private var name = ""
    @State private var date = Date()
    @State private var design = ""
    @State private var price = ""

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    NameAndDetailView(name: $name, detail: $design, price: $price)

                    photoSelectionBlock

                    DateAndTimeView(colorScheme: colorScheme, date: $date)
                }
                .padding(.horizontal)
            }
            .toolbar {
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

            if imagePicker.images.isEmpty {
                Text("No photos selected.")
                    .italic()
            } else {
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(imagePicker.images, id: \.self) { photo in
                        RoundedRectangle(cornerRadius: 15.0)
                            .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 160)
                            .overlay {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 160)
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

    func addNewSchedule() {
        let newSchedule = Schedule(context: dataController.container.viewContext)
        newSchedule.id = UUID()
        newSchedule.name = name == "" ? "John Doe" : name
        newSchedule.date = date
        newSchedule.design = design == "" ? "No detail" : design
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

struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
    }
}
