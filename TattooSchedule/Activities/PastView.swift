//
//  PastView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 18/10/2022.
//

import SwiftUI

struct PastSectionView: View {
    static let tag: String? = "Past"

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var dataController: DataController

    var body: some View {
        NavigationView {
            Group {
                if viewModel.pastSchedules().isEmpty {
                    Text("No past schedules.")
                } else {
                    List {
                        ForEach(viewModel.pastSchedules()) { schedule in
                            NavigationLink {
                                DetailEditView(viewModel: viewModel, schedule: schedule)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .bold()

                                    Text(schedule.scheduleDate.formatted())
                                }
                                .font(.headline)
                                .foregroundColor(.secondary)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    dataController.delete(schedule)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Past")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddSchedule.toggle()
                    } label: {
                        Label("Add Schedule", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.showingSearchView.toggle()
                    } label: {
                        Label("Search for schedules", systemImage: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSchedule) {
                AddScheduleView()
            }
        }
    }
}
