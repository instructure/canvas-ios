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

import HorizonUI
import SwiftUI

struct ScoresAssignmentsView: View {
    let details: ScoreDetails
    @Binding var selectedSortOption: String
    @State private var selectionSortFocused: Bool = false
    let openAssignmentDetails: (URL?) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            HorizonUI.SingleSelect(
                selection: $selectedSortOption,
                focused: $selectionSortFocused,
                label: String(localized: "Sort By", bundle: .horizon),
                options: ScoreDetails.SortOption.allCases.map(\.localizedTitle)
            )
            .padding(.horizontal, .huiSpaces.space16)
            .padding(.top, .huiSpaces.space16)
            VStack(spacing: .zero) {
                ForEach(Array(details.assignments.enumerated()), id: \.offset) { index, assignment in
                    VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                        Text("Name: \(assignment.name)", bundle: .horizon)
                        if let dueAtString = assignment.dueAtString {
                            Text("Due Date: \(dueAtString)", bundle: .horizon)
                        }

                        let submissionStatus = assignment.status
                        HStack(spacing: .huiSpaces.space4) {
                            Text("Status: ", bundle: .horizon)
                            HorizonUI.Pill(
                                title: submissionStatus.text,
                                style: submissionStatus == .missing ? .outline(.danger) : .outline(.institution),
                                isUppercased: false,
                                icon: nil
                            )
                        }
                        Text("Result: \(assignment.pointsResult)", bundle: .horizon)
                        HStack(spacing: .huiSpaces.space4) {
                            Text("Feedback: ", bundle: .horizon)
                            if assignment.commentsCount > 0 {
                                if assignment.isRead {
                                    HorizonUI.icons.chat
                                        .frame(width: 24, height: 24)
                                } else {
                                    HorizonUI.icons.markUnreadChat
                                        .frame(width: 24, height: 24)
                                }
                                Text(String(assignment.commentsCount))
                            } else {
                                Text("-")
                            }
                        }
                    }
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .bottom], .huiSpaces.space16)
                    .onTapGesture {
                        openAssignmentDetails(assignment.htmlUrl)
                    }

                    if index != details.assignments.count - 1 {
                        divider
                    }
                }
                Spacer()
            }
            .padding(.vertical, .huiSpaces.space8)
            .padding(.horizontal, .huiSpaces.space24)
        }
        .background(Color.huiColors.primitives.white10)
        .huiCornerRadius(level: .level5)
    }

    private var divider: some View {
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .foregroundColor(Color.huiColors.surface.divider)
    }
}

#Preview {
    ScoresAssignmentsView(details: .init(
        score: "",
        assignmentGroups: [
            .init(id: "1", name: "1", groupWeight: 1, assignments: [
                ScoresAssignment(
                    id: "2",
                    name: "iOS Debugging Quiz",
                    commentsCount: 0,
                    dueAt: Date().addingTimeInterval(172800),
                    htmlUrl: URL(string: "https://dev.ce.com/assignment2"),
                    pointsPossible: 50,
                    score: nil,
                    state: "not_submitted",
                    isRead: false,
                    isExcused: false,
                    isLate: false,
                    isMissing: true,
                    submittedAt: nil
                ),
                ScoresAssignment(
                    id: "1",
                    name: "Essay on SwiftUI",
                    commentsCount: 3,
                    dueAt: Date().addingTimeInterval(86400),
                    htmlUrl: URL(string: "https://dev.cd.com/assignment1"),
                    pointsPossible: 100,
                    score: 95,
                    state: "graded",
                    isRead: true,
                    isExcused: false,
                    isLate: false,
                    isMissing: false,
                    submittedAt: Date().addingTimeInterval(-3600)
                )
            ])
        ],
        sortOption: .dueDate
    ),
    selectedSortOption: .constant("Due Date"),
    openAssignmentDetails: { _ in })
}
