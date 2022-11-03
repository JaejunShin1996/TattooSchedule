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

    @State private var showingAddSchedule = false
    @State private var showingSearchView = false

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
                        showingAddSchedule.toggle()
                    } label: {
                        Label("Add Schedule", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSearchView.toggle()
                    } label: {
                        Label("Search for schedules", systemImage: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingAddSchedule) {
                AddScheduleView()
            }
            .sheet(isPresented: $showingSearchView) {
                ScheduleSearchView(dataController: dataController)
            }
        }
    }
}
