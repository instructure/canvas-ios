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

struct CourseInvitationCard: View {
    @ObservedObject var course: Course
    @ObservedObject var enrollment: Enrollment
    let id: String

    @Environment(\.appEnvironment) var env

    var body: some View {
        let courseName = course.name ?? ""
        let sectionName = course.sections.first { $0.id == enrollment.courseSectionID }? .name
        let displayName = (sectionName == courseName ? nil : sectionName.map { "\(courseName), \($0)" }) ?? courseName

        HStack(spacing: 0) {
            VStack {
                Image.invitationLine.foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.top, 10)
                    .accessibility(hidden: true)
                Spacer()
            }
                .background(Color.backgroundSuccess)
            VStack(alignment: .leading, spacing: 0) {
                HStack { Spacer() }
                if enrollment.state != .invited {
                    HStack(alignment: .top) {
                        (enrollment.state == .active ?
                            Text("Invite accepted!", bundle: .core) :
                            Text("Invite declined!", bundle: .core)
                        )
                            .font(.semibold18)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Button(action: dismiss, label: {
                            Image.xSolid.foregroundColor(.textDark)
                                .padding(10)
                        })
                            .accessibility(label: Text("Dismiss invitation to \(course.name ?? "")", bundle: .core))
                            .identifier("CourseInvitation.\(id).dismissButton")
                            .padding(.horizontal, -16).padding(.vertical, -12)
                    }
                } else {
                    Text("You have been invited", bundle: .core)
                        .font(.semibold18).foregroundColor(.textDarkest)
                    Text(displayName)
                        .font(.regular14).foregroundColor(.textDarkest)
                        .padding(.bottom, 12)
                    HStack(spacing: 16) {
                        Button(action: { handle(isAccepted: false) }, label: {
                            Text("Decline", bundle: .core)
                                .font(.semibold16).foregroundColor(.textDark)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderDark, lineWidth: 1 / UIScreen.main.scale))
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.backgroundLightest))
                        })
                            .identifier("CourseInvitation.\(id).rejectButton")
                        Button(action: { handle(isAccepted: true) }, label: {
                            Text("Accept", bundle: .core)
                                .font(.semibold16).foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.backgroundSuccess))
                        })
                            .identifier("CourseInvitation.\(id).acceptButton")
                    }
                }
            }
                .padding(.horizontal, 16).padding(.vertical, 12)
        }
            .background(RoundedRectangle(cornerRadius: 4).stroke(Color.backgroundSuccess))
            .background(Color(.backgroundLightest))
            .cornerRadius(4)
    }

    func handle(isAccepted: Bool) {
        HandleCourseInvitation(courseID: course.id, enrollmentID: id, isAccepted: isAccepted).fetch()
    }

    func dismiss() {
        env.database.performWriteTask { context in
            let enrollment: Enrollment? = context.first(where: #keyPath(Enrollment.id), equals: id)
            enrollment?.isFromInvitation = false
            try? context.save()
        }
    }
}
