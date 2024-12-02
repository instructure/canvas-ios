//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class AssignmentCellViewModel: ObservableObject {
    public let assignment: Assignment
    public let courseColor: UIColor?

    private let env = AppEnvironment.shared

    public init(assignment: Assignment, courseColor: UIColor?) {
        self.assignment = assignment
        self.courseColor = courseColor
    }

    public var route: URL? { assignment.htmlURL }
    var icon: UIImage { assignment.icon ?? .assignmentLine }
    var name: String { assignment.name }
    var submissionStatus: String { assignment.submission?.stateDisplayProperties.text ?? SubmissionStatus.notSubmitted.text }
    var submissionIcon: UIImage { assignment.submission?.stateDisplayProperties.icon ?? SubmissionStatus.notSubmitted.icon }
    var submissionColor: Color { .init(assignment.submission?.stateDisplayProperties.color ?? SubmissionStatus.notSubmitted.color) }
    let defaultTextColor: Color = .textDark
    let brandColor: Color = .init(Brand.shared.primary)
    var hasPointsPossible: Bool { scoreLabel != nil }
    var pointsPossibleText: String { assignment.pointsPossibleCompleteText }

    // Teacher
    var isTeacher: Bool { env.app == .teacher }
    var needsGrading: Bool { assignment.needsGradingCount > 0 }
    var needsGradingCount: Int { assignment.needsGradingCount }

    private var formattedDueAt: String? {
        guard let dueAt = assignment.dueAt else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL d, y h:mm a"
        return dateFormatter.string(from: dueAt)
    }

    var scoreLabel: String? {
        guard let pointsPossible = assignment.pointsPossible else { return nil }
        var scoreString = "-"
        if let viewableScore = assignment.viewableScore {
            scoreString = String(Int(viewableScore))
        }
        return "\(scoreString)/\(String(Int(pointsPossible)))"
    }

    var published: Bool? {
        guard isTeacher else { return nil }
        return assignment.published
    }

    var needsGradingText: String? {
        guard assignment.needsGradingCount > 0, assignment.gradingType != .not_graded else {
            return nil
        }

        let format = String(localized: "d_needs_grading", bundle: .core)
        return String.localizedStringWithFormat(format, needsGradingCount).localizedCapitalized
    }

    var formattedDueDate: String {
        if let lockAt = assignment.lockAt, Clock.now > lockAt {
            return String(localized: "Availability: Closed", bundle: .core)
        }

        if assignment.hasMultipleDueDates {
            return String(localized: "Multiple Due Dates", bundle: .core)
        }

        if let dueAt = formattedDueAt {
            let format = String(localized: "Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 9:00 PM>")
            return String.localizedStringWithFormat(format, dueAt)
        }

        return String(localized: "No Due Date", bundle: .core)
    }
}
