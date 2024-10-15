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

public struct AssignmentFilterScreen: View {
    // MARK: - Properties
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: AssignmentFilterViewModel

    // MARK: - Init
    public init(viewModel: AssignmentFilterViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if viewModel.isGradingPeriodsSectionVisible {
                    gradingPeriodsSection
                }
                sortBySection
            }
            .navigationTitleStyled(navBarTitleView)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }

    private var navBarTitleView: some View {
        VStack {
            Text(String(localized: "Assignment Preferences", bundle: .core))
                .foregroundStyle(Color.textDarkest)
                .font(.semibold16)
            Text(viewModel.courseName ?? "")
                .foregroundStyle(Color.textDark)
                .font(.regular12)
        }
    }

    private var gradingPeriodsSection: some View {
        Section {
            InstUI.RadioButtonCell(title: "All", value: nil, selectedValue: $viewModel.selectedGradingPeriod, color: Color(Brand.shared.primary))
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

    private var sortBySection: some View {
        Section {
            ForEach(viewModel.sortingOptions, id: \.self) { item in
                sortByItem(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Sort By", bundle: .core))
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

    private var saveButton: some View {
        InstUI.NavigationBarButton.save(isEnabled: viewModel.isSaveButtonEnabled) {
            viewModel.saveButtonTapped(viewController: viewController)
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Save", bundle: .core))
        .accessibilityIdentifier("AssignmentFilter.saveButton")
    }

    private var saveButton2: some View {
        Button {
            viewModel.saveButtonTapped(viewController: viewController)
        } label: {
            Text(String(localized: "Save", bundle: .core))
                .font(.semibold16)
                .foregroundColor(viewModel.isSaveButtonEnabled
                                 ? .textDarkest
                                 : .disabledGray)

        }
        .disabled(!viewModel.isSaveButtonEnabled)
    }

    private var cancelButton: some View {
        InstUI.NavigationBarButton.cancel {
            viewModel.dismiss(viewController: viewController)
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Cancel", bundle: .core))
        .accessibilityIdentifier("AssignmentFilter.cancelButton")
    }

    private var cancelButton2: some View {
        Button {
            viewModel.dismiss(viewController: viewController)
        } label: {
            Image.xLine
                .padding(5)
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Hide", bundle: .core))
    }
}

#if DEBUG

struct AssignmentFilterScreen_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static func createGradingPeriods() -> [GradingPeriod] {
        let gradingPeriods = [
            APIGradingPeriod.make(id: "1", title: "Period X"),
            APIGradingPeriod.make(id: "2", title: "Period Y")
        ]
        return gradingPeriods.map {
            GradingPeriod.save($0, courseID: "1", in: context)
        }
    }

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = UITableView.setupDefaultSectionHeaderTopPadding()

        let gradingPeriods = createGradingPeriods()
        let viewModel = AssignmentFilterViewModel(
            gradingPeriods: gradingPeriods,
            initialGradingPeriod: nil,
            sortingOptions: AssignmentArrangementOptions.allCases,
            initialSortingOption: AssignmentArrangementOptions.groupName,
            courseName: "Sample Course Name",
            completion: { _ in })
        AssignmentFilterScreen(viewModel: viewModel)
    }
}

#endif
