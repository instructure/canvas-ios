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

    @Environment(\.appEnvironment) var env

    public init(courseID: String, userID: String) {
        let env = AppEnvironment.shared
        user = env.subscribe(GetUserProfile(userID: userID))
        course = env.subscribe(GetCourse(courseID: courseID))
    }

    public var body: some View {
        ScrollView {
            if let course = course.first, let user = user.first {
                ContextCardHeaderView(user: user, course: course)
            } else {
                CircleProgress()
            }
            gradesView
        }
        .navigationTitle(user.first?.name ?? "", subtitle: course.first?.name ?? "")
        .onAppear {
            self.user.refresh()
        }
    }

    @ViewBuilder var gradesView: some View {
        VStack(alignment: .leading) {
            Text("Grades")
            HStack() {
                Text("Grade before posting")
                Text("Grade after posting")

            }
        }
    }
    @ViewBuilder var submissionView: some View {
        VStack(alignment: .leading) {
            Text("Submissions")
            HStack() {
                Text("Grade before posting")
                Text("Grade after posting")

            }
        }
    }
}



#if DEBUG
struct ContextCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContextCardView(courseID: "1", userID: "1")
    }
}
#endif
