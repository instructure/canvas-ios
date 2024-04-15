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

import SwiftUI

public struct GradeRowView: View {
    public let assignment: Assignment
    public let userID: String?

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            assignmentIcon
            HStack(spacing: 0) {
                assignmentDetailsView
                Spacer()
                gradeText
            }
            .padding(.vertical, 12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("GradeListCell.\(assignment.id)")
    }

    private var assignmentIcon: some View {
        Image(uiImage: assignment.icon ?? .assignmentLine)
            .padding(.top, 12)
            .padding(.leading, 22)
            .padding(.trailing, 18)
    }

    private var assignmentDetailsView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(assignment.name)
                .font(.medium16)
                .foregroundStyle(Color.textDarkest)
                .multilineTextAlignment(.leading)
            Text(assignment.dueText)
                .font(.regular14)
                .foregroundStyle(Color.textDark)
                .multilineTextAlignment(.leading)

            let submission = assignment.submissions?.first { $0.userID == userID }
            let status = submission?.status ?? .notSubmitted

            if assignment.isOnline {
                Text(status.text)
                    .foregroundStyle(Color(status.color))
                    .font(.regular14)
            }
        }
    }

    private var gradeText: some View {
        Text(GradeFormatter.string(
            from: assignment,
            userID: userID,
            style: .medium
        ) ?? "")
            .font(.regular16)
            .foregroundStyle(Color.textDarkest)
            .padding(.horizontal, 16)
            .accessibilityLabel(Text(
                GradeFormatter.a11yString(
                    from: assignment,
                    userID: userID,
                    style: .medium
                )
                .flatMap { String(localized: "Grade") + ", " + $0 } ?? ""
            ))
    }
}

#if DEBUG

struct GradeRowViewPreview: PreviewProvider {
    static var previews: some View {
        GradeRowView(
            assignment: .save(
                .make(name: "Radiation Processes - ASTR 25400"),
                in: PreviewEnvironment().globalDatabase.viewContext,
                updateSubmission: false,
                updateScoreStatistics: false
            ),
            userID: ""
        )
    }
}

#endif
