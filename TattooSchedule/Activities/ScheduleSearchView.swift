//
//  ScheduleSearchView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 11/10/2022.
//

import SwiftUI

struct ScheduleSearchView: View {
    @State private var searchText = ""

    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)

        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var searchResults: [Schedule] {
        if searchText.isEmpty {
            return viewModel.schedules
        } else {
            return viewModel.filteredSchedules(searchString: searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults, id: \.self) { schedule in
                    NavigationLink(destination: DetailView(schedule: schedule)) {
                        VStack(alignment: .leading) {
                            Text(schedule.scheduleName)
                                .font(.headline)

                            Text(schedule.scheduleDate.formatted())
                                .font(.headline)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Search")
        }
    }
}

struct ScheduleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleSearchView(dataController: DataController.preview)
    }
}
