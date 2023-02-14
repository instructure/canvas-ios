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

struct AnnouncementsWidgetView: View {
    var entry: AnnouncementsEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let firstAnnouncement = entry.announcements.first {
            switch family {
            case .systemSmall:
                SmallAnnouncementsView(announcement: firstAnnouncement)
            default:
                let announcementsToShow = Array(entry.announcements.prefix((family == .systemMedium) ? 1 : 3))
                MediumLargeAnnouncementsView(announcements: announcementsToShow)
            }
        } else if entry.isLoggedIn {
            EmptyView(title: Text("Announcements"), message: Text("No Announcements"))
        } else {
            EmptyView(title: Text("Announcements"), message: Text("Please log in via the application"))
        }
    }
}

#if DEBUG
private enum PreviewConfig {
    private static let data = [
        AnnouncementsEntry(isLoggedIn: false),
        AnnouncementsEntry(announcementItems: []),
        .make(),
    ]

    static func preview(for family: WidgetFamily, device: PreviewDevice = PreviewDevice(PreviewSimulator.allCases[0])) -> some View {
        ForEach(data) { entry in
            AnnouncementsWidgetView(entry: entry)
                .previewContext(WidgetPreviewContext(family: family))
                .previewDevice(device)
        }
    }
}

struct SmallWidgets: PreviewProvider {
    static var previews: some View { PreviewConfig.preview(for: .systemSmall) }
}

struct MediumWidgets: PreviewProvider {
    static var previews: some View { PreviewConfig.preview(for: .systemMedium) }
}

struct LargeWidgets: PreviewProvider {
    static var previews: some View { PreviewConfig.preview(for: .systemLarge) }
}

struct ExtraLargeWidgets: PreviewProvider {
    static var previews: some View {
        PreviewConfig.preview(for: .systemExtraLarge, device: PreviewDevice(.iPadPro_9_7))
    }
}

#endif
