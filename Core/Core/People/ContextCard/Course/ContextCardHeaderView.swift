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

struct ContextCardHeaderView: View {
    let user: APIUser
    let course: Course
    let sections: [CourseSection]
    let enrollment: Enrollment
    let showLastActivity: Bool

    var body: some View {
        VStack(spacing: 10) {
            // Show short name (nickname) if user is not a teacher
            let nameToUse = (user.email ?? "").isEmpty ? user.short_name : user.name

            Avatar(name: nameToUse, url: user.avatar_url?.rawValue, size: 80)
                .padding(20)
            Text(User.displayName(nameToUse, pronouns: user.pronouns))
                .font(.bold20)
                .foregroundColor(.textDarkest)
                .identifier("ContextCard.userNameLabel")
            // Only teachers can see user email addresses
            if let email = user.email {


                Text(email)
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                    .identifier("ContextCard.userEmailLabel")
            }
            if showLastActivity, let activityTime = enrollment.lastActivityAt?.dateTimeString {
                Text("Last activity on \(activityTime)", bundle: .core)
                    .font(.regular12)
                    .foregroundColor(.textDark)
                    .identifier("ContextCard.lastActivityLabel")
            }
            ZStack {
                Divider()
                VStack {
                    Text(course.name ?? "")
                        .font(.semibold16)
                        .identifier("ContextCard.courseLabel")
                    if let sectionName = sections.first(where: {$0.id == enrollment.courseSectionID})?.name {
                        Text(sectionName)
                            .font(.semibold12)
                            .accessibility(label: Text("Section: \(sectionName)", bundle: .core))
                            .identifier("ContextCard.sectionLabel")
                    }
                }.padding(.horizontal, 16).padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderDarkest, lineWidth: 1 / UIScreen.main.scale))
                .foregroundColor(.textDarkest)
                .background(Color.backgroundLightest)
            }
        }.padding(.vertical, 16)
    }
}

#if DEBUG
struct ContextCardHeaderView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let apiUser = APIUser.make()
        let apiCourse = APICourse.make()
        let course = Course.save(apiCourse, in: context)
        let apiEnrollment = APIEnrollment.make(last_activity_at: Date())
        let enrollment = Enrollment(context: context)
        enrollment.update(fromApiModel: apiEnrollment, course: course, in: context)
        return ContextCardHeaderView(user: apiUser, course: course, sections: [], enrollment: enrollment, showLastActivity: true).previewLayout(.sizeThatFits)
    }
}
#endif
