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
    @State private var transitionDirection: Edge = .leading

    init(viewModel: AnnouncementsListWidgetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: .zero) {
            switch viewModel.state {
            case .data, .loading:
                dataView
            case .empty, .error:
                EmptyView()
            }
        }
        .accessibilityElement(children: viewModel.state == .loading ? .ignore : .contain)
        .accessibilityLabel(
            viewModel.state == .loading
            ? Text(String(localized: "Loading announcements", bundle: .horizon))
            : nil
        )
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

    private var dataView: some View {
        VStack(spacing: .huiSpaces.space16) {
            AnnouncementWidgetView(
                announcement: viewModel.currentAnnouncement,
                focusedAnnouncementID: $focusedAnnouncementID,
                onTap: { seletedAnnouncement in
                    lastFocusedElement.wrappedValue = .announcement(id: seletedAnnouncement.id)
                    viewModel.navigateToAnnouncement(
                        announcement: seletedAnnouncement,
                        viewController: viewController
                    )
                }
            )
            .id(viewModel.currentAnnouncement.id)
            .paginationTransition(transitionDirection)
            if viewModel.isNavigationButtonVisiable {
                announcementNavigationButtons
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var announcementNavigationButtons: some View {
        HStack {
            HorizonUI.IconButton(
                Image.huiIcons.chevronLeft,
                type: .grayOutline,
                isSmall: true
            ) {
                transitionDirection = .leading
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    viewModel.goPreviousAnnouncement()
                }
            }
            .disabled(!viewModel.isPreviousButtonEnabled)
            .opacity(viewModel.isPreviousButtonEnabled ? 1.0 : 0.5)
            .skeletonLoadable()
            .accessibilityLabel(Text("Go to the previous announcement"))
            .accessibilityAddTraits(.isButton)
            .accessibilityHidden(!viewModel.isPreviousButtonEnabled)

            Spacer()

            Text(
                String(
                    format: String(localized: "%@ of %@"),
                    (viewModel.currentInex + 1).description,
                    viewModel.announcements.count.description
                )
            )
            .huiTypography(.p1)
            .foregroundStyle(Color.huiColors.text.title)
            .skeletonLoadable()
            .accessibilityLabel(
                Text(
                    String(
                        format: String(localized: "Announcement %@ of %@"),
                        (viewModel.currentInex + 1).description,
                        viewModel.announcements.count.description
                    )
                )
            )

            Spacer()

            HorizonUI.IconButton(
                Image.huiIcons.chevronRight,
                type: .grayOutline,
                isSmall: true
            ) {
                transitionDirection = .trailing
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    viewModel.goNextAnnouncement()
                }
            }
            .disabled(!viewModel.isNextButtonEnabled)
            .opacity(viewModel.isNextButtonEnabled ? 1.0 : 0.5)
            .skeletonLoadable()
            .accessibilityLabel(Text("Go to the next announcement"))
            .accessibilityAddTraits(.isButton)
            .accessibilityHidden(!viewModel.isNextButtonEnabled)
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
