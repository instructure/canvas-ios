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

    @State private var selectedSortOption = "Due Date"

    var body: some View {
        VStack(spacing: .zero) {
            Text("Sort By")
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.body)
                .padding([.top, .leading, .trailing], .huiSpaces.space24)
                .frame(maxWidth: .infinity, alignment: .leading)

            HorizonUI.SingleSelect(
                selection: $selectedSortOption,
                options: ["Due Date", "Assignment Name"]
            ) {
                VStack(spacing: .zero) {
                    ForEach(Array(details.assignments.enumerated()), id: \.offset) { index, assignment in
                        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                            Text("Name: \(assignment.name)", bundle: .horizon)
                            if let dueAtString = assignment.dueAtString {
                                Text("Due Date: \(dueAtString)", bundle: .horizon)
                            }

                            HStack(spacing: .huiSpaces.space4) {
                                Text("Status: ")
                                HorizonUI.Pill(
                                    title: "Submitted",
                                    //                            title: assignment.latestSubmission?.status,
                                    style: .outline(.danger),
                                    isUppercased: false,
                                    icon: nil
                                )
                            }
                            Text("Result: XX/XX")
                            //                    Text("Result: \(assignment.result)", bundle: .horizon)
                            HStack(spacing: .huiSpaces.space4) {
                                Text("Feedback: ", bundle: .horizon)
                                HorizonUI.icons.chat
                                    .frame(width: 24, height: 24)
                                Text("1")
                                //                        Text("\(assignment.latestSubmissionCommentCount)")
                            }
                        }
                        .huiTypography(.p1)
                        .foregroundStyle(Color.huiColors.text.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding([.leading, .trailing], .huiSpaces.space24)
                        .padding([.top, .bottom], .huiSpaces.space16)

                        if index != details.assignments.count - 1 {
                            divider
                        }
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
                .init(
                    id: "1",
                    name: "First assignment",
                    details: nil,
                    pointsPossible: 10,
                    dueAt: Date.now,
                    allowedAttempts: 10,
                    submissionTypes: [],
                    courseID: "1",
                    courseName: "Course 1",
                    workflowState: nil,
                    submittedAt: Date.now,
                    submissions: []
                ),
                .init(
                    id: "2",
                    name: "Second assignment",
                    details: nil,
                    pointsPossible: 5,
                    dueAt: Date.now,
                    allowedAttempts: 10,
                    submissionTypes: [],
                    courseID: "1",
                    courseName: "Course 1",
                    workflowState: nil,
                    submittedAt: Date.now,
                    submissions: []
                )
            ])
        ]
    ))
}
