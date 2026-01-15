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
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: .huiSpaces.space12) {
                ForEach(Array(viewModel.announcements.enumerated()), id: \.offset) { index, announcement in
                    announcementView(announcement: announcement, index: index)
                        .id(index)
                        .scaleEffect(
                            viewModel.currentCardIndex == index ? 1 : 0.9,
                            anchor: (viewModel.currentCardIndex ?? 0) < index ? .leading : .trailing
                        )
                }
            }
            .scrollTargetLayout()
            .padding(.bottom, .huiSpaces.space16)
        }
        .animation(.smooth, value: viewModel.currentCardIndex)
        .scrollPosition(id: $viewModel.currentCardIndex)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, HorizonUI.spaces.space24, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    private func announcementView(announcement: AnnouncementModel, index: Int) -> some View {
        Button {
            lastFocusedElement.wrappedValue = .announcement(id: announcement.id)
            viewModel.navigateToAnnouncement(
                announcement: announcement,
                viewController: viewController
            )
        } label: {
            AnnouncementWidgetView(
                announcement: announcement,
                currentIndex: index,
                totalCount: viewModel.announcements.count,
                isCounterVisible: viewModel.isCounterViewVisible,
                focusedAnnouncementID: $focusedAnnouncementID
            )
            .containerRelativeFrame(.horizontal)
        }
        .disabled(viewModel.state == .loading)
    }
}

#if DEBUG
#Preview {
    let interactor = AnnouncementInteractorPreview()
    let viewModel = AnnouncementsListWidgetViewModel(
        interactor: interactor,
        router: AppEnvironment.shared.router
    )
    AnnouncementsListWidgetView(viewModel: viewModel)
}
#endif
