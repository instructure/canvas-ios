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

import Combine
import Core
import SwiftUI

struct CourseInvitationsWidgetView: View {
    @State var viewModel: CourseInvitationsWidgetViewModel

    var body: some View {
        ZStack {
            if viewModel.state == .data {
                DashboardTitledWidget(widgetTitle) {
                    HorizontalCarouselView(items: viewModel.invitations) { cardViewModel in
                        CourseInvitationCardView(viewModel: cardViewModel)
                    }
                }
            }
        }
        .animation(.smooth, value: viewModel.invitations)
    }

    private var widgetTitle: String {
        let count = viewModel.invitations.count
        return String(localized: "Course Invitations (\(count))", bundle: .student)
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    return CourseInvitationsWidgetView(viewModel: viewModel)
        .padding()
        .onAppear {
            viewModel.refresh(ignoreCache: false)
                .sink { _ in }
                .store(in: &subscriptions)
        }
}

private func makePreviewViewModel() -> CourseInvitationsWidgetViewModel {
    let env = PreviewEnvironment()
    let context = env.database.viewContext

    let config = DashboardWidgetConfig(id: .courseInvitations, order: 1, isVisible: true, settings: nil)
    let offlineModeInteractor = OfflineModeInteractorMock()
    let coursesInteractor = CoursesInteractorMock()

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
                enrollments: [.make(id: "enrollment2", enrollment_state: .invited)]
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

    coursesInteractor.mockCoursesResult = CoursesResult(
        allCourses: mockCourses,
        invitedCourses: mockCourses
    )

    return CourseInvitationsWidgetViewModel(
        config: config,
        interactor: coursesInteractor,
        offlineModeInteractor: offlineModeInteractor
    )
}

#endif
