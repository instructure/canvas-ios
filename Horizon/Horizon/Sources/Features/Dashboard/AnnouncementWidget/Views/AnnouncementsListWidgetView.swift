//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import HorizonUI
import SwiftUI

struct AnnouncementsListWidgetView: View {
    @Environment(\.viewController) private var viewController
    @State private var viewModel: AnnouncementsListWidgetViewModel

    init(viewModel: AnnouncementsListWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            switch viewModel.state {
            case .loading:
                AnnouncementWidgetView(announcement: NotificationModel.mock) { _ in }
            case .data(announcements: let announcements):
                ForEach(announcements) { announcement in
                    AnnouncementWidgetView(announcement: announcement) { seletedAnnouncement in
                        viewModel.navigateToAnnouncement(
                            announcement: seletedAnnouncement,
                            viewController: viewController
                        )
                    }
                }
            }
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .isSkeletonLoadActive(viewModel.state == .loading )
        .onWidgetReload { completion in
            viewModel.fetchAnnouncements(ignoreCache: true, completion: completion)
        }
    }
}

#if DEBUG
#Preview {
    AnnouncementsWidgetAssembly.makePreview()
}
#endif
