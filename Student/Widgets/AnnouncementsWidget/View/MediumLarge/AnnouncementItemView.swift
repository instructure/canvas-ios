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

import Core
import SwiftUI
import WidgetKit

struct AnnouncementItemView: View {
    var announcementItem: AnnouncementItem

    var body: some View {
        Link(destination: announcementItem.url) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(announcementItem.courseName)
                        .font(.semibold12)
                        .foregroundColor(announcementItem.courseColor)
                    Spacer()
                    Text(announcementItem.date.relativeDateOnlyString)
                        .font(.semibold12)
                        .lineLimit(1)
                        .foregroundColor(.textDark)
                }
                Text(announcementItem.title)
                    .font(.bold17)
                    .foregroundColor(.textDarkest)
                    .lineLimit(2)
                HStack {
                    if let avatar = announcementItem.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .frame(width: 16, height: 16, alignment: .center)
                            .cornerRadius(8)
                    } else {
                        Avatar(name: announcementItem.authorName, url: nil, size: 16)
                    }
                    Text(announcementItem.authorName)
                        .font(.semibold12)
                        .foregroundColor(.textDark)
                    Spacer()
                }
            }
        }
    }
}

#if DEBUG

struct AnnouncementItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item = AnnouncementItem(
            title: "Finals are moving to another week.",
            date: Date(),
            url: URL(string: "https://www.instructure.com/")!,
            authorName: "Thomas McKempis",
            courseName: "Introduction to the solar system",
            courseColor: .textInfo)
        AnnouncementItemView(announcementItem: item).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

#endif
