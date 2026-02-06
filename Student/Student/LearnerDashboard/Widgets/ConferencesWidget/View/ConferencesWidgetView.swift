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

struct ConferencesWidgetView: View {
    @State var viewModel: ConferencesWidgetViewModel
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
                            items: viewModel.conferences,
                            currentPage: $currentPage,
                            totalPages: $totalPages
                        ) { cardViewModel in
                            ConferenceCardView(viewModel: cardViewModel)
                        }

                        InstUI.PageIndicator(currentIndex: currentPage, count: totalPages)
                    }
                }
                .animation(.dashboardWidget, value: viewModel.conferences)
            }
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    ConferencesWidgetView(viewModel: viewModel)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.refresh(ignoreCache: false)
                .sink { _ in }
                .store(in: &subscriptions)
        }
}

private func makePreviewViewModel() -> ConferencesWidgetViewModel {
    let env = PreviewEnvironment()
    let context = env.database.viewContext

    let config = DashboardWidgetConfig(id: .conferences, order: 0, isVisible: true, settings: nil)
    let coursesInteractor = CoursesInteractorMock()

    let mockCourses = [
        Course.save(
            .make(id: "1", name: "Introduction to Computer Science"),
            in: context
        ),
        Course.save(
            .make(id: "2", name: "Advanced Mathematics"),
            in: context
        )
    ]

    let mockGroups = [
        Group.save(
            .make(id: "group1", name: "Study Group A"),
            in: context
        )
    ]

    coursesInteractor.mockCoursesResult = CoursesResult(
        allCourses: mockCourses,
        invitedCourses: [],
        groups: mockGroups
    )

    return ConferencesWidgetViewModel(
        config: config,
        interactor: coursesInteractor,
        snackBarViewModel: SnackBarViewModel(),
        context: context
    )
}

#endif
