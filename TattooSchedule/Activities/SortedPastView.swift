//
//  SortedPastView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 22/10/2022.
//

import SwiftUI

struct SortedPastView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var dataController: DataController

    var body: some View {
        List {
            ForEach(Array(viewModel.groupSchedulesByMonth()), id: \.key) { month, schedules in
                Section {
                    ForEach(schedules) { schedule in
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
                } header: {
                    Text(month)
                        .foregroundColor(.primary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
