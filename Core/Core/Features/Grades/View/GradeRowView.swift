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
    public let gradeRowEntry: GradeRowEntry
    public let isWhatIfScoreModeOn: Bool
    public let editScoreButtonDidTap: () -> Void

    @ScaledMetric private var uiScale: CGFloat = 1

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            assignmentIcon
            HStack(spacing: 0) {
                assignmentDetailsView
                Spacer()
                if isWhatIfScoreModeOn {
                    gradeText.padding(.leading, 16)
                    editButton
                } else {
                    gradeText.padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("GradeListCell.\(gradeRowEntry.id)")
    }

    private var assignmentIcon: some View {
        Image(uiImage: gradeRowEntry.assignmentIcon)
            .padding(.top, 12)
            .padding(.leading, 22)
            .padding(.trailing, 18)
    }

    private var assignmentDetailsView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(gradeRowEntry.assignmentName)
                .font(.medium16)
                .foregroundStyle(Color.textDarkest)
                .multilineTextAlignment(.leading)
            Text(gradeRowEntry.dueText)
                .font(.regular14)
                .foregroundStyle(Color.textDark)
                .multilineTextAlignment(.leading)

            HStack(spacing: 2) {
                gradeRowEntry.statusIcon
                    .size(uiScale.iconScale * 18)
                Text(gradeRowEntry.statusText)
                    .font(.regular14)
            }
            .foregroundStyle(gradeRowEntry.statusColor)
        }
    }

    private var gradeText: some View {
        Text(gradeRowEntry.gradeText)
            .font(.regular16)
            .foregroundStyle(Color.textDarkest)
            .accessibilityLabel(Text(gradeRowEntry.gradeAccessibilityLabel))
    }

    private var editButton: some View {
        Button {
            editScoreButtonDidTap()
        } label: {
            Image(uiImage: .editLine)
                .resizable()
                .frame(width: 20, height: 20)
        }
        .frame(width: 44, height: 44)
        .padding(.trailing, 6)
    }
}

extension GradeRowView: Equatable {

    public static func == (lhs: GradeRowView, rhs: GradeRowView) -> Bool {
        lhs.gradeRowEntry == rhs.gradeRowEntry && lhs.isWhatIfScoreModeOn == rhs.isWhatIfScoreModeOn
    }
}

#if DEBUG

struct GradeRowViewPreview: PreviewProvider {
    static var previews: some View {
        let assignment = Assignment.save(
            .make(name: "Radiation Processes - ASTR 25400"),
            in: PreviewEnvironment().globalDatabase.viewContext,
            updateSubmission: false,
            updateScoreStatistics: false
        )
        GradeRowView(
            gradeRowEntry: GradeRowEntry(assignment: assignment, userID: ""),
            isWhatIfScoreModeOn: true,
            editScoreButtonDidTap: {}
        )
    }
}

#endif
