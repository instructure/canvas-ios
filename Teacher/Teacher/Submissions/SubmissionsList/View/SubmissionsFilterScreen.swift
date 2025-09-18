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

                if let gradeInputType = viewModel.gradeInputType {

                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            GradeInputTextFieldCell(
                                title: String(localized: "Scored More than", bundle: .teacher),
                                inputType: gradeInputType,
                                pointsPossibleText: viewModel.pointsPossibleText,
                                pointsPossibleAccessibilityText: viewModel.pointsPossibleAccessibilityText,
                                isExcused: false,
                                text: viewModel.scoredMoreFilterValue.binding,
                                isSaving: .init(false)
                            )
                            InstUI.Divider(.padded)
                            GradeInputTextFieldCell(
                                title: String(localized: "Scored Less than", bundle: .teacher),
                                inputType: gradeInputType,
                                pointsPossibleText: viewModel.pointsPossibleText,
                                pointsPossibleAccessibilityText: viewModel.pointsPossibleAccessibilityText,
                                isExcused: false,
                                text: viewModel.scoredLessFilterValue.binding,
                                isSaving: .init(false)
                            )
                        }

                    } header: {
                        InstUI.ListSectionHeader(
                            title: String(localized: "Precise filtering", bundle: .teacher),
                            itemCount: 2
                        )
                    }
                }

                if let sectionOptions = viewModel.sectionFilterOptions {
                    MultiSelectionView(
                        title: String(localized: "Filter by Section", bundle: .teacher),
                        identifierGroup: "SubmissionsFilter.sectionOptions",
                        options: sectionOptions
                    )
                }

                if viewModel.differentiationTagFilterOptions.all.isNotEmpty {
                    MultiSelectionView(
                        title: String(localized: "Differentiation Tags", bundle: .teacher),
                        identifierGroup: "SubmissionsFilter.diffTagOptions",
                        options: viewModel.differentiationTagFilterOptions
                    )
                    .tint(viewModel.courseColor)
                }

                SingleSelectionView(
                    title: String(localized: "Sort by", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.sortByOptions",
                    options: viewModel.sortModeOptions
                )
            }
            .tint(viewModel.courseColor)
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
