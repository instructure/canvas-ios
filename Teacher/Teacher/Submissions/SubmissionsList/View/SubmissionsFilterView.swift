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

enum SubmissionFilterMode: String, CaseIterable {
    case all
    case needsGrading
    case notSubmitted
    case graded

    var title: String {
        switch self {
        case .all:
            String(localized: "All Submissions", bundle: .teacher)
        case .needsGrading:
            String(localized: "Needs Grading", bundle: .teacher)
        case .notSubmitted:
            String(localized: "Not Submitted", bundle: .teacher)
        case .graded:
            String(localized: "Graded", bundle: .teacher)
        }
    }

    var filters: [GetSubmissions.Filter] {
        switch self {
        case .all:
            return []
        case .needsGrading:
            return [.needsGrading]
        case .notSubmitted:
            return [.notSubmitted]
        case .graded:
            return [.graded]
        }
    }
}

struct SubmissionsFilterView: View {

    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: SubmissionListViewModel
    private let filterOptions: SingleSelectionOptions

    init(viewModel: SubmissionListViewModel) {
        self.viewModel = viewModel

        let color = viewModel.course.flatMap({ Color(uiColor: $0.color) })
        let initialMode = viewModel.filterMode

        self.filterOptions = SingleSelectionOptions(
            all: SubmissionFilterMode.allCases.map {
                OptionItem(id: $0.rawValue, title: $0.title, color: color)
            },
            initial: OptionItem(id: initialMode.rawValue, title: initialMode.title)
        )
    }

    var body: some View {
        VStack {
            SingleSelectionView(
                title: String(localized: "Submission Filter", bundle: .core),
                accessibilityIdentifier: "SubmissionsFilter.filterOptions",
                options: filterOptions
            )
            Spacer()
        }
        .background(Color.backgroundLightest)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.filterMode = selectedFilterMode
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
        .navigationBarStyle(.modal)
        .navigationBarTitleView(
            title: "Submission list Preferences",
            subtitle: viewModel.assignment?.name
        )
    }

    private var selectedFilterMode: SubmissionFilterMode {
        guard
            let modeID = filterOptions.selected.value?.id,
            let mode = SubmissionFilterMode(rawValue: modeID)
        else { return .all }
        return mode
    }

    private var color: Color {
        viewModel.course.flatMap({ Color(uiColor: $0.color) }) ?? .accentColor
    }
}
