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
    // MARK: - Properties
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: AssignmentListPreferencesViewModel
    private let color: Color = .init(Brand.shared.primary)

    // MARK: - Init
    public init(viewModel: AssignmentListPreferencesViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                filterSection
                if viewModel.isTeacher {
                    statusFilterSectionTeacher
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

    // MARK: - Filter Section

    @ViewBuilder
    private var filterSection: some View {
        if viewModel.isTeacher {
            Section {
                ForEach(AssignmentFilterOptionsTeacher.allCases) { item in
                    filterItemTeacher(with: item)
                }
            } header: {
                InstUI.ListSectionHeader(title: String(localized: "Assignment Filter", bundle: .core))
            }
        } else {
            Section {
                ForEach(AssignmentFilterOptionStudent.allCases) { item in
                    filterItemStudent(with: item)
                }
            } header: {
                InstUI.ListSectionHeader(title: String(localized: "Assignment Filter", bundle: .core))
            }
        }
    }

    private func filterItemStudent(with item: AssignmentFilterOptionStudent) -> some View {
        var filterSelectionBinding: Binding<Bool> {
            Binding {
                viewModel.selectedAssignmentFilterOptionsStudent.contains(item)
            } set: { isSelected in
                viewModel.didSelectAssignmentFilterOption(item, isSelected: isSelected)
            }
        }

        return InstUI.CheckboxCell(
            title: item.title,
            isSelected: filterSelectionBinding,
            color: color
        )
        .accessibilityIdentifier("AssignmentFilter.filterItems.\(item.id)")
    }

    private func filterItemTeacher(with item: AssignmentFilterOptionsTeacher) -> some View {
        InstUI.RadioButtonCell(
            title: item.title,
            value: item,
            selectedValue: $viewModel.selectedFilterOptionTeacher,
            color: color
        )
        .accessibilityIdentifier("AssignmentFilter.customFilterOptions.\(item.rawValue)")
    }

    // MARK: - Status Filter Section

    private var statusFilterSectionTeacher: some View {
        Section {
            ForEach(AssignmentStatusFilterOptionsTeacher.allCases) { item in
                statusFilterItemTeacher(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Status Filter", bundle: .core))
        }
    }

    private func statusFilterItemTeacher(with item: AssignmentStatusFilterOptionsTeacher) -> some View {
        InstUI.RadioButtonCell(
            title: item.title,
            value: item,
            selectedValue: $viewModel.selectedStatusFilterOptionTeacher,
            color: color
        )
        .accessibilityIdentifier("AssignmentFilter.statusFilterOptions.\(item.rawValue)")
    }

    // MARK: - Sort By Section

    private var sortBySection: some View {
        OptionsSectionView(
            title: String(localized: "Grouped By", bundle: .core),
            options: viewModel.sortingOptionItems,
            selectionType: .single,
            selectedOption: viewModel.selectedSortingOptionItem
        )
        // TODO:
//        .accessibilityIdentifier("AssignmentFilter.sortByItems.\(item.rawValue)")
    }

    // MARK: - Grading Period Section

    private var gradingPeriodsSection: some View {
        OptionsSectionView(
            title: String(localized: "Grading Period", bundle: .core),
            options: viewModel.gradingPeriodItems,
            selectionType: .single,
            selectedOption: viewModel.selectedGradingPeriodItem
        )
        // TODO:
        //        .accessibilityIdentifier("AssignmentFilter.gradingPeriodItems.\(item.id ?? "0")")
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
