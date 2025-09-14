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
    private let filterOptions: MultiSelectionOptions
    private let courseColor: Color

    init(viewModel: SubmissionListViewModel) {
        self.viewModel = viewModel

        courseColor = viewModel.course.flatMap { Color(uiColor: $0.color) } ?? Color(Brand.shared.primary)

        let initialSelection = Set(viewModel.statusFilters.map({ OptionItem(id: $0.rawValue, title: $0.name) }))
        let allOptions = viewModel.statusFilterOptions.map({ OptionItem(id: $0.rawValue, title: $0.name) })

        self.filterOptions = MultiSelectionOptions(
            all: allOptions,
            initial: initialSelection
        )
    }

    var body: some View {
        VStack {
            MultiSelectionView(
                title: String(localized: "Submission Filter", bundle: .teacher),
                identifierGroup: "SubmissionsFilter.filterOptions",
                options: filterOptions
            )
            .tint(courseColor)
            Spacer()
        }
        .background(Color.backgroundLightest)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.statusFilters = selectedFilters
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

    private var selectedFilters: [SubmissionStatusFilter] {
        filterOptions.selected.value.compactMap({ SubmissionStatusFilter(rawValue: $0.id) })
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
