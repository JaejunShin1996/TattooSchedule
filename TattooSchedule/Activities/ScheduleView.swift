//
//  ScheduleView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import BackgroundTasks
import SwiftUI
import UserNotifications

struct ScheduleView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)

        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today").font(.title)) {
                    ForEach(viewModel.schedules) { schedule in
                        if isToday(schedule: schedule) {
                            NavigationLink {
                                DetailView(schedule: schedule)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .font(.largeTitle)
                                    
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
                                        .font(.title)
                                    
                                    Text(schedule.scheduleDate.formatted())
                                        .font(.title)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Past").font(.caption)) {
                    ForEach(viewModel.schedules) { schedule in
                        if isYesterday(schedule: schedule) ||
                            (!isToday(schedule: schedule) && !isTomorrow(schedule: schedule)) {
                            NavigationLink {
                                DetailView(schedule: schedule)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .font(.title3)
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
            .navigationTitle("Tattoo Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddSchedule.toggle()
                    } label: {
                        Label("Add Schedule", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSchedule) {
                AddScheduleView()
            }
            .alert(isPresented: $viewModel.showingNotificationsError) {
                Alert(
                    title: Text("Oops!"),
                    message: Text("There was a problem. Please check you have notifications enabled."),
                    primaryButton: .default(Text("Check Settings"), action: showAppSettings),
                    secondaryButton: .cancel()
                )
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

    

    // alerts when users have disabled the notification.
    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(dataController: DataController.preview)
    }
}
