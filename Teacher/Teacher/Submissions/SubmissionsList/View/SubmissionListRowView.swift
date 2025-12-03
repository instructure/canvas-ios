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

import SwiftUI
import Core

struct SubmissionListRowView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let anonymizeStudents: Bool?
    let item: SubmissionListItem

    var body: some View {
        HStack(spacing: 12) {
            avatarView
                .layoutPriority(3)
            VStack(alignment: .leading, spacing: 4) {
                nameLabel
                    .layoutPriority(1)
                if item.needsGrading {
                    if dynamicTypeSize < .accessibility3 {
                        InstUI.JoinedSubtitleLabels(
                            label1: { statusLabel },
                            label2: { needsGradingLabel },
                            alignment: .top
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            statusLabel
                            needsGradingLabel
                        }
                    }
                } else {
                    statusLabel
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
            gradeLabel
                .layoutPriority(2)
        }
        .paddingStyle(set: .standardCell)
        .accessibilityIdentifier("SubmissionListCell.\(item.originalUserID)")
    }

    private var avatarView: some View {
        Avatar(model: item.userNameModel)
    }

    private var nameLabel: some View {
        return Text(item.userNameModel.name)
            .multilineTextAlignment(.leading)
            .font(.semibold16)
            .foregroundStyle(Color.textDarkest)
    }

    private var statusLabel: some View {
        SubmissionStatusLabel(model: item.status)
            .accessibilityHidden(isGradeBlank == false && item.status == .graded)
    }

    private var needsGradingLabel: some View {
        Text("Needs Grading", bundle: .teacher)
            .font(.regular14)
            .foregroundStyle(Color.textWarning)
            .multilineTextAlignment(.leading)
    }

    private var isGradeBlank: Bool {
        return item
            .gradeFormatted
            .replacingOccurrences(of: "-", with: "")
            .trimmed()
            .isEmpty
    }

    private var gradeLabel: some View {
        let grade = item.gradeFormatted
        let accLabelFormat = String(
            localized: "Graded to %@",
            bundle: .teacher,
            comment: "Examples: Graded to A, Graded to 95%"
        )
        return Text(item.gradeFormatted)
            .font(.semibold16)
            .foregroundStyle(Color.course2)
            .accessibilityLabel(Text(String(format: accLabelFormat, grade)))
            .accessibilityHidden(isGradeBlank)
    }
}
