//
//  ScheduleView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import BackgroundTasks
import SwiftUI

struct ScheduleView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var dataController: DataController
    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)

        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Today").font(.title)) {
                    ForEach(viewModel.schedules) { schedule in
                        if isToday(schedule: schedule) {
                            NavigationLink {
                                DetailView(schedule: schedule)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .font(.title)

                                    Text(schedule.scheduleDate.formatted())
                                        .font(.title)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Upcoming").font(.caption)) {
                    ForEach(viewModel.schedules) { schedule in
                        if isTomorrow(schedule: schedule) ||
                            schedule.scheduleDate > Date.now.addingTimeInterval(86400) {
                            NavigationLink {
                                DetailView(schedule: schedule)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .font(.headline)

                                    Text(schedule.scheduleDate.formatted())
                                        .font(.headline)
                                }
                            }
                        }
                    }
                }

                Toggle(isOn: $viewModel.showingPastSchedule) {
                    Text("Past Schedules")
                }

                if viewModel.showingPastSchedule {
                    Section(header: Text("Past").font(.caption)) {
                        ForEach(viewModel.schedules) { schedule in
                            if isYesterday(schedule: schedule) ||
                                (!isToday(schedule: schedule) &&
                                 !isTomorrow(schedule: schedule) &&
                                 !(schedule.scheduleDate > Date.now.addingTimeInterval(86400))
                                ) {
                                NavigationLink {
                                    DetailView(schedule: schedule)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(schedule.scheduleName)
                                            .font(.headline)
                                            .foregroundColor(.secondary)

                                        Text(schedule.scheduleDate.formatted())
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

            }
            .navigationTitle("Tattoo Schedule")
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
            .sheet(isPresented: $viewModel.showingSearchView) {
                ScheduleSearchView(dataController: dataController)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("Inactive")
                    viewModel.reload()
                } else if newPhase == .active {
                    print("Active")
                    viewModel.reload()
                } else if newPhase == .background {
                    print("Background")
                    viewModel.reload()
                }
            }
        }
    }

    func isToday(schedule: Schedule) -> Bool {
        let firstDate = Date.now
        let secondDate = schedule.scheduleDate

        return Calendar.current.isDate(firstDate, inSameDayAs: secondDate)
    }

    func isTomorrow(schedule: Schedule) -> Bool {
        let date = schedule.scheduleDate

        return Calendar.current.isDateInTomorrow(date)
    }

    func isYesterday(schedule: Schedule) -> Bool {
        let date = schedule.scheduleDate

        return Calendar.current.isDateInYesterday(date)
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(dataController: DataController.preview)
    }
}
