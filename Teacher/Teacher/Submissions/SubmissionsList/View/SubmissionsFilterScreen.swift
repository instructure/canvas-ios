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

    @State
    private var scoredMoreFilterValue: String = ""
    @State
    private var scoredLessFilterValue: String = ""

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

        _scoredMoreFilterValue = .init(
            initialValue: viewModel
                .scoreBasedFilters
                .moreThanFilter
                .flatMap({ viewModel.toScoreInputValue($0.score) })?
                .formatted(.number.precision(.fractionLength(0 ... 3))) ?? ""
        )

        _scoredLessFilterValue = .init(
            initialValue: viewModel
                .scoreBasedFilters
                .lessThanFilter
                .flatMap({ viewModel.toScoreInputValue($0.score) })?
                .formatted(.number.precision(.fractionLength(0 ... 3))) ?? ""
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MultiSelectionView(
                    title: String(localized: "Statuses", bundle: .teacher),
                    identifierGroup: "SubmissionsFilter.filterOptions",
                    options: statusFilterOptions
                )
                .tint(courseColor)

                if let gradeInputType = viewModel.gradeInputType {

                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            GradeInputTextFieldCell(
                                title: String(localized: "Scored More than", bundle: .teacher),
                                inputType: gradeInputType,
                                pointsPossibleText: viewModel.pointsPossibleText,
                                pointsPossibleAccessibilityText: viewModel.pointsPossibleAccessibilityText,
                                isExcused: false,
                                text: $scoredMoreFilterValue,
                                isSaving: .init(false)
                            )
                            InstUI.Divider(.padded)
                            GradeInputTextFieldCell(
                                title: String(localized: "Scored Less than", bundle: .teacher),
                                inputType: gradeInputType,
                                pointsPossibleText: viewModel.pointsPossibleText,
                                pointsPossibleAccessibilityText: viewModel.pointsPossibleAccessibilityText,
                                isExcused: false,
                                text: $scoredLessFilterValue,
                                isSaving: .init(false)
                            )
                        }

                    } header: {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Precise filtering", bundle: .teacher)
                                .textStyle(.sectionHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .paddingStyle(set: .sectionHeader)
                                .accessibilityAddTraits([.isHeader])
                            InstUI.Divider()
                        }
                    }
                }

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
                        viewModel.scoreBasedFilters = selectedScoreBasedFilters
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

    private var selectedScoreBasedFilters: Set<GetSubmissions.Filter.Score> {
        var filters = Set<GetSubmissions.Filter.Score>()
        if let moreThanValue = scoredMoreFilterValue.doubleValueByFixingDecimalSeparator {
            filters.insert(.moreThan(viewModel.toScoreValue(moreThanValue)))
        }
        if let lessThanValue = scoredLessFilterValue.doubleValueByFixingDecimalSeparator {
            filters.insert(.lessThan(viewModel.toScoreValue(lessThanValue)))
        }
        return filters
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
