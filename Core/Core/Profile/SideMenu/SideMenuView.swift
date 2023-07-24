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

public struct SideMenuView: View, ScreenViewTrackable {
    @Environment(\.appEnvironment) private var environment
    let enrollment: HelpLinkEnrollment
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/profile")

    public init(_ enrollment: HelpLinkEnrollment) {
        self.enrollment = enrollment
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    SideMenuHeaderView()
                    Divider()
                    SideMenuMainSection(enrollment)
                    Divider()
                    if !environment.k5.isK5Enabled, enrollment == .observer {
                        SideMenuOptionsSection()
                        Divider()
                    }
                    SideMenuBottomSection(enrollment)
                    Spacer()
                }
            }.clipped()
            SideMenuFooterView()
        }
    }
}

#if DEBUG

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(.student)
            .previewDisplayName("Student")
        SideMenuView(.observer)
            .previewDisplayName("Parent")
    }
}

#endif
