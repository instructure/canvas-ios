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
                    Spacer()
                }.padding(8)
            } else {
                Text("No announcements")
            }
        default:
            let announcementsToShow = entry.announcements.prefix((family == .systemMedium) ? 1 : 3)
            VStack(alignment: .leading, spacing: 2) {
                Image("student-logomark")
                    .resizable()
                    .frame(width: 24, height: 24).padding(8)
                ForEach(announcementsToShow) { announcementItem in
                    announcementItemView(announcementItem: announcementItem)
                }
                Spacer()
            }.padding(8)
        }
    }
}

#if DEBUG
struct AnnouncementsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let item = AnnouncementItem(title: "Preview A PROG  kapcsolás  időpontja ,  amely  nem változtatható meg, csak a hozzárendelt hőfok állítható az egyéni  igények  szerint.  Így  tehát  gyári  alaphelyzetben  a  termosztát naponta csak 1 kapcsolást (PROG) hajt végre, ami -től a következő nap -ig van érvényben")
        let entry = AnnouncementsEntry(announcementItems: [item, item, item])
        AnnouncementsWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        AnnouncementsWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        AnnouncementsWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
