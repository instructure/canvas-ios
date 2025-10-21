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

import Core
import HorizonUI
import SwiftUI

struct AnnouncementsListWidgetView: View {
    @Environment(\.viewController) private var viewController
    @Environment(\.dashboardLastFocusedElement) private var lastFocusedElement
    @Environment(\.dashboardRestoreFocusTrigger) private var restoreFocusTrigger
    @State private var viewModel: AnnouncementsListWidgetViewModel
    @AccessibilityFocusState private var focusedAnnouncementID: String?

    init(viewModel: AnnouncementsListWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            switch viewModel.state {
            case .loading:
                AnnouncementWidgetView(
                    announcement: NotificationModel.mock,
                    focusedAnnouncementID: $focusedAnnouncementID
                ) { _ in }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(String(localized: "Loading announcements", bundle: .horizon)))
            case let .data(announcements: announcements):
                ForEach(announcements) { announcement in
                    AnnouncementWidgetView(
                        announcement: announcement,
                        focusedAnnouncementID: $focusedAnnouncementID,
                        onTap: { seletedAnnouncement in
                            lastFocusedElement.wrappedValue = .announcement(id: seletedAnnouncement.id)
                            viewModel.navigateToAnnouncement(
                                announcement: seletedAnnouncement,
                                viewController: viewController
                            )
                        }
                    )
                }
            }
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .isSkeletonLoadActive(viewModel.state == .loading)
        .onWidgetReload { completion in
            viewModel.fetchAnnouncements(ignoreCache: true, completion: completion)
        }
        .onChange(of: restoreFocusTrigger) { _, _ in
            if let lastFocused = lastFocusedElement.wrappedValue,
               case let .announcement(id) = lastFocused {
                DispatchQueue.main.async {
                    focusedAnnouncementID = id
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        let interactor = NotificationInteractorPreview()
        let viewModel = AnnouncementsListWidgetViewModel(
            interactor: interactor,
            router: AppEnvironment.shared.router
        )
        AnnouncementsListWidgetView(viewModel: viewModel)
    }
#endif
