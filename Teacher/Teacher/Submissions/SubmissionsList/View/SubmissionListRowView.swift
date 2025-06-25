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
                        HStack(alignment: .top, spacing: 4) {
                            statusLabel
                                .layoutPriority(1)
                            statusDivider
                            needsGradingLabel
                        }
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

    @ViewBuilder
    private var avatarView: some View {
        if anonymizeStudents != false {
            Avatar(model: item.groupID != nil ? .anonymousGroup : .anonymousUser)
        } else if let groupName = item.groupName {
            Avatar(name: groupName, url: nil)
        } else {
            Avatar(
                name: item.user?.name ?? "",
                url: item.user?.avatarURL
            )
        }
    }

    private var nameLabel: some View {
        let nameText: Text = if anonymizeStudents != false {
            if item.groupID != nil {
                Text("Group \(item.orderInList)", bundle: .teacher)
            } else {
                Text("Student \(item.orderInList)", bundle: .teacher)
            }
        } else {
            Text(
                item.groupName ?? item.user.flatMap {
                    User.displayName($0.name, pronouns: $0.pronouns)
                } ?? ""
            )
        }

        return nameText
            .multilineTextAlignment(.leading)
            .font(.semibold16)
            .foregroundStyle(Color.textDarkest)
    }

    private var statusLabel: some View {
        HStack(alignment: .center, spacing: 2) {
            item.status.redesignAppearance.icon.scaledIcon(size: 16)
            Text(item.status.text).multilineTextAlignment(.leading)
        }
        .font(.regular14)
        .foregroundStyle(item.status.redesignAppearance.color)
        .accessibilityHidden(isGradeBlank == false && item.status == .graded)
    }

    private var statusDivider: some View {
        Color
            .borderMedium
            .frame(width: 1)
            .padding(.vertical, 2)
            .accessibilityHidden(true)
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

// MARK: - Submission Status for Redesign List

private extension SubmissionStatus {
    struct RedesignAppearance {
        let submissionStatus: SubmissionStatus
    }

    var redesignAppearance: RedesignAppearance {
        RedesignAppearance(submissionStatus: self)
    }
}

private extension SubmissionStatus.RedesignAppearance {

    var color: Color {
        switch submissionStatus {
        case .late, .excused:
            return .textWarning
        case .missing:
            return .textDanger
        case .submitted, .graded:
            return .textSuccess
        case .notSubmitted:
            return .textDark
        }
    }

    var icon: Image {
        switch submissionStatus {
        case .submitted:
            return .completeLine
        case .graded, .excused:
            return .completeSolid
        case .late:
            return .clockLine
        case .missing, .notSubmitted:
            return .noSolid
        }
    }
}
