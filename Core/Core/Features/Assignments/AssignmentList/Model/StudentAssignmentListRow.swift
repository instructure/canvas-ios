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
import SwiftUI

struct StudentAssignmentListRow: Equatable, Identifiable {

    let id: String
    let title: String
    let icon: Image

    let dueDate: String
    let submissionStatus: SubmissionStatusLabel.Model
    let score: String?

    let route: URL?

    init(assignment: Assignment) {
        let stateDisplayProperties = assignment.submission?.stateDisplayProperties ?? .usingStatus(.notSubmitted)

        self.id = assignment.id
        self.title = assignment.name
        self.icon = assignment.icon.asImage
        self.dueDate = assignment.formattedDueDate
        self.submissionStatus = .init(stateDisplayProperties: stateDisplayProperties)
        let hasPointsPossible = assignment.pointsPossible != nil
        self.score = hasPointsPossible ? GradeFormatter.string(from: assignment, style: .medium) : nil
        self.route = assignment.htmlURL
    }
}

private extension Assignment {
    var formattedDueDate: String {
        if let lockAt, Clock.now > lockAt {
            return String(localized: "Availability: Closed", bundle: .core)
        }

        return dueText
    }
}

#if DEBUG

extension StudentAssignmentListRow {
    private init(
        id: String,
        title: String,
        icon: Image,
        dueDate: String,
        submissionStatus: SubmissionStatusLabel.Model,
        score: String?,
        route: URL?
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.dueDate = dueDate
        self.submissionStatus = submissionStatus
        self.score = score
        self.route = route
    }

    public static func make(
        id: String = "",
        title: String = "",
        icon: Image = .emptyLine,
        dueDate: String = "",
        submissionStatus: SubmissionStatusLabel.Model = .init(text: "", icon: .emptyLine, color: .clear),
        score: String? = nil,
        route: URL? = nil
    ) -> Self {
        self.init(
            id: id,
            title: title,
            icon: icon,
            dueDate: dueDate,
            submissionStatus: submissionStatus,
            score: score,
            route: route
        )
    }
}

#endif
