//
//  DetailEditView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import ImageViewer
import SwiftUI
import PhotosUI

struct DetailEditView: View {
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController

    @ObservedObject var imagePicker = ImagePicker()

    @State private var selectedPhoto = Image(systemName: "flame.fill")
    @State private var showingImageViewer = false

    let columns = [GridItem(.adaptive(minimum: 100))]

    @State private var name: String
    @State private var date: Date
    @State private var design: String
    @State private var price: String

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var schedule: Schedule

    init(viewModel: ViewModel, schedule: Schedule) {
        self.viewModel = viewModel
        self.schedule = schedule

        _name = State(wrappedValue: schedule.scheduleName)
        _date = State(wrappedValue: schedule.scheduleDate)
        _design = State(wrappedValue: schedule.scheduleDesign)
        _price = State(wrappedValue: schedule.schedulePrice)
    }

    @State private var showingEditMode = false
    @State private var showingDeleteAlert = false

    var body: some View {
        Form {
            if !showingEditMode {
                detailView
            } else {
                editView
            }

            Section {
                Button {
                    switchViews()
                } label: {
                    Text(showingEditMode ? "Save" : "Edit")
                }
            }
        }
        .navigationTitle(schedule.scheduleName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            Button {
                showingDeleteAlert = true
            } label: {
                Label("Delete the schedule", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .overlay(
            ImageViewer(
                image: $selectedPhoto,
                viewerShown: $showingImageViewer,
                closeButtonTopRight: true
            )
        )
        .alert("Delete this Schedule?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive, action: deleteSchedule)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you really sure?")
        }
        .onSubmit {
            switch focusedField {
            case .clientName:
                focusedField = .design
            case .design:
                focusedField = .price
            default:
                print("Creating account…")
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    var detailView: some View {
        Group {
            Section {
                Text(schedule.scheduleDate, style: .date)
                    .font(.title)
                Text(schedule.scheduleDate, style: .time)
                    .font(.title)
            } header: {
                Text("Time")
            }

            Section {
                Text(schedule.scheduleDesign)
                    .font(.title)

                Text(schedule.schedulePrice)
                    .font(.title)
            } header: {
                Text("Design & Comment")
            }

            photosInDetailView
        }
    }

    var editView: some View {
        Group {
            Section {
                DatePicker("Date", selection: $date)
                    .datePickerStyle(.graphical)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 30
                    }
            }

            Section {
                TextField("Client Name", text: $name)
                    .focused($focusedField, equals: .clientName)
                    .submitLabel(.done)
            } header: {
                Text("Name")
            }

            Section {
                TextField(design, text: $design)
                    .focused($focusedField, equals: .design)
                    .submitLabel(.done)

                TextField(price, text: $price)
                    .focused($focusedField, equals: .price)
                    .submitLabel(.done)
            } header: {
                Text("Design & Comment")
            }

            photosInEditView
        }
    }

    var photosInDetailView: some View {
        Section {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(viewModel.sortedImages(schedule)) { photo in
                    if let data = photo.designPhoto {
                        ZStack {
                            Color(.darkGray)
                                .opacity(0.5)

                            Image(uiImage: UIImage(data: data)!)
                                .resizable()
                                .scaledToFit()
                        }
                        .cornerRadius(10.0)
                        .frame(width: (UIScreen.main.bounds.width - 20) * 0.4, height: 160)
                        .onTapGesture {
                            selectedPhoto = Image(uiImage: UIImage(data: data)!)
                            showingImageViewer.toggle()
                        }
                    }
                }
                .padding(.vertical, 3)
            }
        } header: {
            Text("Photo")
        }
    }

    var photosInEditView: some View {
    Section {
        PhotosPicker(
            selection: $imagePicker.imageSelections,
            maxSelectionCount: 10,
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()
        ) {
            HStack {
                Text("Reselect photos")
                Image(systemName: "photo.stack")
            }
        }

        if imagePicker.images.isEmpty {
            VStack {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(viewModel.sortedImages(schedule)) { photo in
                        if let data = photo.designPhoto {
                            ZStack {
                                Color(.darkGray)
                                    .opacity(0.5)

                                Image(uiImage: UIImage(data: data)!)
                                    .resizable()
                                    .scaledToFit()
                            }
                            .cornerRadius(10.0)
                            .frame(width: (UIScreen.main.bounds.width - 20) * 0.4, height: 160)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }
        } else {
            VStack {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(imagePicker.images, id: \.self) { photo in
                        ZStack {
                            Color(.darkGray)
                                .opacity(0.5)

                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                        }
                        .cornerRadius(20.0)
                        .frame(width: 150, height: 160)
                        .padding(.vertical, 3)
                    }
                }
            }
        }
    } header: {
        Text("Photo")
    }
}

    func switchViews() {
        if showingEditMode {
            saveEditedSchedule(schedule)
            showingEditMode.toggle()
        } else {
            showingEditMode.toggle()
        }
    }

    func saveEditedSchedule(_ editedSchedule: Schedule) {
        editedSchedule.name = name
        editedSchedule.date = date
        editedSchedule.design = design
        editedSchedule.price = price

        if !(imagePicker.images.isEmpty) {
            editedSchedule.photos = []
            for image in imagePicker.images {
                if let data = image.jpegData(compressionQuality: 1.0) {
                    let newPhoto = Photo(context: dataController.container.viewContext)
                    newPhoto.designPhoto = data
                    newPhoto.creationTime = Date.now
                    newPhoto.schedule = editedSchedule
                }
            }
        }

        NotificationManager.instance.cancelNotification(notificationId: editedSchedule.scheduleStringID)
        NotificationManager.instance.scheduleNotification(
            stringID: editedSchedule.scheduleStringID,
            name: editedSchedule.scheduleName,
            time: editedSchedule.scheduleDate.formatted(date: .omitted, time: .shortened),
            weekday: Calendar.current.component(.weekday, from: editedSchedule.scheduleDate)
        )

        dataController.save()
    }

    func deleteSchedule() {
        dataController.delete(schedule)
        NotificationManager.instance.cancelNotification(notificationId: schedule.scheduleStringID)
        dismiss()
    }
}
