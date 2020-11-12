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

struct MediumLargeAnnouncementsView: View {
    var body: some View {
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
                if announcements.count > 0 {
                    ForEach(announcements) { announcementItem in
                        AnnouncementItemView(announcementItem: announcementItem)

                        if announcementItem == announcements.last {
                            Spacer(minLength: 0)
                        }
                    }
                } else {
                    EmptyView(title: Text("Announcements"), message: Text("No Announcements"))
                }
            }.padding(.top, 40) // This is to move the first entry below the header
        }.padding()
    }

    private let announcements: [AnnouncementItem]

    init(announcements: [AnnouncementItem]) {
        self.announcements = announcements
    }
}

#if DEBUG
struct MediumLargeAnnouncementViewPreviews: PreviewProvider {
    static var previews: some View {
        ForEach(PreviewSimulator.allCases, id: \.self) { simulator in
            AnnouncementsWidgetView(entry: .make())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: simulator.rawValue))
                .previewDisplayName(simulator.rawValue)
            AnnouncementsWidgetView(entry: .make())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDevice(PreviewDevice(rawValue: simulator.rawValue))
                .previewDisplayName(simulator.rawValue)
        }
    }
}
#endif
