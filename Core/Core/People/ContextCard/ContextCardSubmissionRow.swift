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

struct ContextCardSubmissionRow: View {
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color(hexString: "#008EE2")!, Color(hexString: "#00C1F3")!]), startPoint: .leading, endPoint: .trailing)
    private let assignment: Assignment
    private let submission: Submission
    private let progressRatio: CGFloat
    private let grade: String
    private let icon: Icon

    var body: some View {
        Button(action: { /*route to */}, label: {
            HStack(alignment: .top, spacing: 0) {
                icon
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 12))
                VStack(alignment: .leading, spacing: 8) {
                    Text(assignment.name)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .lineLimit(2)
                    Text(submission.status.text)
                        .font(.semibold14).foregroundColor(.textDark)
                    progressView(progress: progressRatio, label: Text(grade))
                }
            }
        })
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    init(assignment: Assignment, submission: Submission) {
        self.assignment = assignment
        self.submission = submission
        self.progressRatio =  {
            guard let score = submission.score, let maxPoints = assignment.pointsPossible, maxPoints > 0 else {
                return 0
            }
            return CGFloat(min(1, score / maxPoints))
        }()
        self.grade = {
            GradeFormatter.gradeString(for: assignment, submission: submission) ?? ""
        }()
        self.icon = {
            if assignment.submissionTypes.contains(.online_quiz) {
                return .quizLine
            } else if assignment.submissionTypes.contains(.discussion_topic) {
                return .discussionLine
            } else {
                return .assignmentLine
            }
        }()
    }

    private func progressView(progress: CGFloat, label: Text) -> some View {
        HStack {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    let gradientWidth = proxy.size.width * progress
                    Rectangle()
                        .fill(gradient)
                        .frame(width: gradientWidth)
                    Rectangle()
                        .fill(Color.backgroundLight)
                        .frame(width: proxy.size.width - gradientWidth)

                }
            }.frame(height: 18)
            label.foregroundColor(.textDark).font(.semibold14)
        }
    }
}

#if DEBUG
struct ContextCardSubmissionRow_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext
    static var testData: [Submission] {
        let submission = Submission(context: context)
        submission.submittedAt = Date()
        submission.score = 1
        let excused = Submission(context: context)
        excused.excused = true
        return [submission, excused]
    }

    static var previews: some View {
        let assignment = Assignment(context: context)
        assignment.name = "Test Assignment"
        assignment.pointsPossible = 10
        assignment.gradingType = .points
        return ForEach(testData) { submission in
            ContextCardSubmissionRow(assignment: assignment, submission: submission).previewLayout(.sizeThatFits)
        }
    }
}
#endif
