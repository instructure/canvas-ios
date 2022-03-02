//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI

public struct K5HomeroomView: View {
    @Environment(\.horizontalPadding) private var horizontalPadding
    @ObservedObject private var viewModel: K5HomeroomViewModel

    public init(viewModel: K5HomeroomViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CircleRefresh { endRefreshing in
                viewModel.refresh(completion: endRefreshing)
            }

            VStack(alignment: .leading, spacing: 0) {
                conferences
                invitations
                accountAnnouncements

                Text(viewModel.welcomeText)
                    .foregroundColor(.licorice)
                    .font(.bold34)
                    .padding(.top)
                ForEach(viewModel.announcements) {
                    K5HomeroomAnnouncementView(viewModel: $0)
                        .padding(.vertical, 23)
                    Divider()
                        .padding(.horizontal, -horizontalPadding) // make sure the divider fills the parent view horizontally
                }

                K5HomeroomMySubjectsView(subjectCards: viewModel.subjectCards)
                    .padding(.top, 23)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }

    private var conferences: some View {
        ForEach(viewModel.conferencesViewModel.conferences, id: \.entity.id) { conference in
            ConferenceCard(conference: conference.entity, contextName: conference.contextName)
                .padding(.top, 16)
        }
    }

    private var invitations: some View {
        ForEach(viewModel.invitationsViewModel.invitations, id: \.id) { (id, course, enrollment) in
            CourseInvitationCard(course: course, enrollment: enrollment, id: id)
                .padding(.top, 16)
        }
    }

    private var accountAnnouncements: some View {
        ForEach(viewModel.accountAnnouncements, id: \.id) { announcement in
            NotificationCard(notification: announcement)
                .padding(.top, 16)
        }
    }
}

#if DEBUG

struct K5HomeroomView_Previews: PreviewProvider {
    static var previews: some View {
        K5HomeroomView(viewModel: K5HomeroomViewModel()).previewLayout(.sizeThatFits)
    }
}

#endif
