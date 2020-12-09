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

    let user: UserProfile
    let course: Course

    var body: some View {
        VStack(spacing: 10) {
            Avatar(name: user.name, url: user.avatarURL, size: 80)
                .padding(20)
            Text(user.name)
                .font(.bold20)
                .foregroundColor(.textDarkest)
            Text(user.email ?? "")
                .font(.regular14)
                .foregroundColor(.textDarkest)
            //TODO get enrollment
            Text("Last activity on December 8 at 1:11PM")
                .font(.regular12)
                .foregroundColor(.textDark)
            ZStack() {
                Divider()
                VStack() {
                    Text(course.name ?? "")
                        .font(.semibold16)
                    //TODO get section name
                    Text("section name")
                        .font(.semibold12)
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
        let apiProfile = APIProfile.make(id: "1", name: "Test Student", primary_email: "test@instucture.com", login_id: nil, avatar_url: nil, calendar: nil, pronouns: nil)
        let user = UserProfile.save(apiProfile, in: context)
        let apiCourse = APICourse.make()
        let course = Course.save(apiCourse, in: context)
        return ContextCardHeaderView(user: user, course: course)
    }
}
#endif
