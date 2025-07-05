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

public struct SubmissionListItem {

    let originalUserID: String
    let userNameModel: UserNameModel
    let userAsRecipient: Recipient?
    let status: SubmissionStatus
    let needsGrading: Bool
    let gradeFormatted: String

    private var hashOfProperties: Int

    private init(
        submissionId: String,
        originalUserID: String,
        userNameModel: UserNameModel,
        userAsRecipient: Recipient?,
        status: SubmissionStatus,
        needsGrading: Bool,
        gradeFormatted: String
    ) {
        self.originalUserID = originalUserID
        self.userNameModel = userNameModel
        self.userAsRecipient = userAsRecipient
        self.status = status
        self.needsGrading = needsGrading
        self.gradeFormatted = gradeFormatted

        let idHashSources: [AnyHashable] = [
            submissionId,
            userNameModel,
            status,
            needsGrading,
            gradeFormatted
        ]
        hashOfProperties = idHashSources.hashValue
    }

    init(submission: Submission, assignment: Assignment?, displayIndex: Int?) {
        self.init(
            submissionId: submission.id,
            originalUserID: submission.userID,
            userNameModel: .init(submission: submission, assignment: assignment, displayIndex: displayIndex),
            userAsRecipient: submission.user.flatMap {
                Recipient(id: $0.id, name: $0.name, avatarURL: $0.avatarURL)
            },
            status: submission.statusIncludingGradedState,
            needsGrading: submission.needsGrading,
            gradeFormatted: GradeFormatter.shortString(for: assignment, submission: submission, blankPlaceholder: .oneDash)
        )
    }
}

extension SubmissionListItem: Identifiable {
    public var id: Int { hashOfProperties }
}

// MARK: - For Mocking

#if DEBUG

extension SubmissionListItem {
    static func make(
        submissionId: String = "",
        originalUserID: String = "",
        userNameModel: UserNameModel = .anonymousUser,
        userAsRecipient: Recipient? = nil,
        status: SubmissionStatus = .notSubmitted,
        needsGrading: Bool = false,
        gradeFormatted: String = "-"
    ) -> SubmissionListItem {
        SubmissionListItem(
            submissionId: submissionId,
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
