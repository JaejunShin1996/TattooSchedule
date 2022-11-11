//
//  AddScheduleView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import SwiftUI
import PhotosUI

struct AddScheduleView: View {
    @FocusState private var focusedField: Field?

    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss

    @StateObject var imagePicker = ImagePicker()

    let columns = [GridItem(.adaptive(minimum: 100))]

    @State private var name = ""
    @State private var date = Date()
    @State private var design = ""
    @State private var comment = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Client Name", text: $name)
                        .focused($focusedField, equals: .clientName)
                        .submitLabel(.done)
                } header: {
                    Text("Name")
                }

                Section {
                    TextField("Design", text: $design)
                        .focused($focusedField, equals: .design)
                        .submitLabel(.done)

                    TextField("Any Comment?", text: $comment)
                        .focused($focusedField, equals: .comment)
                        .submitLabel(.done)
                } header: {
                    Text("Detail & Comment")
                }

                Section {
                    DatePicker("Date & Time", selection: $date)
                        .datePickerStyle(.compact)
                        .onAppear {
                            UIDatePicker.appearance().minuteInterval = 30
                        }
                } header: {
                    Text("Date")
                }

                photosInAddingView
            }
            .navigationTitle("Add New Schedule")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            addNewSchedule()
                            dismiss()
                        } label: {
                            Text("Save")
                        }
                    }
                }
                .onSubmit {
                    switch focusedField {
                    case .clientName:
                        focusedField = .design
                    case .design:
                        focusedField = .comment
                    default:
                        print("Creating account…")
                    }
                }
                .scrollDismissesKeyboard(.immediately)
        }
    }

    var photosInAddingView: some View {
        Section {
            PhotosPicker(
                selection: $imagePicker.imageSelections,
                maxSelectionCount: 10,
                matching: .images,
                preferredItemEncoding: .automatic,
                photoLibrary: .shared()
            ) {
                HStack(alignment: .center) {
                    Text("Photos")
                    Image(systemName: "photo.stack")
                }
            }

            if !imagePicker.images.isEmpty {
                VStack {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(0..<imagePicker.images.count, id: \.self) { index in
                            ZStack {
                                Color(.darkGray)
                                    .opacity(0.5)

                                Image(uiImage: imagePicker.images[index])
                                    .resizable()
                                    .scaledToFit()
                            }
                            .cornerRadius(10.0)
                            .frame(width: (UIScreen.main.bounds.width - 20) * 0.4, height: 160)
                            .padding(.vertical, 3)
                        }
                    }
                }
            }
        } header: {
            Text("Photo")
        }
    }

    func addNewSchedule() {
        let newSchedule = Schedule(context: dataController.container.viewContext)
        newSchedule.id = UUID()
        newSchedule.name = name == "" ? "John Doe" : name
        newSchedule.date = date
        newSchedule.design = design == "" ? "No detail" : design
        newSchedule.comment = comment == "" ? "No comment" : comment
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
            name: newSchedule.scheduleName,
            time: newSchedule.scheduleDate.formatted(date: .omitted, time: .shortened)
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
