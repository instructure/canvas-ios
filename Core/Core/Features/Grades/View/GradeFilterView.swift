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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if viewModel.isShowGradingPeriodsView {
                    gradingPeriodSection
                }
                sortBySection
            }
            .navigationBarTitleView(
                title: String(localized: "Grade List Preferences", bundle: .core),
                subtitle: viewModel.courseName
            )
            .navigationBarItems(leading: cancelButton, trailing: sendButton)
            .navigationBarStyle(.modal)
        }
        .background(Color.backgroundLightest)
    }

    private var gradingPeriodSection: some View {
        SingleSelectionView(
            title: String(localized: "Grading Periods", bundle: .core),
            accessibilityIdentifier: "GradeFilter.gradingPeriodOptions",
            options: viewModel.gradingPeriodOptions
        )
    }

    private var sortBySection: some View {
        SingleSelectionView(
            title: String(localized: "Grouped By", bundle: .core),
            accessibilityIdentifier: "GradeFilter.sortModeOptions",
            options: viewModel.sortModeOptions
        )
    }

    private var sendButton: some View {
        Button {
            viewModel.saveButtonTapped(viewController: viewController)
        } label: {
            Text(String(localized: "Done", bundle: .core))
                .font(.semibold16)
                .foregroundColor(viewModel.saveButtonIsEnabled
                                 ? .textDarkest
                                 : .disabledGray)

        }
        .disabled(!viewModel.saveButtonIsEnabled)
        .accessibilityIdentifier("GradeFilter.saveButton")
    }

    private var cancelButton: some View {
        Button {
            viewModel.dimiss(viewController: viewController)
        } label: {
            Text(String(localized: "Cancel", bundle: .core))
                .font(.semibold16)
        }
    }
}

#if DEBUG
#Preview {
    GradeFilterView(
        viewModel: GradeFilterViewModel(
            dependency: .init(
                router: AppEnvironment.shared.router,
                isShowGradingPeriod: false,
                sortByOptions: GradeArrangementOptions.allCases
            ),
            gradeFilterInteractor: GradeFilterInteractorLive(
                appEnvironment: .shared,
                courseId: "12"
            )
        )
    )
}
#endif
