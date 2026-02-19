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

struct CoursesAndGroupsWidgetView: View {
    @Environment(\.viewController) var controller

    @State var viewModel: CoursesAndGroupsWidgetViewModel

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .empty:
                InteractivePanda(config: .empty(
                    title: String(localized: "Welcome to Canvas!", bundle: .student),
                    subtitle: String(localized: """
                        You don't have any courses yet — so things are a bit quiet here. \
                        Once you enroll in a class, your dashboard will start filling up with new activity.
                        """, bundle: .student)
                ))
            case .data:
                content
            case .loading, .error:
                SwiftUI.EmptyView()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .center, spacing: 16) {
            if viewModel.courseCards.isNotEmpty {
                coursesSection
            }

            if viewModel.groupCards.isNotEmpty {
                groupsSection
            }

            Button(String(localized: "All Courses", bundle: .student)) {
                viewModel.didTapAllCourses(from: controller)
            }
            .buttonStyle(.pillButtonBrandFilled)
            .identifier("Dashboard.allCoursesButton")

        }
        .animation(.dashboardWidget, value: viewModel.layoutIdentifier)
    }

    private var coursesSection: some View {
        DashboardTitledWidget(
            viewModel.coursesSectionTitle,
            customAccessibilityTitle: viewModel.coursesSectionAccessibilityTitle
        ) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.courseCards) { cardViewModel in
                    CourseCardView(
                        viewModel: cardViewModel,
                        showGrades: viewModel.showGrades,
                        showColorOverlay: viewModel.showColorOverlay
                    )
                }
            }
        }
    }

    private var groupsSection: some View {
        DashboardTitledWidget(
            viewModel.groupsSectionTitle,
            customAccessibilityTitle: viewModel.groupsSectionAccessibilityTitle
        ) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.groupCards) { cardViewModel in
                    GroupCardView(viewModel: cardViewModel)
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    PreviewContainer(horizontalPadding: 16) {
        CoursesAndGroupsWidgetView(viewModel: viewModel)
            .onAppear {
                viewModel.refresh(ignoreCache: false).sink { _ in }.store(in: &subscriptions)
            }
    }
    .background(.backgroundLight)
}

private func makePreviewViewModel() -> CoursesAndGroupsWidgetViewModel {
    let config = DashboardWidgetConfig(id: .coursesAndGroups, order: 0, isVisible: true, settings: nil)
    let interactor = CoursesAndGroupsWidgetInteractorMock()

    return CoursesAndGroupsWidgetViewModel(
        config: config,
        interactor: interactor,
        environment: PreviewEnvironment()
    )
}

#endif
