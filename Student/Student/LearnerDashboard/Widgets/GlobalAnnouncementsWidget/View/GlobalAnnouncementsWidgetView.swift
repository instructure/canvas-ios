//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Combine
import Core
import SwiftUI

struct GlobalAnnouncementsWidgetView: View {
    @State var viewModel: GlobalAnnouncementsWidgetViewModel
    @State private var currentPage: Int = 0
    @State private var totalPages: Int = 1

    var body: some View {
        ZStack {
            if viewModel.state == .data {
                DashboardTitledWidget(
                    viewModel.widgetTitle,
                    customAccessibilityTitle: viewModel.widgetAccessibilityTitle
                ) {
                    VStack(spacing: InstUI.Styles.Padding.sectionHeaderVertical.rawValue) {
                        HorizontalCarouselView(
                            items: viewModel.announcements,
                            currentPage: $currentPage,
                            totalPages: $totalPages
                        ) { cardViewModel in
                            GlobalAnnouncementCardView(viewModel: cardViewModel)
                                .accessibilityElement(children: .contain)
                                .identifier("Dashboard.GlobalAnnouncementCard.Id.\(cardViewModel.id)")
                        }

                        InstUI.PageIndicator(currentIndex: currentPage, count: totalPages)
                    }
                }
                .animation(.dashboardWidget, value: viewModel.announcements)
            }
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    GlobalAnnouncementsWidgetView(viewModel: viewModel)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.refresh(ignoreCache: false)
                .sink { _ in }
                .store(in: &subscriptions)
        }
}

private func makePreviewViewModel() -> GlobalAnnouncementsWidgetViewModel {
    let config = DashboardWidgetConfig(id: .globalAnnouncements, order: 0, isVisible: true, settings: nil)
    let interactor = GlobalAnnouncementsWidgetInteractorMock()

    interactor.mockAnnouncements = [
        .make(id: "1", title: "Calendar", icon: .calendar, startDate: Date()),
        .make(id: "2", title: "Information", icon: .information, startDate: Date().addHours(1)),
        .make(id: "3", title: "Question", icon: .question, startDate: Date().addHours(2)),
        .make(id: "4", title: "Warning", icon: .warning, startDate: Date().addHours(3)),
        .make(id: "5", title: "Error", icon: .error, startDate: Date().addHours(4))
    ]

    return GlobalAnnouncementsWidgetViewModel(
        config: config,
        interactor: interactor,
        environment: PreviewEnvironment()
    )
}

#endif
