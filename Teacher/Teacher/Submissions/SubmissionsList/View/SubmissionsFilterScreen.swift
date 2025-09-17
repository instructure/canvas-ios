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

    private let viewModel: SubmissionsFilterViewModel

    init(listViewModel: SubmissionListViewModel) {
        self.viewModel = SubmissionsFilterViewModel(listViewModel: listViewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MultiSelectionView(
                    title: String(localized: "Statuses", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.statusOptions",
                    options: viewModel.statusFilterOptions
                )
                .tint(viewModel.courseColor)
                MultiSelectionView(
                    title: String(localized: "Filter by Section", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.sectionOptions",
                    options: viewModel.sectionFilterOptions
                )
                .tint(viewModel.courseColor)
            }
        }
        .background(Color.backgroundLightest)
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.saveSelection()
                        controller.value.dismiss(animated: true)
                    },
                    label: {
                        Text("Done", bundle: .teacher)
                            .font(.semibold16)
                            .foregroundColor(viewModel.courseColor)
                    }
                )
            }

            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: { controller.value.dismiss(animated: true) },
                    label: {
                        Text("Cancel", bundle: .teacher)
                            .font(.regular16)
                            .foregroundColor(viewModel.courseColor)
                    }
                )
            }
        }
        .navigationBarTitleView(
            title: String(localized: "Submission List Preferences", bundle: .teacher),
            subtitle: viewModel.assignmentName
        )
        .navigationBarStyle(.modal)
    }
}

#if DEBUG

#Preview {
    SubmissionListAssembly.makeFilterScreenPreview()
}

#endif
