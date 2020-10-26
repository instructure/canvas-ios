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
import WidgetKit

struct AnnouncementsWidgetView : View {
    var entry: AnnouncementsProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            if let firstAnnouncement = entry.announcements.first {
                VStack(alignment: .leading, spacing: 2) {
                    Text(firstAnnouncement.date.relativeDateOnlyString)
                        .font(.regular11Monodigit)
                        .lineLimit(1)
                        .foregroundColor(.textDark)
                    Text("Introduction to the solar system")
                        .font(.regular11Monodigit)
                        .foregroundColor(.blue)
                    Text(firstAnnouncement.title).font(.bold17).foregroundColor(.textDarkest)
                }.padding(8)
            } else {
                Text("No announcements")
            }
        case .systemMedium:
            VStack(alignment: .leading, spacing: 8) {
                Image("student-logomark")
                    .resizable()
                    .frame(width: 24, height: 24).padding(8)
                if let firstAnnouncement = entry.announcements.first {
                    singleAnnouncementView(announcement: firstAnnouncement)
                } else {
                    Text("No announcements")
                }
            }.padding(8)
        default:
            VStack(alignment: .leading, spacing: 2) {
                Image("student-logomark")
                    .resizable()
                    .frame(width: 24, height: 24).padding(8)
                ForEach(entry.announcements.prefix(3)) { announcementItem in
                    singleAnnouncementView(announcement: announcementItem)
                }
            }.padding(8)
        }
    }
}

struct singleAnnouncementView: View {
    var announcement: AnnouncementItem

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Introduction to the solar system")
                    .font(.regular11Monodigit)
                    .foregroundColor(.blue)
                Spacer()
                Text(announcement.date.relativeDateOnlyString)
                    .font(.regular11Monodigit)
                    .lineLimit(1)
                    .foregroundColor(.textDark)
            }
            Text(announcement.title).font(.bold17).foregroundColor(.textDarkest)
            Text("Author - TODO")
                .font(.regular12)
                .foregroundColor(.textDark)
        }.padding(8)
    }
}

struct AnnouncementsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let item = AnnouncementItem(title: "Preview announcement placeholder text, this is long, blablablablabla, jajj de hosszú")
        let entry = AnnouncementsEntry(announcementItems: [item, item])
        AnnouncementsWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        AnnouncementsWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        AnnouncementsWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
