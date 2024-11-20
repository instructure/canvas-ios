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
                if viewModel.isFilterSectionVisible {
                    filterSection
                }
                sortBySection
                if viewModel.isGradingPeriodsSectionVisible {
                    gradingPeriodsSection
                }
            }
        }
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

    private var filterSection: some View {
        Section {
            ForEach(AssignmentFilterOption.allCases, id: \.id) { item in
                filterItem(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Assignment Filter", bundle: .core))
        }
    }

    private func filterItem(with item: AssignmentFilterOption) -> some View {
        var filterSelectionBinding: Binding<Bool> {
            Binding {
                viewModel.selectedAssignmentFilterOptions.contains(item)
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

    // MARK: - Sort By Section

    private var sortBySection: some View {
        Section {
            ForEach(viewModel.sortingOptions, id: \.self) { item in
                sortByItem(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Grouped By", bundle: .core))
        }
    }

    private func sortByItem(with item: AssignmentListViewModel.AssignmentArrangementOptions) -> some View {
        InstUI.RadioButtonCell(
            title: item.title,
            value: item,
            selectedValue: $viewModel.selectedSortingOption,
            color: color
        )
        .accessibilityIdentifier("AssignmentFilter.sortByItems.\(item.rawValue)")
    }

    // MARK: - Grading Period Section

    private var gradingPeriodsSection: some View {
        Section {
            InstUI.RadioButtonCell(title: "All Grading Periods", value: nil, selectedValue: $viewModel.selectedGradingPeriod, color: Color(Brand.shared.primary))
            ForEach(viewModel.gradingPeriods, id: \.hashValue) { item in
                gradingPeriodItem(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Grading Period", bundle: .core))
        }
    }

    private func gradingPeriodItem(with item: GradingPeriod) -> some View {
        InstUI.RadioButtonCell(
            title: item.title ?? "",
            value: item,
            selectedValue: $viewModel.selectedGradingPeriod,
            color: color
        )
        .accessibilityIdentifier("AssignmentFilter.gradingPeriodItems.\(item.id ?? "0")")
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
