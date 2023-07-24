//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public enum AssignmentDetails: String, ElementWrapper {
    case allowedExtensions
    case attemptsView
    case circleComplete
    case due
    case fileSubmissionButton
    case gradeCell
    case gradeCircle
    case gradeCircleOutOf
    case gradeDisplayGrade
    case gradeLatePenalty
    case lockIcon
    case lockSection
    case name
    case points
    case replyButton // parent
    case status
    case submissionTypes
    case submitAssignmentButton
    case submittedText
    case viewAllSubmissionsButton // teacher
    case viewSubmissionButton
    case published
    case unpublished

    public static func description(_ description: String) -> Element {
        return app.find(label: description)
    }

    public static func link(_ description: String) -> Element {
        return app.webViews.staticTexts.matching(label: description).firstElement
    }

    public static func pointsOutOf(actualScore: String, maxScore: String) -> Element {
        app.find(id: "AssignmentDetails.gradeCircle", label: "Scored \(actualScore) out of \(maxScore) points possible")
    }
}

public enum AssignmentsList {
    public static func assignment(id: String) -> Element {
        return app.find(id: "assignment-list.assignment-list-row.cell-\(id)")
    }
}

public enum QuizzesNext {
    public static func text(_ description: String) -> Element {
        return app.webViews.staticTexts.matching(label: description).firstElement
    }

    public static var beginButton: Element {
        return app.webViews.buttons.matching(label: "Begin").firstElement
    }

    public static var doneButton: Element {
        return app.buttons.matching(label: "Done").firstElement
    }
}
