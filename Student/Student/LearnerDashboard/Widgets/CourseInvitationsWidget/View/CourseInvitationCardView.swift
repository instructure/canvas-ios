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

struct CourseInvitationCardView: View {
    let invitation: CourseInvitation
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("You have been invited", bundle: .student)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundColor(.textDark)

                Text(invitation.courseName)
                    .font(.medium16, lineHeight: .fit)
                    .foregroundColor(.textDarkest)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 14)

            HStack(spacing: 12) {
                Button(action: onAccept) {
                    Text("Accept", bundle: .student)
                        .font(.semibold12, lineHeight: .fit)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background(Color(uiColor: UIColor(hexString: "#2573DF")!))
                .cornerRadius(100)
                .accessibilityLabel(Text("Accept invitation to \(invitation.courseName)"))

                Button(action: onDecline) {
                    Text("Decline", bundle: .student)
                        .font(.regular12, lineHeight: .fit)
                        .foregroundColor(.textDarkest)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background(Color.backgroundLightest)
                .cornerRadius(100)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.borderMedium, lineWidth: 0.5)
                )
                .accessibilityLabel(Text("Decline invitation to \(invitation.courseName)"))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .elevation(.cardLarge, background: .backgroundLightest)
    }
}

#if DEBUG

#Preview {
    CourseInvitationCardView(
        invitation: CourseInvitation(
            id: "1",
            courseName: "Introduction to Computer Science",
            invitedBy: "Dr. Sarah Johnson",
            invitedAt: Date()
        ),
        onAccept: {},
        onDecline: {}
    )
    .padding()
}

#endif
