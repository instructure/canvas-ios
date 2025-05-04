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

enum SubmissionFilter: CaseIterable {
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
}

struct SubmissionsFilterView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilter: SubmissionFilter? = .all

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

                ForEach(SubmissionFilter.allCases, id: \.self) { filter in
                    InstUI.RadioButtonCell(
                        title: filter.title,
                        value: filter,
                        selectedValue: $selectedFilter,
                        color: .green
                    )
                }

                Spacer()
            }
            .background(Color.backgroundLightest)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleView(title: "Submission list Preferences", subtitle: "Some course")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { dismiss() }, label: {
                        Text("Done", bundle: .teacher)
                            .font(.semibold16)
                            .foregroundColor(Color.pink)
                    })
                }

                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: { dismiss() }, label: {
                        Text("Cancel", bundle: .teacher)
                            .font(.regular16)
                            .foregroundColor(Color.pink)
                        //.padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
                    })
                }
            }
        }
    }
}

