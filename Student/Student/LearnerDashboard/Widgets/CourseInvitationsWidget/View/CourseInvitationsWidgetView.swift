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
            LearnerDashboardTitledWidget(widgetTitle) {
                HorizontalCarouselView(items: viewModel.invitations) { invitation in
                    CourseInvitationCardView(
                        invitation: invitation,
                        onAccept: { viewModel.acceptInvitation(id: invitation.id) },
                        onDecline: { viewModel.declineInvitation(id: invitation.id) }
                    )
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
    let config = WidgetConfig(id: .courseInvitations, order: 1, isVisible: true, settings: nil)
    let interactor = CourseInvitationsInteractorLive()
    let viewModel = CourseInvitationsWidgetViewModel(config: config, interactor: interactor)

    CourseInvitationsWidgetView(viewModel: viewModel)
        .onAppear {
            _ = viewModel.refresh(ignoreCache: false)
        }
}

#endif
