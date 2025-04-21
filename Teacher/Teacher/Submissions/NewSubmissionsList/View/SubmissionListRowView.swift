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
    let submission: Submission
    let assignment: Assignment?

    var body: some View {
        HStack(spacing: 16) {
            Avatar(
                name: submission.userName,
                url: submission.imageUrl
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(submission.userName)
                    .font(.medium16)
                    .foregroundStyle(Color.textDarkest)
                Text(submission.statusText)
                    .font(.regular14)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Text(submission.gradeText)
                .font(.semibold16)
                .foregroundStyle(Color.course2)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
    }
}

extension Submission {
    var userName: String {
        return user.flatMap({ User.displayName($0.name, pronouns: $0.pronouns) }) ?? groupName ?? ""
    }

    var imageUrl: URL? {
        return user?.avatarURL
    }

    var statusText: String {
        return status.text ?? ""
    }

    var gradeText: String {
        GradeFormatter.shortString(for: assignment, submission: self)
    }
}

//backgroundColor = .backgroundLightest
//if assignment?.anonymizeStudents != false {
//    if submission?.groupID != nil {
//        avatarView.icon = .groupLine
//        nameLabel.text = String(localized: "Group \(row)", bundle: .teacher)
//    } else {
//        avatarView.icon = .userLine
//        nameLabel.text = String(localized: "Student \(row)", bundle: .teacher)
//    }
//} else if let name = submission?.groupName {
//    avatarView.name = name
//    avatarView.url = nil
//    nameLabel.text = name
//} else {
//    avatarView.name = submission?.user?.name ?? ""
//    avatarView.url = submission?.user?.avatarURL
//    nameLabel.text = submission?.user.flatMap {
//        User.displayName($0.name, pronouns: $0.pronouns)
//    }
//}
//statusIconView.image = submission?.status.icon
//statusIconView.tintColor = submission?.status.color
//statusLabel.text = submission?.status.text
//statusLabel.textColor = submission?.status.color
//needsGradingView.isHidden = submission?.needsGrading != true
//gradeLabel.text = GradeFormatter.shortString(for: assignment, submission: submission)
//hiddenView.isHidden = submission?.postedAt != nil || (submission?.score == nil && submission?.grade == nil)

