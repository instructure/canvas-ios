//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct SubmissionGrades: View {
    let assignment: Assignment
    let submission: Submission

    @State var isSaving = false

    var hasLateDeduction: Bool {
        submission.late && (submission.pointsDeducted ?? 0) > 0
    }

    var body: some View {
        if assignment.moderatedGrading {
            GeometryReader { geometry in
                ScrollView {
                    EmptyPanda(.Unsupported, message: Text("Moderated Grading Unsupported"))
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
            }
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Grade")
                        Spacer()
                        Button(action: {}, label: {
                            grade
                        })
                        if submission.grade?.isEmpty == false, submission.postedAt == nil {
                            Icon.offLine.foregroundColor(.textDanger)
                                .padding(.leading, 12)
                        }
                    }
                        .font(.heavy24)
                        .foregroundColor(hasLateDeduction ? .textDark : .textDarkest)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    Divider()
                }
            }
        }
    }

    @ViewBuilder
    var grade: some View {
        if assignment.gradingType == .not_graded {
            Text("Not Graded")
        } else if isSaving {
            CircleProgress(size: 24)
        } else if submission.excused == true {
            Text("Excused")
        } else if submission.grade?.isEmpty == false {
            Text(GradeFormatter.longString(for: assignment, submission: submission, final: false))
        } else {
            Icon.addSolid.foregroundColor(Color(Brand.shared.linkColor))
        }
    }
}
