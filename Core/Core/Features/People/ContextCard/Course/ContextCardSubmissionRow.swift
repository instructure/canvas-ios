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
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    private let gradient = LinearGradient(gradient: Gradient(colors: [Color(hexString: "#008EE2")!, Color(hexString: "#00C1F3")!]), startPoint: .leading, endPoint: .trailing)
    private let assignment: Assignment
    private let submission: Submission
    private let progressRatio: CGFloat
    private let grade: String
    private let icon: Image
    private let a11ySubmissionStatus: String

    var body: some View {
        Button(action: navigateToAssignment) {
            HStack(alignment: .top, spacing: 0) {
                icon.padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 12))
                VStack(alignment: .leading, spacing: 8) {
                    Text(assignment.name)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(submission.status.text)
                        .font(.regular14).foregroundColor(Color(submission.status.color))
                    if submission.needsGrading {
                        needsGradingCapsule()
                    } else if submission.workflowState == .graded, submission.score != nil {
                        progressView(progress: progressRatio, label: Text(grade))
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .accessibility(label: Text("Submission \(assignment.name), \(submission.status.text), \(a11ySubmissionStatus)", bundle: .core))
        .identifier("ContextCard.submissionCell(\(assignment.id))")
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
            GradeFormatter.string(from: assignment, submission: submission) ?? ""
        }()
        self.icon = {
            if assignment.submissionTypesWithQuizLTIMapping.contains(.online_quiz) {
                return .quizLine
            } else if assignment.submissionTypes.contains(.discussion_topic) {
                return .discussionLine
            } else {
                return .assignmentLine
            }
        }()
        self.a11ySubmissionStatus = {
            if submission.needsGrading {
                return String(localized: "NEEDS GRADING", bundle: .core)
            } else if submission.workflowState == .graded, submission.score != nil, let grade = GradeFormatter.string(from: assignment, submission: submission) {
                return String(localized: "grade", bundle: .core) + " " + grade
            } else {
                return ""
            }
        }()
    }

    private func needsGradingCapsule() -> some View {
        Text("NEEDS GRADING", bundle: .core)
            .font(.regular12)
            .foregroundColor(.textWarning)
            .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
            .overlay(Capsule(style: .continuous)
            .stroke(Color.textWarning, style: StrokeStyle(lineWidth: 1)))
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
            label.foregroundColor(.textDark).font(.semibold14).frame(width: 60, alignment: .leading)
        }
    }

    private func navigateToAssignment() {
        guard let urlString = assignment.htmlURL?.absoluteString else { return }
        let route = "\(urlString)/submissions/\(submission.userID)"
        let options: RouteOptions = (env.app == .teacher) ? .modal(.fullScreen, embedInNav: true) : .modal(embedInNav: true, addDoneButton: true)
        env.router.route(to: route, from: controller, options: options)
    }
}

#if DEBUG
struct ContextCardSubmissionRow_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext
    static var testData: [Submission] {
        let submission = Submission(context: context)
        submission.id = "1"
        submission.submittedAt = Date()
        submission.score = 1
        let needsGrading = Submission(context: context)
        needsGrading.id = "2"
        needsGrading.workflowStateRaw = "pending_review"
        needsGrading.typeRaw = "online_quiz"
        needsGrading.late = true
        needsGrading.submittedAt = Date()
        return [submission, needsGrading]
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
