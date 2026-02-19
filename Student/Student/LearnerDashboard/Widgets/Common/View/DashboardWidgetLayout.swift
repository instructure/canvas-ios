//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import CoreData
import SwiftUI

extension DashboardWidgetLayout {

    /// This is the source of truth for column count calculation for all widgets utilizing columns.
    static func columnCount(for width: CGFloat) -> Int {
        switch width {
        case ..<600: 1
        case 600..<840: 2
        default: 3
        }
    }
}

struct DashboardWidgetLayout: View {
    let fullWidthWidgets: [any DashboardWidgetViewModel]
    let gridWidgets: [any DashboardWidgetViewModel]
    let containerWidth: CGFloat

    var body: some View {
        VStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
            fullWidthSection()
                .animation(.dashboardWidget, value: fullWidthWidgets.map(\.layoutIdentifier))
            gridSection(columnCount: Self.columnCount(for: containerWidth))
                .animation(.dashboardWidget, value: gridWidgets.map(\.layoutIdentifier))
        }
    }

    @ViewBuilder
    private func fullWidthSection() -> some View {
        ForEach(fullWidthWidgets, id: \.id) { viewModel in
            LearnerDashboardWidgetAssembly.makeView(for: viewModel)
        }
    }

    @ViewBuilder
    private func gridSection(columnCount: Int) -> some View {
        if !gridWidgets.isEmpty {
            HStack(alignment: .top, spacing: InstUI.Styles.Padding.standard.rawValue) {
                ForEach(0..<columnCount, id: \.self) { columnIndex in
                    columnView(columnIndex: columnIndex, columnCount: columnCount)
                }
            }
        }
    }

    private func columnView(columnIndex: Int, columnCount: Int) -> some View {
        ConditionallyLazyVStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
            ForEach(Array(gridWidgets.enumerated()), id: \.element.id) { index, viewModel in
                if index % columnCount == columnIndex {
                    LearnerDashboardWidgetAssembly.makeView(for: viewModel)
                }
            }
        }
    }
}

#if DEBUG

private func makePreviewInteractor(context: NSManagedObjectContext) -> CoursesInteractorMock {
    let mockCourses = [
        Course.save(
            .make(
                id: "1",
                name: "Introduction to Computer Science",
                enrollments: [.make(id: "enrollment1", enrollment_state: .invited)]
            ),
            in: context
        ),
        Course.save(
            .make(
                id: "2",
                name: "Advanced Mathematics",
                enrollments: [.make(id: "enrollment2", course_section_id: "section2", enrollment_state: .invited)]
            ),
            in: context
        ),
        Course.save(
            .make(
                id: "3",
                name: "English Literature",
                enrollments: [.make(id: "enrollment3", enrollment_state: .invited)]
            ),
            in: context
        )
    ]

    let mockInteractor = CoursesInteractorMock()
    mockInteractor.mockCoursesResult = .make(
        allCourses: mockCourses,
        invitedCourses: mockCourses
    )
    mockInteractor.getCoursesDelay = 2
    return mockInteractor
}

#Preview {
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    let env = PreviewEnvironment()
    let context = env.database.viewContext
    let snackBarViewModel = SnackBarViewModel()
    let coursesInteractor = makePreviewInteractor(context: context)

    let courseInvitations = CourseInvitationsWidgetViewModel(
        config: .make(id: .courseInvitations, order: 0),
        interactor: coursesInteractor,
        snackBarViewModel: snackBarViewModel
    )
    let helloWidget = HelloWidgetViewModel(
        config: .make(id: .helloWidget, order: 1),
        interactor: HelloWidgetInteractorPreview(),
        dayPeriodProvider: .init()
    )
    let coursesAndGroups = CoursesAndGroupsWidgetViewModel(
        config: .make(id: .coursesAndGroups, order: 2),
        interactor: .preview()
    )

    GeometryReader { geometry in
        ScrollView {
            DashboardWidgetLayout(
                fullWidthWidgets: [courseInvitations],
                gridWidgets: [helloWidget, coursesAndGroups],
                containerWidth: geometry.size.width
            )
            .paddingStyle(.horizontal, .standard)
            .snackBar(viewModel: snackBarViewModel)
        }
    }
    .onAppear {
        courseInvitations.refresh(ignoreCache: false).sink { _ in }.store(in: &subscriptions)
        helloWidget.refresh(ignoreCache: false).sink { _ in }.store(in: &subscriptions)
        coursesAndGroups.refresh(ignoreCache: false).sink { _ in }.store(in: &subscriptions)
    }
}

#endif
