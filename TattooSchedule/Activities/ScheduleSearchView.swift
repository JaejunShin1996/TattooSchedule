//
//  ScheduleSearchView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 11/10/2022.
//

import SwiftUI

struct ScheduleSearchView: View {
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""

    @ObservedObject var viewModel: ViewModel

    var searchResults: [Schedule] {
        if searchText.isEmpty {
            return []
        } else {
            return viewModel.filteredSchedules(searchString: searchText)
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if searchResults.isEmpty {
                    VStack {
                        Spacer()

                        Text("Search a client's name")
                            .font(.headline)
                            .italic()

                        Spacer()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(searchResults, id: \.self) { schedule in
                            NavigationLink(destination: DetailView(viewModel: viewModel, schedule: schedule)) {
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)

                                    Text(schedule.scheduleDate.formatted())
                                }
                                .font(.headline)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Back")
                    }

                }
            }
        }
    }
}

struct ScheduleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleSearchView(viewModel: ViewModel(dataController: DataController()))
    }
}
