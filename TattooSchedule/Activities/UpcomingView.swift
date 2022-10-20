//
//  UpcomingView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 18/10/2022.
//

import SwiftUI

struct UpcomingSectionView: View {
    static let tag: String? = "Upcoming"

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var dataController: DataController

    var body: some View {
        NavigationView {
            Group {
                if viewModel.upcomingSchedules().isEmpty {
                    Text("No upcoming schedules.")
                } else {
                    List {
                        ForEach(viewModel.upcomingSchedules()) { schedule in
                            NavigationLink {
                                DetailEditView(viewModel: viewModel, schedule: schedule)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .bold()

                                    Text(schedule.scheduleDate.formatted())
                                }
                                .font(.title)
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
            .navigationTitle("Upcoming")
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
