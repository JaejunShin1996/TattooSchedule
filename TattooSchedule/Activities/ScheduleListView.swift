//
//  ScheduleListView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 15/11/2022.
//

import SwiftUI

struct ScheduleListView: View {
    static let todayTag: String? = "Today"
    static let UpcomingTag: String? = "Upcoming"
    static let pastTag: String? = "Past"

    var navigationTitle: String

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var dataController: DataController

    var schedulesForEachView: [Schedule] {
        if navigationTitle == "Today" {
            return viewModel.todaySchedules()
        } else if navigationTitle == "Upcoming" {
            return viewModel.upcomingSchedules()
        } else {
            return viewModel.pastSchedules()
        }
    }

    @State private var showingAddSchedule = false
    @State private var showingSearchView = false

    var body: some View {
        NavigationView {
            Group {
                if schedulesForEachView.isEmpty {
                    Text("No schedules.")
                } else {
                    if navigationTitle == "Today" {
                        todayList
                    } else if navigationTitle == "Upcoming" {
                        upcomingList
                    } else {
                        pastList
                    }
                }
            }
            .navigationTitle(navigationTitle)
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
                ScheduleSearchView(viewModel: viewModel)
            }
        }
    }

    var todayList: some View {
        List {
            ForEach(schedulesForEachView) { schedule in
                NavigationLink {
                    DetailView(viewModel: viewModel, schedule: schedule)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(schedule.scheduleName)
                                .font(.title)
                                .bold()

                            HStack {
                                Text(schedule.scheduleDate.formatted(date: .omitted, time: .shortened))
                                    .font(.title)
                                Text(schedule.scheduleDate.formatted(date: .abbreviated, time: .omitted))
                            }
                        }

                        Spacer()

                        Text("A$ \(schedule.schedulePrice)")
                    }
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

    var upcomingList: some View {
        List {
            ForEach(Array(viewModel.groupUpcomingSchedulesByWeeks()), id: \.key) { week, schedules in
                Section {
                    ForEach(schedules) { schedule in
                        NavigationLink {
                            DetailView(viewModel: viewModel, schedule: schedule)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .font(.title)
                                        .bold()

                                    HStack {
                                        Text(schedule.scheduleDate.formatted(date: .omitted, time: .shortened))
                                            .font(.title)
                                        Text(schedule.scheduleDate.formatted(date: .abbreviated, time: .omitted))
                                    }
                                }

                                Spacer()

                                Text("A$ \(schedule.schedulePrice)")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                dataController.delete(schedule)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(week)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    var pastList: some View {
        List {
            ForEach(Array(viewModel.groupPastSchedulesByMonth()), id: \.key) { month, schedules in
                Section {
                    ForEach(schedules) { schedule in
                        NavigationLink {
                            DetailView(viewModel: viewModel, schedule: schedule)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(schedule.scheduleName)
                                    .bold()

                                Text(schedule.scheduleDate.formatted(date: .abbreviated, time: .shortened))
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
                } header: {
                    Text(month)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static let viewModel = ViewModel(dataController: DataController.preview)

    static var previews: some View {
        ScheduleListView(
            navigationTitle: "Example",
            viewModel: viewModel,
            dataController: DataController.preview
        )
    }
}
