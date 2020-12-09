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

struct ContextCardGradesView: View {

    let user: UserProfile
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Grades")
                .font(.semibold14)
                .foregroundColor(.textDark)
            HStack() {
                ContextCardBoxView(title: "98%", subTitle: "Grade before posting")
                ContextCardBoxView(title: "94.5%", subTitle: "Grade after posting")
                ContextCardBoxView(title: "96.25%", subTitle: "Grade Override")
            }
        }.padding(.horizontal, 16).padding(.vertical, 8)

    }
}

#if DEBUG
struct ContextCardGradesrView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let apiProfile = APIProfile.make(id: "1", name: "Test Student", primary_email: "test@instucture.com", login_id: nil, avatar_url: nil, calendar: nil, pronouns: nil)
        let user = UserProfile.save(apiProfile, in: context)
        let apiCourse = APICourse.make()
        let course = Course.save(apiCourse, in: context)
        return ContextCardGradesView(user: user, course: course)
    }
}
#endif
