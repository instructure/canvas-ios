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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.containerSize) private var containerSize

    @State private var viewModel: CoursesAndGroupsWidgetViewModel
    @State private var draggedCourseCardId: String?

    init(viewModel: CoursesAndGroupsWidgetViewModel) {
        self.viewModel = viewModel
    }

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

    @ViewBuilder
    private var content: some View {
        let columnCount = DashboardWidgetLayout.columnCount(for: containerSize.width)
        let itemWidth = itemWidth(containerWidth: containerSize.width, columnCount: columnCount)

        VStack(alignment: .center, spacing: 16) {
            if viewModel.courseCards.isNotEmpty {
                coursesSection(itemWidth: itemWidth, columnCount: columnCount)
            }

            if viewModel.groupCards.isNotEmpty {
                groupsSection(itemWidth: itemWidth, columnCount: columnCount)
            }

            Button(String(localized: "All Courses", bundle: .student)) {
                viewModel.didTapAllCourses(from: controller)
            }
            .buttonStyle(.pillButtonBrandFilled)
            .identifier("Dashboard.allCoursesButton")
        }
        .animation(.dashboardWidget, value: columnCount)
        .animation(.dashboardWidget, value: viewModel.layoutIdentifier)
    }

    private func coursesSection(itemWidth: CGFloat, columnCount: Int) -> some View {
        DashboardTitledWidget(
            viewModel.coursesSectionTitle,
            customAccessibilityTitle: viewModel.coursesSectionAccessibilityTitle
        ) {
            DashboardGrid(
                itemIDs: viewModel.courseCards.map(\.id),
                itemWidth: itemWidth,
                spacing: cardSpacing(columnCount),
                columnCount: columnCount
            ) { index in
                let cardViewModel = viewModel.courseCards[index]
                CourseCardView(
                    viewModel: cardViewModel,
                    showGrades: viewModel.showGrades,
                    showColorOverlay: viewModel.showColorOverlay
                )
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: InstUI.Styles.Elevation.Shape.cardLarge.cornerRadius))
                .onDrag {
                    draggedCourseCardId = cardViewModel.id
                    return NSItemProvider(item: nil, typeIdentifier: CourseCardDropToReorderDelegate.DropID)
                }
                .onDrop(
                    of: [CourseCardDropToReorderDelegate.DropID],
                    delegate: CourseCardDropToReorderDelegate(
                        receiverCardId: cardViewModel.id,
                        draggedCourseCardId: $draggedCourseCardId,
                        order: viewModel.courseCards.map { $0.id },
                        delegate: viewModel
                    )
                )
            }
            .animation(.dashboardWidget, value: viewModel.courseCards)
        }
    }

    private func groupsSection(itemWidth: CGFloat, columnCount: Int) -> some View {
        DashboardTitledWidget(
            viewModel.groupsSectionTitle,
            customAccessibilityTitle: viewModel.groupsSectionAccessibilityTitle
        ) {
            DashboardGrid(
                itemIDs: viewModel.groupCards.map(\.id),
                itemWidth: itemWidth,
                spacing: cardSpacing(columnCount),
                columnCount: columnCount
            ) { index in
                GroupCardView(viewModel: viewModel.groupCards[index])
            }
        }
    }

    private func itemWidth(containerWidth: CGFloat, columnCount: Int) -> CGFloat {
        guard containerWidth > 0, columnCount > 0 else { return 0 }
        return (containerWidth - CGFloat(columnCount - 1) * cardSpacing(columnCount)) / CGFloat(columnCount)
    }

    private func cardSpacing(_ columnCount: Int) -> CGFloat {
        (columnCount == 1) ? 4 : 8
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
    return CoursesAndGroupsWidgetViewModel(
        config: .make(id: .coursesAndGroups),
        interactor: .preview(),
        environment: PreviewEnvironment()
    )
}

#endif
