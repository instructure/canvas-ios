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
                    Spacer(minLength: 0)
                    Text(firstAnnouncement.courseName)
                        .font(.regular11Monodigit)
                        .foregroundColor(firstAnnouncement.courseColor)
                    Text(firstAnnouncement.title).font(.bold17).foregroundColor(.textDarkest)
                    Spacer(minLength: 0)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding(16)
                .widgetURL(firstAnnouncement.url)
            } else {
                NoAnnouncementView()
            }
        default:
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                HStack {
                    Text(NSLocalizedString("Announcements", comment: ""))
                        .font(.semibold12).foregroundColor(.textDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image("student-logomark")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                VStack(spacing: 25) {
                    let announcementsToShow = entry.announcements.prefix((family == .systemMedium) ? 1 : 3)
                    if announcementsToShow.count > 0 {
                        ForEach(announcementsToShow) { announcementItem in
                            AnnouncementItemView(announcementItem: announcementItem)

                            if announcementItem == announcementsToShow.last {
                                Spacer(minLength: 0)
                            }
                        }
                    } else {
                        NoAnnouncementView()
                    }
                }.padding(.top, 40) // This is move the first entry below the header
            }.padding()
        }
    }
}

#if DEBUG
private enum PreviewConfig {
    static func preview(for family: WidgetFamily) -> some View {
        ForEach(PreviewSimulator.allCases, id: \.self) { simulator in
            AnnouncementsWidgetView(entry: .makePreview())
                .previewContext(WidgetPreviewContext(family: family))
                .previewDevice(PreviewDevice(rawValue: simulator.rawValue))
                .previewDisplayName(simulator.rawValue)
            AnnouncementsWidgetView(entry: AnnouncementsEntry(announcementItems: []))
                .previewContext(WidgetPreviewContext(family: family))
                .previewDevice(PreviewDevice(rawValue: simulator.rawValue))
                .previewDisplayName(simulator.rawValue)
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

#endif
