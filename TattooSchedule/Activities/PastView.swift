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

    @State private var showingAddSchedule = false
    @State private var showingSearchView = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.pastSchedules().isEmpty {
                    Text("No past schedules.")
                } else {
                    SortedPastView(viewModel: viewModel, dataController: dataController)
                }
            }
            .navigationTitle("Past")
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
