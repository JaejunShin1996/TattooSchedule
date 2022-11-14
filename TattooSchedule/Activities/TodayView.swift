//
//  TodayView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 18/10/2022.
//

import SwiftUI

struct TodaySectionView: View {
    static let tag: String? = "Today"

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var dataController: DataController

    @State private var showingAddSchedule = false
    @State private var showingSearchView = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.todaySchedules().isEmpty {
                    Text("No today schedules.")
                } else {
                    List {
                        ForEach(viewModel.todaySchedules()) { schedule in
                            NavigationLink {
                                DetailView(viewModel: viewModel, schedule: schedule)
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
            .navigationTitle("Today")
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
