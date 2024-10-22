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

    // MARK: - Init
    public init(viewModel: AssignmentListPreferencesViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                if viewModel.isStudentApp {
                    filterSection
                }
                sortBySection
                if viewModel.isGradingPeriodsSectionVisible {
                    gradingPeriodsSection
                }
            }
            .navigationTitleStyled(navBarTitleView)
            .navigationBarItems(trailing: doneButton)
        }
    }

    private var navBarTitleView: some View {
        VStack {
            Text(String(localized: "Assignment List Preferences", bundle: .core))
                .foregroundStyle(Color.textDarkest)
                .font(.semibold16)
            Text(viewModel.courseName ?? "")
                .foregroundStyle(Color.textDark)
                .font(.regular12)
        }
    }

    private var doneButton: some View {
        InstUI.NavigationBarButton.done {
            viewModel.doneButtonTapped(viewController: viewController)
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Done", bundle: .core))
        .accessibilityIdentifier("AssignmentFilter.doneButton")
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
        InstUI.CheckboxCell(
            title: item.title,
            isSelected: selectionBinding(option: item),
            color: Color(Brand.shared.primary),
            subtitle: item.subtitle
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

    private func sortByItem(with item: AssignmentArrangementOptions) -> some View {
        InstUI.RadioButtonCell(
            title: item.title,
            value: item,
            selectedValue: $viewModel.selectedSortingOption,
            color: Color(Brand.shared.primary)
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
            color: Color(Brand.shared.primary)
        )
        .accessibilityIdentifier("AssignmentFilter.gradingPeriodItems.\(item.id ?? "0")")
    }

    // MARK: - Additional functions

    private func selectionBinding(option: AssignmentFilterOption) -> Binding<Bool> {
        Binding {
            viewModel.selectedAssignmentFilterOptions.contains(option)
        } set: { isSelected in
            viewModel.didSelectAssignmentFilterOption(option: option, isSelected: isSelected)
        }
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
        // swiftlint:disable:next redundant_discardable_let
        let _ = UITableView.setupDefaultSectionHeaderTopPadding()

        let gradingPeriods = createGradingPeriods()
        let viewModel = AssignmentListPreferencesViewModel(
            gradingPeriods: gradingPeriods,
            initialGradingPeriod: nil,
            sortingOptions: AssignmentArrangementOptions.allCases,
            initialSortingOption: AssignmentArrangementOptions.dueDate,
            courseId: "1",
            courseName: "Sample Course Name",
            completion: { _ in })
        AssignmentListPreferencesScreen(viewModel: viewModel)
    }
}

#endif
