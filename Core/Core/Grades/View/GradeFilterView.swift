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

public struct GradeFilterView: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: GradeFilterViewModel

    // MARK: - Init
    public init(viewModel: GradeFilterViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isShowGradingPeriodsView {
                    gradingPeriodSection
                }
                sortBySection
            }
            .navigationBarItems(leading: cancelButton, trailing: sendButton)
            .navigationTitle(String(localized: "Grade Preferences", bundle: .core), subtitle: viewModel.courseName)
        }
    }

    private var gradingPeriodSection: some View {
        Section {
            ForEach(viewModel.gradingPeriods, id: \.hashValue) { item in
                gradingPeriodItem(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Grading Period", bundle: .core))
        }
    }

    private func gradingPeriodItem(with item: GradeFilterViewModel.GradePeriod) -> some View {
        InstUI.RadioButtonCell(
            title: item.title ?? String(localized: "All", bundle: .core),
            value: item,
            selectedValue: $viewModel.selectedGradingPeriod,
            color: Color(Brand.shared.primary)
        )
    }

    private var sortBySection: some View {
        Section {
            ForEach(viewModel.sortByOptions, id: \.self) { item in
                sortByItem(with: item)
            }
        } header: {
            InstUI.ListSectionHeader(title: String(localized: "Sort By", bundle: .core))
        }
    }

    private func sortByItem(with item: GradeArrangementOptions) -> some View {
        InstUI.RadioButtonCell(
            title: item.title,
            value: item,
            selectedValue: $viewModel.selectedSortByOption,
            color: Color(Brand.shared.primary)
        )
    }

    private var sendButton: some View {
        Button {
            viewModel.saveButtonTapped(viewController: viewController)
        } label: {
            Text(String(localized: "Save", bundle: .core))
                .font(.semibold16)
                .foregroundColor(viewModel.saveButtonIsEnabled
                                 ? .textDarkest
                                 : .disabledGray)

        }
        .disabled(!viewModel.saveButtonIsEnabled)
    }

    private var cancelButton: some View {
        Button {
            viewModel.dimiss(viewController: viewController)
        } label: {
            Image.xLine
                .accessibilityHidden(true)
                .accessibilityLabel(Text("Hide", bundle: .core))
        }
    }
}

#if DEBUG
#Preview {
    var dependency: GradeFilterViewModel.Dependency = .init(
        router: AppEnvironment.shared.router,
        isShowGradingPeriod: false,
        selectedSortBy: GradeArrangementOptions.dueDate,
        sortByOptions: GradeArrangementOptions.allCases
    )
    let viewModel = GradeFilterViewModel(dependency: dependency)
    return GradeFilterView(viewModel: viewModel)
}
#endif
