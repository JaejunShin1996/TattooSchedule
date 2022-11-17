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

    @StateObject var imagePicker = ImagePicker()
    @State private var selectedPhoto = Image(systemName: "flame.fill")
    @State private var showingImageViewer = false

    @State private var showingDeleteAlert = false

    @State private var detailmode = true
    @State private var editting = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center) {
                NameAndDetailView(name: $name, detail: $design, price: $price)
                    .allowsHitTesting(editting)

                GridPhotoView(
                    isEditing: editting,
                    colorScheme: colorScheme,
                    imagePicker: imagePicker,
                    photos: $photos,
                    selectedPhoto: $selectedPhoto,
                    showingImageViewer: $showingImageViewer
                )

                DateAndTimeView(isEditing: editting, colorScheme: colorScheme, date: $date)
                    .allowsHitTesting(editting)

                SlideToUnlockView(isLocked: $detailmode)

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .navigationTitle(name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingDeleteAlert.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .onChange(of: detailmode) { _ in
            editting.toggle()
            if !editting {
                saveEditedSchedule(schedule)
                photos = viewModel.sortedImages(schedule)
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

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            viewModel: ViewModel(dataController: DataController()),
            schedule: Schedule.example
        )
    }
}
