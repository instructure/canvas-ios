//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct AssignmentListPreferencesScreen: View {
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: AssignmentListPreferencesViewModel
    private let color: Color = .init(Brand.shared.primary)

    public init(viewModel: AssignmentListPreferencesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                if viewModel.isTeacher {
                    teacherFilterSection
                    teacherPublishStatusFilterSection
                } else {
                    studentFilterSection
                }

                sortBySection

                if viewModel.isGradingPeriodsSectionVisible {
                    gradingPeriodsSection
                }
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitleStyled(navBarTitleView)
        .navigationBarItems(leading: cancelButton, trailing: doneButton)
        .onDisappear {
            viewModel.didDismiss()
        }
    }

    private var cancelButton: some View {
        InstUI.NavigationBarButton.cancel {
            viewModel.didTapCancel(viewController: viewController)
        }
        .accessibilityIdentifier("AssignmentFilter.cancelButton")
    }

    private var doneButton: some View {
        InstUI.NavigationBarButton.done {
            viewModel.didTapDone(viewController: viewController)
        }
        .accessibilityIdentifier("AssignmentFilter.doneButton")
    }

    private var navBarTitleView: some View {
        VStack {
            Text(String(localized: "Assignment List Preferences", bundle: .core))
                .foregroundStyle(Color.textDarkest)
                .font(.semibold16)
            Text(viewModel.courseName)
                .foregroundStyle(Color.textDark)
                .font(.regular12)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var studentFilterSection: some View {
        MultiSelectionView(
            title: String(localized: "Assignment Filter", bundle: .core),
            accessibilityIdentifier: "AssignmentFilter.studentFilterOption",
            options: viewModel.studentFilterOptions,
            selectedOptions: viewModel.selectedStudentFilterOptions
        )
    }

    @ViewBuilder
    private var teacherFilterSection: some View {
        SingleSelectionView(
            title: String(localized: "Assignment Filter", bundle: .core),
            accessibilityIdentifier: "AssignmentFilter.teacherFilterOption",
            options: viewModel.teacherFilterOptions,
            selectedOption: viewModel.selectedTeacherFilterOption
        )
    }

    private var teacherPublishStatusFilterSection: some View {
        SingleSelectionView(
            title: String(localized: "Status Filter", bundle: .core),
            accessibilityIdentifier: "AssignmentFilter.teacherPublishStatusFilterOption",
            options: viewModel.teacherPublishStatusFilterOptions,
            selectedOption: viewModel.selectedTeacherPublishStatusFilterOption
        )
    }

    private var sortBySection: some View {
        SingleSelectionView(
            title: String(localized: "Grouped By", bundle: .core),
            accessibilityIdentifier: "AssignmentFilter.sortMode",
            options: viewModel.sortModeOptions,
            selectedOption: viewModel.selectedSortModeOption
        )
    }

    private var gradingPeriodsSection: some View {
        SingleSelectionView(
            title: String(localized: "Grading Period", bundle: .core),
            accessibilityIdentifier: "AssignmentFilter.gradingPeriodOption",
            options: viewModel.gradingPeriodOptions,
            selectedOption: viewModel.selectedGradingPeriodOption
        )
    }
}

#if DEBUG

struct AssignmentFilterScreen_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static func createGradingPeriods() -> [GradingPeriod] {
        let gradingPeriods = [
            APIGradingPeriod.make(id: "1", title: "Summer"),
            APIGradingPeriod.make(id: "2", title: "Autumn"),
            APIGradingPeriod.make(id: "3", title: "Winter")
        ]
        return gradingPeriods.map {
            GradingPeriod.save($0, courseID: "1", in: context)
        }
    }

    static var previews: some View {
        let gradingPeriods = createGradingPeriods()
        let viewModel = AssignmentListPreferencesViewModel(
            isTeacher: false,
            initialFilterOptionsStudent: AssignmentFilterOptionStudent.allCases,
            initialStatusFilterOptionTeacher: .allAssignments,
            initialFilterOptionTeacher: .allAssignments,
            sortingOptions: AssignmentListViewModel.AssignmentArrangementOptions.allCases,
            initialSortingOption: AssignmentListViewModel.AssignmentArrangementOptions.dueDate,
            gradingPeriods: gradingPeriods,
            initialGradingPeriod: nil,
            courseName: "Sample Course Name",
            env: AppEnvironment.shared,
            completion: { _ in })
        AssignmentListPreferencesScreen(viewModel: viewModel)
    }
}

#endif
