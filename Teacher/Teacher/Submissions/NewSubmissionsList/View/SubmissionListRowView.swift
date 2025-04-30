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
    let row: Int
    let submission: Submission
    let assignment: Assignment?

    var body: some View {
        HStack(spacing: 16) {
            avatarView
            VStack(alignment: .leading, spacing: 4) {
                nameLabel
                if submission.needsGrading {
                    HStack(spacing: 4) {
                        statusLabel
                        statusDivider
                        needsGradingLabel
                    }
                } else {
                    statusLabel
                }
            }
            Spacer()
            gradeText
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
    }

    @ViewBuilder
    private var avatarView: some View {
        if assignment?.anonymizeStudents != false {
            Avatar.Anonymous(isGroup: submission.groupID != nil)
        } else if let groupName = submission.groupName {
            Avatar(name: groupName, url: nil)
        } else {
            Avatar(
                name: submission.user?.name ?? "",
                url: submission.user?.avatarURL
            )
        }
    }

    private var nameLabel: some View {
        let nameText: Text = if assignment?.anonymizeStudents != false {
            if submission.groupID != nil {
                Text("Group \(row)", bundle: .teacher)
            } else {
                Text("Student \(row)", bundle: .teacher)
            }
        } else {
            Text(
                submission.groupName ?? submission.user.flatMap {
                    User.displayName($0.name, pronouns: $0.pronouns)
                } ?? ""
            )
        }

        return nameText
            .font(.semibold16)
            .foregroundStyle(Color.textDarkest)
    }

    private var statusLabel: some View {
        HStack(spacing: 2) {
            submission.status.appearance.icon.size(16)
            Text(submission.status.text)
        }
        .font(.regular14)
        .foregroundStyle(submission.status.appearance.color)
    }

    private var statusDivider: some View {
        Text(verbatim: "|").font(.regular14).foregroundStyle(Color.borderMedium)
    }

    private var needsGradingLabel: some View {
        Text("Needs Grading", bundle: .teacher)
            .font(.regular14)
            .foregroundStyle(Color.textWarning)
    }

    private var gradeText: some View {
        let grade = GradeFormatter.shortString(for: assignment, submission: submission)
        return Text(grade)
            .font(.semibold16)
            .foregroundStyle(Color.course2)
    }
}

extension SubmissionStatus {
    fileprivate struct Appearance {
        let submissionStatus: SubmissionStatus
    }

    fileprivate var appearance: Appearance { Appearance(submissionStatus: self) }
}

extension SubmissionStatus.Appearance {

    var color: Color {
        switch submissionStatus {
        case .late:
            return .textWarning
        case .missing:
            return .textDanger
        case .submitted:
            return .textSuccess
        case .notSubmitted:
            return .textDark
        }
    }

    var icon: Image {
        switch submissionStatus {
        case .submitted:
            return .completeLine
        case .late:
            return .clockSolid
        case .missing, .notSubmitted:
            return .noSolid
        }
    }
}
