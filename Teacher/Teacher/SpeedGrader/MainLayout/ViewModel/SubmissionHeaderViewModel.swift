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

class SubmissionHeaderViewModel: ObservableObject {
    let submitterName: String
    let groupName: String?
    let isGroupSubmission: Bool
    let routeToSubmitter: String?

    init(
        assignment: Assignment,
        submission: Submission
    ) {
        let isGroupSubmission = !assignment.gradedIndividually && submission.groupID != nil
        self.isGroupSubmission = isGroupSubmission

        let groupName = isGroupSubmission ? submission.groupName : nil
        self.groupName = groupName

        submitterName = {
            groupName ?? (submission.user.flatMap { User.displayName($0.name, pronouns: $0.pronouns) } ?? "")
        }()
        routeToSubmitter = isGroupSubmission ? nil : "/courses/\(assignment.courseID)/users/\(submission.userID)"
    }
}
