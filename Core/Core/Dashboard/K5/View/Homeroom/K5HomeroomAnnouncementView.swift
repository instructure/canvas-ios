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

struct K5HomeroomAnnouncementView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("123098 — Homeroom FALL 2020 — Ms. Johnson")
            Text("Announcement Title")
            WebView(html: nil)
            Button(action: {}, label: {
                Text("View Previous Announcements", bundle: .core)
            })
        }
    }
}

struct K5HomeRoomAnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        K5HomeroomAnnouncementView().previewLayout(.sizeThatFits)
    }
}
