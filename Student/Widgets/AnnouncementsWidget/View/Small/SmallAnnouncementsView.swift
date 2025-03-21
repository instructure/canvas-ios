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

import WidgetKit
import SwiftUI

struct SmallAnnouncementsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(announcement.date.relativeDateOnlyString)
                .font(.semibold12)
                .lineLimit(1)
                .foregroundColor(.textDark)
            Spacer(minLength: 0)
            Text(announcement.courseName)
                .font(.semibold12)
                .foregroundColor(announcement.courseColor)
            Text(announcement.title).font(.bold17).foregroundColor(.textDarkest)
            Spacer(minLength: 0)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .widgetURL(announcement.url)
    }

    private let announcement: AnnouncementItem

    init(announcement: AnnouncementItem) {
        self.announcement = announcement
    }
}

#if DEBUG

struct SmallAnnouncementViewPreviews: PreviewProvider {
    static var previews: some View {
        AnnouncementsWidgetView(entry: .make())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#endif
