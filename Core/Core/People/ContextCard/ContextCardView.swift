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

    @ObservedObject var user: Store<GetUserProfile>
    @ObservedObject var course: Store<GetCourse>
    @ObservedObject var colors: Store<GetCustomColors>
    @ObservedObject var enrollments: Store<GetEnrollments>
    @ObservedObject var sections: Store<GetCourseSections>
    @ObservedObject var submissions: Store<GetSubmissionsForStudent>

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    let userID: String

    public init(courseID: String, userID: String) {
        let env = AppEnvironment.shared
        self.userID = userID
        user = env.subscribe(GetUserProfile(userID: userID))
        course = env.subscribe(GetCourse(courseID: courseID))
        colors = env.subscribe(GetCustomColors())
        enrollments = env.subscribe(GetEnrollments(context: Context(.course, id: courseID)))
        sections = env.subscribe(GetCourseSections(courseID: courseID))
        submissions = env.subscribe(GetSubmissionsForStudent(context: Context(.course, id: courseID), studentID: userID))
    }

    public var body: some View {
        contextCard
            .navigationBarItems(
                trailing: Button(action: emailContact, label: {
                    Icon.emailLine
                })
                .accessibility(label: Text("Send message", bundle: .core))
                .identifier("ContextCard.emailContact")
            )
            .navigationTitle(user.first?.name ?? "", subtitle: course.first?.name ?? "")
            .onAppear() {
                self.user.refresh()
                self.course.refresh()
                self.colors.refresh()
                self.enrollments.refresh(force: true)
                self.sections.refresh()
                self.submissions.refresh(force: true)
            }
    }

    @ViewBuilder var contextCard: some View {
        if isPending {
            CircleProgress()
        } else {
            if let course = course.first, let user = user.first, let enrollment = enrollments.first(where: {$0.userID == userID}) {
                ScrollView {
                    ContextCardHeaderView(user: user, course: course, enrollment: enrollment)
                    if enrollment.isStudent, let grades = enrollment.grades.first {
                        ContextCardGradesView(grades: grades, color: Color(course.color))
                    }
                    if enrollment.isStudent, submissions.all.count != 0 {
                        ContextCardSubmissionsView(submissions: submissions.all)
                    }
                    ForEach(submissions.all) { submission in
                        if let assignment = submission.assignment {
                            Divider()
                            ContextCardSubmissionRow(assignment: assignment, submission: submission)
                        }
                    }
                }
            } else if user.first == nil {
                EmptyPanda(.Locked, title: Text("No permission"), message: Text("You have no permission to view this user's profile"))
            } else {
                EmptyPanda(.Unsupported, title: Text("Something went wrong"), message: Text("There was an error while communicating with the server"))
            }
        }
    }

    private var isPending: Bool {
        return !user.requested || user.pending || course.pending || colors.pending || enrollments.pending || sections.pending || submissions.pending
    }

    private func emailContact() {
        guard let course = course.first, let user = user.first else { return }
        let recipient: [String: Any?] = [
            "id": user.id,
            "name": user.name,
            "avatar_url": user.avatarURL?.absoluteString
        ]
        env.router.route(to: "/conversations/compose", userInfo: [
            "recipients": [recipient],
            "contextName": course.name ?? "",
            "contextCode": course.id,
            "canSelectCourse": false
        ], from: controller, options: .modal())
    }
}

#if DEBUG
struct ContextCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContextCardView(courseID: "1", userID: "1")
    }
}
#endif
