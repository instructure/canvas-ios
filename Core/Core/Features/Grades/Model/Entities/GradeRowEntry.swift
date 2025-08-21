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

import Combine
import SwiftUI

public struct GradeRowEntry: Equatable {
    public let userID: String?

    public let id: String
    public let assignmentName: String
    public let assignmentIcon: UIImage
    public let dueText: String
    public let gradeText: String
    public let gradeAccessibilityLabel: String
    public let statusIcon: Image
    public let statusText: String
    public let statusColor: Color

    public init(assignment: Assignment, userID: String?) {
        self.id = assignment.id
        self.userID = userID
        self.assignmentName = assignment.name
        self.assignmentIcon = assignment.icon
        self.dueText = assignment.dueText

        let submission = assignment.submissions?.first { $0.userID == userID }

        let submissionDisplayProperties = submission?.stateDisplayProperties ?? .usingStatus(.notSubmitted)
        self.statusIcon = Image(uiImage: submissionDisplayProperties.icon)
        self.statusColor = Color(submissionDisplayProperties.color)
        self.statusText = submissionDisplayProperties.text

        self.gradeText = GradeFormatter.string(
            from: assignment,
            userID: userID,
            style: .medium
        ) ?? ""

        let gradeA11yString = GradeFormatter.a11yString(
            from: assignment,
            userID: userID,
            style: .medium
        )
        self.gradeAccessibilityLabel = gradeA11yString
            .flatMap { String(localized: "Grade", bundle: .core) + ", " + $0 } ?? ""
    }
}
