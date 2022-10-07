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
                    if let image = imagePicker.image {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()

                            PhotosPicker(
                                selection: $imagePicker.imageSelection,
                                matching: .images,
                                preferredItemEncoding: .automatic,
                                photoLibrary: .shared()
                            ) {
                                Text("Select a photo")
                            }
                        }
                    } else {
                        PhotosPicker(
                            selection: $imagePicker.imageSelection,
                            matching: .images,
                            preferredItemEncoding: .automatic,
                            photoLibrary: .shared()
                        ) {
                            Text("Select a photo")
                        }
                    }
                } header: {
                    Text("Photo")
                }

                Section {
                    DatePicker("Select the date", selection: $date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onAppear {
                            UIDatePicker.appearance().minuteInterval = 30
                        }
                }
                
                Section {
                    Button("Save") {
                        addNewSchedule()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add New Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
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

    func addNewSchedule() {
        let newSchedule = Schedule(context: dataController.container.viewContext)
        newSchedule.id = UUID()
        newSchedule.name = name
        newSchedule.date = date
        newSchedule.design = design == "" ? "No detail" : design
        newSchedule.comment = comment == "" ? "No comment" : comment
        if let selectedImage = imagePicker.image {
            let data = selectedImage.jpegData(compressionQuality: 1.0)
            newSchedule.designPhoto = data
        }

        dataController.save()
    }
}

struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
    }
}
