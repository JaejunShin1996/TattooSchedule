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
            List {
                ForEach(viewModel.pastSchedules()) { schedule in
                    NavigationLink {
                        DetailView(schedule: schedule)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(schedule.scheduleName)
                                .bold()

                            Text(schedule.scheduleDate.formatted())
                        }
                        .font(.headline)
                        .foregroundColor(.secondary)
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
