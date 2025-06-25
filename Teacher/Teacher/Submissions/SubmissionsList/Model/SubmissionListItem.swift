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

    public let id: String
    let originalUserID: String
    let userNameModel: UserNameViewModel
    let userAsRecipient: Recipient?
    let status: SubmissionStatus
    let needsGrading: Bool
    let gradeFormatted: String

    init(submission: Submission, assignment: Assignment?, displayIndex: Int?) {
        self.id = submission.id
        self.originalUserID = submission.userID
        self.userNameModel = .init(submission: submission, assignment: assignment, displayIndex: displayIndex)
        self.userAsRecipient = submission.user.flatMap {
            Recipient(id: $0.id, name: $0.name, avatarURL: $0.avatarURL)
        }
        self.status = submission.statusIncludingGradedState
        self.needsGrading = submission.needsGrading
        self.gradeFormatted = GradeFormatter.shortString(for: assignment, submission: submission, blankPlaceholder: .oneDash)
    }
}

// MARK: - For Mocking

#if DEBUG

extension SubmissionListItem {

    private init(
        id: String,
        originalUserID: String,
        userNameModel: UserNameViewModel,
        userAsRecipient: Recipient?,
        status: SubmissionStatus,
        needsGrading: Bool,
        gradeFormatted: String
    ) {
        self.id = id
        self.originalUserID = originalUserID
        self.userNameModel = userNameModel
        self.userAsRecipient = userAsRecipient
        self.status = status
        self.needsGrading = needsGrading
        self.gradeFormatted = gradeFormatted
    }

    static func make(
        id: String = "",
        originalUserID: String = "",
        userNameModel: UserNameViewModel = .anonymousUser,
        userAsRecipient: Recipient? = nil,
        status: SubmissionStatus = .notSubmitted,
        needsGrading: Bool = false,
        gradeFormatted: String = "-"
    ) -> SubmissionListItem {
        SubmissionListItem(
            id: id,
            originalUserID: originalUserID,
            userNameModel: userNameModel,
            userAsRecipient: userAsRecipient,
            status: status,
            needsGrading: needsGrading,
            gradeFormatted: gradeFormatted
        )
    }
}

#endif
