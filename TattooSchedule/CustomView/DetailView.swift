//
//  DetailView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 12/11/2022.
//

import ImageViewer
import SwiftUI
import PhotosUI

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var schedule: Schedule

    @State private var name: String
    @State private var date: Date
    @State private var design: String
    @State private var price: String
    @State private var photos: [Photo]

    init(viewModel: ViewModel, schedule: Schedule) {
        self.viewModel = viewModel
        self.schedule = schedule

        _name = State(wrappedValue: schedule.scheduleName)
        _date = State(wrappedValue: schedule.scheduleDate)
        _design = State(wrappedValue: schedule.scheduleDesign)
        _price = State(wrappedValue: schedule.schedulePrice)
        _photos = State(wrappedValue: viewModel.sortedImages(schedule))
    }

    @ObservedObject var imagePicker = ImagePicker()
    @State private var selectedPhoto = Image(systemName: "flame.fill")
    @State private var showingImageViewer = false

    @State private var showingDeleteAlert = false

    @State private var detailmode = true
    @State private var editting = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center) {
                NameAndDetailView(name: $name, detail: $design)
                    .allowsHitTesting(editting)

                GridPhotoView(
                    isEditing: editting,
                    colorScheme: colorScheme,
                    imagePicker: imagePicker,
                    photos: $photos,
                    selectedPhoto: $selectedPhoto,
                    showingImageViewer: $showingImageViewer
                )

                DateAndTimeView(isEditing: editting,
                                colorScheme: colorScheme)
                    .allowsHitTesting(editting)

                SlideToUnlockView(isLocked: $detailmode)

                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .onChange(of: detailmode) { newValue in
            if newValue {
                saveEditedSchedule(schedule)
                photos = schedule.schedulePhotos
            }
            editting.toggle()
        }
        .navigationTitle(name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "trash")
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
    }

    func deleteSchedule() {
        dataController.delete(schedule)
        NotificationManager.instance.cancelNotification(notificationId: schedule.scheduleStringID)
        dismiss()
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
}

struct NameAndDetailView: View {
    @FocusState private var focusedField: Field?
    @Binding var name: String
    @Binding var detail: String
    @State private var price = "100"

    var body: some View {
        VStack {
            Text("Detail")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .clientName)
                    .font(.headline)

                Divider()

                TextField("Detail and Comment", text: $detail)
                    .focused($focusedField, equals: .design)
                    .font(.headline)

                Divider()

                HStack {
                    Text("A$")

                    TextField("Price", text: $price)
                        .focused($focusedField, equals: .price)
                        .keyboardType(.numberPad)
                }
                .font(.title)
                .bold()
            }
            .padding()
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            .shadow(radius: 20)
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
}

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

            LazyVGrid(columns: columns) {
                if (isEditing || !isEditing) && imagePicker.images.isEmpty {
                    ForEach(photos) { photo in
                        if let data = photo.designPhoto {
                            if let uiImage = UIImage(data: data) {
                                RoundedRectangle(cornerRadius: 15.0)
                                    .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15,
                                           height: 160)
                                    .overlay {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 160)
                                            .cornerRadius(15.0)
                                            .allowsHitTesting(false)
                                    }
                                    .onTapGesture {
                                        selectedPhoto = Image(uiImage: uiImage)
                                        showingImageViewer.toggle()
                                }
                            } else {
                                    Text("Photos can't be loaded.")
                            }
                        } else {
                            Text("Photos can't be loaded.")
                        }
                    }
                } else if (isEditing || !isEditing) && !imagePicker.images.isEmpty {
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
}

struct DateAndTimeView: View {
    var isEditing = false
    var colorScheme: ColorScheme
    @State private var date = Date.now

    var body: some View {
        VStack {
            Text("Date & Time")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                DatePicker("Date", selection: $date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
            }
            .tint(
                colorScheme == .light ?
                  isEditing ? .blue : .primary
                : isEditing ? .blue : .secondary
            )
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .padding(.top)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            viewModel: ViewModel(dataController: DataController()),
            schedule: Schedule.example
        )
    }
}
