//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct CourseInvitationCard: View {
    @ObservedObject var invitation: DashboardInvitationViewModel
    @Environment(\.appEnvironment) var env

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Image.invitationLine.foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.top, 10)
                    .accessibility(hidden: true)
                Spacer()
            }
            .background(Color.backgroundSuccess)
            VStack(alignment: .leading, spacing: 0) {
                invitation.stateText
                    .font(.semibold18)
                    .foregroundColor(.textDarkest)
                invitationName
                HStack(spacing: 16) {
                    declineButton
                    acceptButton
                }
                .padding(.top, invitation.state == .active ? 12 : 0)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.backgroundSuccess))
        .background(Color.backgroundLightest)
        .cornerRadius(4)
        .clipped()
    }

    private var declineButton: some View {
        Button(action: invitation.decline) {
            Text("Decline", bundle: .core)
                .font(.semibold16).foregroundColor(.textDark)
                .frame(maxWidth: .infinity, minHeight: 40)
                .frame(height: invitation.state == .active ? nil : 0)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderDark, lineWidth: 1 / UIScreen.main.scale))
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.backgroundLightest))
        }
        .identifier("CourseInvitation.\(invitation.id).rejectButton")
    }

    private var acceptButton: some View {
        Button(action: invitation.accept) {
            Text("Accept", bundle: .core)
                .font(.semibold16).foregroundColor(.textLightest)
                .frame(maxWidth: .infinity, minHeight: 40)
                .frame(height: invitation.state == .active ? nil : 0)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.backgroundSuccess))
        }
        .identifier("CourseInvitation.\(invitation.id).acceptButton")
    }

    private var invitationName: some View {
        Text(invitation.name)
            .font(.regular14)
            .foregroundColor(.textDarkest)
    }
}

#if DEBUG

struct CourseInvitationCard_Previews: PreviewProvider {
    class MockViewModel: DashboardInvitationViewModel {
        override var state: State { mockState }
        private let mockState: State

        init(name: String, state: State) {
            self.mockState = state
            super.init(name: name, courseId: "", enrollmentId: "")
        }
    }

    static var previews: some View {
        let view = VStack {
            CourseInvitationCard(invitation: DashboardInvitationViewModel(name: "Primary Course", courseId: "", enrollmentId: ""))
            CourseInvitationCard(invitation: MockViewModel(name: "Primary Course", state: .declined))
            CourseInvitationCard(invitation: MockViewModel(name: "Primary Course", state: .accepted))
        }

        view
            .previewDevice(PreviewDevice(stringLiteral: "iPhone 8 (15.4)"))
            .previewDisplayName("iOS 15")
    }
}

#endif
