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
import SwiftUI

struct CourseInvitationsWidgetView: View {
    @State var viewModel: CourseInvitationsWidgetViewModel

    var body: some View {
        if viewModel.state == .data {
            DashboardTitledWidget(widgetTitle) {
                HorizontalCarouselView(items: viewModel.invitations) { cardViewModel in
                    CourseInvitationCardView(viewModel: cardViewModel)
                }
            }
        }
    }

    private var widgetTitle: String {
        let count = viewModel.invitations.count
        return String(localized: "Course Invitations (\(count))", bundle: .student)
    }
}

#if DEBUG

#Preview {
    let config = DashboardWidgetConfig(id: .courseInvitations, order: 1, isVisible: true, settings: nil)
    let offlineModeInteractor = OfflineModeInteractorLive(isOfflineModeEnabledForApp: false)
    let coursesInteractor = CoursesInteractorLive()
    let viewModel = CourseInvitationsWidgetViewModel(
        config: config,
        interactor: coursesInteractor,
        offlineModeInteractor: offlineModeInteractor
    )

    CourseInvitationsWidgetView(viewModel: viewModel)
        .onAppear {
            _ = viewModel.refresh(ignoreCache: false)
        }
}

#endif
