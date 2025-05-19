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

struct SubmissionHeaderView: View {
    let assignment: Assignment
    let submission: Submission

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    var isGroupSubmission: Bool { !assignment.gradedIndividually && submission.groupID != nil }
    var groupName: String? { isGroupSubmission ? submission.groupName : nil }
    var routeToSubmitter: String? {
        if isGroupSubmission {
            nil
        } else {
            "/courses/\(assignment.courseID)/users/\(submission.userID)"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: navigateToSubmitter) {
                HStack(spacing: 12) {
                    avatar

                    VStack(alignment: .leading, spacing: 2) {
                        nameText
                            .font(.semibold16)
                            .foregroundStyle(.textDarkest)

                        HStack(spacing: 4) {
                            HStack(spacing: 2) {
                                Image(uiImage: submission.status.icon)
                                    .size(uiScale.iconScale * 16)
                                    .foregroundStyle(Color(submission.status.color))

                                Text(submission.status.text)
                                    .font(.regular14)
                                    .foregroundStyle(Color(submission.status.color))
                            }

                            Color.borderMedium
                                .frame(width: 1)
                                .clipShape(RoundedRectangle(cornerRadius: 2))

                            Text(assignment.dueText)
                                .font(.regular14)
                                .foregroundStyle(.textDark)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.leading, 6)
                .padding(.trailing, 16)
            }
            .padding(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
            .buttonStyle(.plain)
            .identifier("SpeedGrader.userButton")

            Spacer()
        }
    }

    @ViewBuilder
    var avatar: some View {
        if assignment.anonymizeStudents {
            Avatar.Anonymous(isGroup: isGroupSubmission)
        } else if isGroupSubmission {
            Avatar.Anonymous(isGroup: true)
        } else {
            Avatar(name: submission.user?.name, url: submission.user?.avatarURL)
        }
    }

    var nameText: Text {
        if assignment.anonymizeStudents {
            if isGroupSubmission {
                Text("Group", bundle: .teacher)
            } else {
                Text("Student", bundle: .teacher)
            }
        } else {
            Text(groupName ?? submission.user.flatMap { User.displayName($0.name, pronouns: $0.pronouns) } ?? "")
        }
    }

    func navigateToSubmitter() {
        guard !assignment.anonymizeStudents, let routeToSubmitter = routeToSubmitter else { return }
        env.router.route(
            to: routeToSubmitter,
            userInfo: ["courseID": assignment.courseID, "navigatorOptions": ["modal": true]],
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }
}

#Preview {
    let environment = PreviewEnvironment()

    SubmissionHeaderView(
        assignment: .save(
            .make(due_at: .distantPast),
            in: environment.globalDatabase.viewContext,
            updateSubmission: false,
            updateScoreStatistics: false
        ),
        submission: .save(
            .make(user: .make(name: "Samantha Lastname", pronouns: ("she/her"))),
            in: environment.globalDatabase.viewContext
        )
    )
}
