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

public struct ContextCardView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var user: Store<GetCourseSingleUser>
    @ObservedObject private var course: Store<GetCourse>
    @ObservedObject private var colors: Store<GetCustomColors>
    @ObservedObject private var sections: Store<GetCourseSections>
    @ObservedObject private var submissions: Store<GetSubmissionsForStudent>
    @ObservedObject private var permissions: Store<GetContextPermissions>

    @State private var isFirstAppear = true
    private let context: Context
    private let userID: String
    private let isViewingAnotherUser: Bool

    public init(courseID: String, userID: String, currentUserID: String) {
        let env = AppEnvironment.shared
        self.context = Context.course(courseID)
        self.userID = userID
        self.isViewingAnotherUser = (userID != currentUserID)
        user = env.subscribe(GetCourseSingleUser(context: context, userID: userID))
        course = env.subscribe(GetCourse(courseID: courseID))
        colors = env.subscribe(GetCustomColors())
        sections = env.subscribe(GetCourseSections(courseID: courseID))
        submissions = env.subscribe(GetSubmissionsForStudent(context: context, studentID: userID))
        permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .sendMessages ]))
    }

    public var body: some View {
        contextCard
            .navigationBarItems(trailing: emailButton)
            .navigationTitle(user.first?.name ?? "", subtitle: course.first?.name ?? "")
            .onAppear {
                guard isFirstAppear else { return }
                self.isFirstAppear = false
                self.user.refresh()
                self.course.refresh()
                self.colors.refresh()
                self.sections.refresh()
                self.submissions.refresh(force: true)
                self.permissions.refresh()
            }
    }

    @ViewBuilder var emailButton: some View {
        if permissions.first?.sendMessages == true, isViewingAnotherUser {
            Button(action: emailContact, label: {
                Icon.emailLine
            })
            .accessibility(label: Text("Send message", bundle: .core))
            .identifier("ContextCard.emailContact")
        }
    }

    @ViewBuilder var contextCard: some View {
        if isPending {
            CircleProgress()
        } else {
            if let course = course.first, let user = user.first, let enrollment = user.enrollments?.first(where: { $0.canvasContextID == context.canvasContextID }) {
                ScrollView {
                    ContextCardHeaderView(user: user, course: course, sections: sections.all, enrollment: enrollment, showLastActivity: env.app == .teacher)
                    if enrollment.isStudent {
                        if let grades = enrollment.grades.first {
                            ContextCardGradesView(grades: grades, color: Color(course.color))
                        }
                        if submissions.all.count != 0 {
                            ContextCardSubmissionsView(submissions: submissions.all)
                        }
                    }
                    if env.app == .teacher {
                        ForEach(submissions.all) { submission in
                            if let assignment = assignment(with: submission.assignmentID) {
                                Divider()
                                ContextCardSubmissionRow(assignment: assignment, submission: submission)

                                if submissions.last == submission {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyPanda(.Unsupported, title: Text("Something went wrong"), message: Text("There was an error while communicating with the server"))
            }
        }
    }

    private var isPending: Bool {
        !user.requested || user.pending || course.pending || colors.pending || sections.pending || submissions.pending
    }

    private func emailContact() {
        guard let course = course.first, let user = user.first else { return }
        let recipient: [String: Any?] = [
            "id": user.id,
            "name": user.name,
            "avatar_url": user.avatarURL?.absoluteString,
        ]
        env.router.route(to: "/conversations/compose", userInfo: [
            "recipients": [recipient],
            "contextName": course.name ?? "",
            "contextCode": course.id,
            "canSelectCourse": false,
        ], from: controller, options: .modal(embedInNav: true))
    }

    private func assignment(with id: String) -> Assignment? {
        env.database.viewContext.first(where: #keyPath(Assignment.id), equals: id)
    }
}

#if DEBUG
struct ContextCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContextCardView(courseID: "1", userID: "1", currentUserID: "0")
    }
}
#endif
