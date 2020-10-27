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

struct announcementItemView: View {
    var announcementItem: AnnouncementItem

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Introduction to the solar system")
                    .font(.regular11Monodigit)
                    .foregroundColor(.blue)
                Spacer()
                Text(announcementItem.date.relativeDateOnlyString)
                    .font(.regular11Monodigit)
                    .lineLimit(1)
                    .foregroundColor(.textDark)
            }
            Text(announcementItem.title)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
                .lineLimit(2)
            Text("Author - TODO")
                .font(.regular12)
                .foregroundColor(.textDark)
        }.padding(8)
    }
}
