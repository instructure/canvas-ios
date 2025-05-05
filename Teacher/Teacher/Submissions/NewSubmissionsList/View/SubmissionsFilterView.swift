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

enum SubmissionFilterMode: CaseIterable {
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

    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var viewModel: SubmissionListViewModel
    @State private var selectedFilterMode: SubmissionFilterMode? = .all

    init(viewModel: SubmissionListViewModel) {
         self.viewModel = viewModel
        self._selectedFilterMode = State(initialValue: viewModel.filterMode)
    }

    private var color: Color {
        Color(uiColor: viewModel.course?.color ?? UIColor.gray)
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 8) {
                    Divider()
                    Text("Submission Filter", bundle: .teacher)
                        .font(.semibold14)
                        .foregroundStyle(Color.textDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    Divider()
                }

                ForEach(SubmissionFilterMode.allCases, id: \.self) { mode in
                    InstUI.RadioButtonCell(
                        title: mode.title,
                        value: mode,
                        selectedValue: $selectedFilterMode,
                        color: color
                    )
                }

                Spacer()
            }
            .background(Color.backgroundLightest)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleView(title: "Submission list Preferences", subtitle: viewModel.assignment?.name)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.filterMode = selectedFilterMode ?? .all
                        dismiss()
                    }, label: {
                        Text("Done", bundle: .teacher)
                            .font(.semibold16)
                            .foregroundColor(color)
                    })
                }

                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: { dismiss() }, label: {
                        Text("Cancel", bundle: .teacher)
                            .font(.regular16)
                            .foregroundColor(color)
                    })
                }
            }
        }
    }
}
