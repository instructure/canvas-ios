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

struct SubmissionHeader: View {
    let assignment: Assignment
    let submission: Submission

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var isGroupSubmission: Bool { !assignment.gradedIndividually && submission.groupID != nil }
    var groupName: String? { isGroupSubmission ? submission.groupName : nil }
    var routeToSubmitter: String? {
        if isGroupSubmission {
            return nil
        } else {
            return "/courses/\(assignment.courseID)/users/\(submission.userID)"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: navigateToSubmitter, label: {
                HStack(spacing: 0) {
                    avatar

                    VStack(alignment: .leading, spacing: 2) {
                        nameText
                            .font(.semibold16).foregroundColor(.textDarkest)
                        Text(submission.status.text)
                            .font(.medium14).foregroundColor(Color(submission.status.color))
                    }
                        .padding(.leading, 12)
                }
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 0))
            })
                .buttonStyle(PlainButtonStyle())
                .identifier("SpeedGrader.userButton")

            Spacer()

            Button(action: navigateToPostPolicy, label: {
                Image.eyeLine
                    .foregroundColor(Color(Brand.shared.linkColor))
                    .padding(16)
            })
                .identifier("SpeedGrader.postPolicyButton")
                .accessibility(label: Text("Post settings"))

            Button(action: dismiss, label: {
                Text("Done")
                    .font(.semibold16).foregroundColor(Color(Brand.shared.linkColor))
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
            })
                .identifier("SpeedGrader.doneButton")
        }
    }

    @ViewBuilder var avatar: some View {
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
            return isGroupSubmission ? Text("Group") : Text("Student")
        }
        return Text(groupName ?? submission.user.flatMap {
            User.displayName($0.name, pronouns: $0.pronouns)
        } ?? "")
    }

    func navigateToSubmitter() {
        guard !assignment.anonymizeStudents, let routeToSubmitter = routeToSubmitter else { return }
        env.router.route(
            to: routeToSubmitter,
            userInfo: [ "courseID": assignment.courseID, "navigatorOptions": ["modal": true] ],
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }

    func navigateToPostPolicy() {
        env.router.route(
            to: "/courses/\(assignment.courseID)/assignments/\(assignment.id)/post_policy",
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }

    func dismiss() {
        env.router.dismiss(controller)
    }
}
