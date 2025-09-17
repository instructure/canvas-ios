//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
import Core

struct SubmissionsFilterScreen: View {

    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: SubmissionListViewModel

    private let statusFilterOptions: MultiSelectionOptions
    private let sectionFilterOptions: MultiSelectionOptions
    private let sortModeOptions: SingleSelectionOptions
    private let courseColor: Color

    init(viewModel: SubmissionListViewModel) {
        self.viewModel = viewModel

        courseColor = viewModel.course.flatMap { Color(uiColor: $0.color) } ?? Color(Brand.shared.primary)

        let statusesSelection = Set(viewModel.statusFilters.map({ OptionItem(id: $0.rawValue, title: $0.name) }))
        let allOptions = viewModel.statusFilterOptions.map({ OptionItem(id: $0.rawValue, title: $0.name) })

        self.statusFilterOptions = MultiSelectionOptions(
            all: allOptions,
            initial: statusesSelection
        )

        let sectionSelection = Set(viewModel.sectionFiltersRealized.map({ OptionItem(id: $0.id, title: $0.name) }))
        let sectionOptions = viewModel.courseSections.map { OptionItem(id: $0.id, title: $0.name) }

        self.sectionFilterOptions = MultiSelectionOptions(
            all: sectionOptions,
            initial: sectionSelection
        )

        let sortOptionItems = SubmissionsSortMode.allCases.map { order in
            OptionItem(id: order.rawValue, title: order.name)
        }

        self.sortModeOptions = SingleSelectionOptions(
            all: sortOptionItems,
            initialId: viewModel.sortMode.rawValue
        )
    }

    var body: some View {
        ScrollView {
            VStack {
                MultiSelectionView(
                    title: String(localized: "Statuses", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.filterOptions",
                    options: statusFilterOptions
                )
                .tint(courseColor)
                MultiSelectionView(
                    title: String(localized: "Filter by Section", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.sectionOptions",
                    options: sectionFilterOptions
                )
                .tint(courseColor)
                SingleSelectionView(
                    title: String(localized: "Sort by", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.sortOrderOptions",
                    options: sortModeOptions
                )
            }
        }
        .background(Color.backgroundLightest)
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {

                        viewModel.statusFilters = selectedStatusFilters
                        viewModel.sectionFilters = selectedSectionFilters
                        viewModel.sortMode = selectedSortMode

                        controller.value.dismiss(animated: true)
                    },
                    label: {
                        Text("Done", bundle: .teacher)
                            .font(.semibold16)
                            .foregroundColor(color)
                    }
                )
            }

            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: { controller.value.dismiss(animated: true) },
                    label: {
                        Text("Cancel", bundle: .teacher)
                            .font(.regular16)
                            .foregroundColor(color)
                    }
                )
            }
        }
        .navigationBarTitleView(
            title: String(localized: "Submission List Preferences", bundle: .teacher),
            subtitle: viewModel.assignment?.name
        )
        .navigationBarStyle(.modal)
    }

    private var selectedStatusFilters: Set<SubmissionStatusFilter> {
        Set(
            statusFilterOptions.selected.value.compactMap({ SubmissionStatusFilter(rawValue: $0.id) })
        )
    }

    private var selectedSectionFilters: Set<String> {
        Set(
            sectionFilterOptions
                .selected
                .value
                .compactMap({ option in
                    viewModel.courseSections.first(where: { $0.id == option.id })?.id
                })
        )
    }

    private var selectedSortMode: SubmissionsSortMode {
        return sortModeOptions
            .selected
            .value
            .flatMap({ SubmissionsSortMode(rawValue: $0.id) })
        ?? .studentSortableName
    }

    private var color: Color {
        viewModel.course.flatMap { Color(uiColor: $0.color) } ?? .accentColor
    }
}

#if DEBUG

#Preview {
    SubmissionListAssembly.makeFilterScreenPreview()
}

#endif
