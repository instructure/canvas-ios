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

import Foundation
import Core

public struct SubmissionListItem: Identifiable {
    struct User {
        let id: String
        let name: String
        let pronouns: String?
        let avatarURL: URL?

        var asRecipient: Recipient {
            Recipient(id: id, name: name, avatarURL: avatarURL)
        }

        var displayName: String {
            Core.User.displayName(name, pronouns: pronouns)
        }

        fileprivate init(id: String, name: String, pronouns: String? = nil, avatarURL: URL? = nil) {
            self.id = id
            self.name = name
            self.pronouns = pronouns
            self.avatarURL = avatarURL
        }
    }

    public let id: String
    let originalUserID: String
    let status: SubmissionStatus
    let groupID: String?
    let groupName: String?
    let gradeFormatted: String
    let needsGrading: Bool
    let user: User?
    var orderInList: Int = 0

    init(submission: Submission, assignment: Assignment?) {
        self.id = submission.id
        self.originalUserID = submission.userID
        self.groupID = submission.groupID
        self.groupName = submission.groupName
        self.user = submission.user.flatMap {
            return User(id: $0.id, name: $0.name, pronouns: $0.pronouns, avatarURL: $0.avatarURL)
        }
        self.status = submission.status(gradedChecked: true)
        self.needsGrading = submission.needsGrading
        self.gradeFormatted = GradeFormatter.shortString(for: assignment, submission: submission)
    }
}

// MARK: - For Mocking

#if DEBUG

extension SubmissionListItem.User {
    static func make(id: String, name: String, pronouns: String? = nil, avatarURL: URL? = nil) -> Self {
        SubmissionListItem.User(id: id, name: name, pronouns: pronouns, avatarURL: avatarURL)
    }
}

extension SubmissionListItem {

    fileprivate init(
        id: String,
        originalUserID: String,
        status: SubmissionStatus,
        gradeFormatted: String,
        needsGrading: Bool,
        user: User?,
        groupID: String?,
        groupName: String?
    ) {
        self.id = id
        self.originalUserID = originalUserID
        self.status = status
        self.gradeFormatted = gradeFormatted
        self.needsGrading = needsGrading
        self.user = user
        self.groupID = groupID
        self.groupName = groupName
    }

    static func make(
        id: String,
        originalUserID: String,
        status: SubmissionStatus,
        gradeFormatted: String = "-",
        needsGrading: Bool = false,
        user: User? = nil,
        groupID: String? = nil,
        groupName: String? = nil
    ) -> SubmissionListItem {
        SubmissionListItem(
            id: id,
            originalUserID: originalUserID,
            status: status,
            gradeFormatted: gradeFormatted,
            needsGrading: needsGrading,
            user: user,
            groupID: groupID,
            groupName: groupName
        )
    }
}

#endif
