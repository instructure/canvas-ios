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
    public let courseColor: Color

    private let env: AppEnvironment

    public init(env: AppEnvironment, assignment: Assignment, courseColor: UIColor?) {
        self.env = env
        self.assignment = assignment
        self.courseColor = Color(courseColor ?? .textDark)
    }

    public var route: URL? { assignment.htmlURL }
    public var icon: UIImage { assignment.icon }
    public var name: String { assignment.name }
    public var submissionStatus: String { stateDisplayProperties.text }
    public var submissionIcon: UIImage { stateDisplayProperties.icon }
    public var submissionColor: Color { .init(stateDisplayProperties.color) }
    public let defaultTextColor: Color = .textDark
    public var hasPointsPossible: Bool { scoreLabel != nil }
    public var pointsPossibleText: String { assignment.pointsPossibleCompleteText }

    // Teacher
    public var isTeacher: Bool { env.app == .teacher }
    public var needsGrading: Bool { assignment.needsGradingCount > 0 }
    public var needsGradingCount: Int { assignment.needsGradingCount }

    public var scoreLabel: String? {
        guard let pointsPossible = assignment.pointsPossible else { return nil }
        var scoreString = "-"
        if let viewableScore = assignment.viewableScore {
            scoreString = String(Int(viewableScore))
        }
        return "\(scoreString)/\(String(Int(pointsPossible)))"
    }

    public var published: Bool? {
        guard isTeacher else { return nil }
        return assignment.published
    }

    public var needsGradingText: String? {
        guard assignment.needsGradingCount > 0, assignment.gradingType != .not_graded else {
            return nil
        }

        let format = String(localized: "d_needs_grading", bundle: .core)
        return String.localizedStringWithFormat(format, needsGradingCount).localizedCapitalized
    }

    public var formattedDueDate: String {
        if let lockAt = assignment.lockAt, Clock.now > lockAt {
            return String(localized: "Availability: Closed", bundle: .core)
        }

        if assignment.hasMultipleDueDates {
            return String(localized: "Multiple Due Dates", bundle: .core)
        }

        return assignment.dueText
    }

    private var stateDisplayProperties: SubmissionStateDisplayProperties {
        assignment.submission?.stateDisplayProperties ?? .usingStatus(.notSubmitted)
    }
}

// MARK: - Preview

#if DEBUG
extension AssignmentCellViewModel {
    public convenience init(assignment: Assignment, courseColor: UIColor?) {
        self.init(env: .shared, assignment: assignment, courseColor: courseColor)
    }
}
#endif
