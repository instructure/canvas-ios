//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct SideMenuView: View {
    @Environment(\.appEnvironment) var env
    @ObservedObject var profile: Store<GetUserProfile>

    let enrollment: HelpLinkEnrollment

    public init(_ enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
        let env = AppEnvironment.shared
        profile = env.subscribe(GetUserProfile(userID: "self"))
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    SideMenuHeaderView(profileStore: profile)
                    Divider()
                    SideMenuMainSection(enrollment)
                    Divider()
                    if enrollment != .observer {
                        SideMenuOptionsSection(enrollment: enrollment)
                        Divider()
                    }
                    SideMenuBottomSection(enrollment)
                    Spacer()
                }
            }.clipped()
            SideMenuFooterView()
        }.onAppear {
            profile.refresh()
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(.student)
    }
}
