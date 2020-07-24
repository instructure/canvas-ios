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

import XCTest

public enum AssignmentDetails: String, ElementWrapper {
    case allowedExtensions
    case due
    case gradeCell
    case gradeCircle
    case circleComplete
    case gradeCircleOutOf
    case gradeDisplayGrade
    case gradeLatePenalty
    case name
    case points
    case status
    case submissionTypes
    case submittedText
    case submitAssignmentButton
    case viewSubmissionButton
    case fileSubmissionButton
    case lockIcon
    case lockSection
    case replyButton // parent

    public static func description(_ description: String) -> Element {
        return app.find(label: description)
    }

    public static func link(_ description: String) -> Element {
        return app.webViews.staticTexts.matching(label: description).firstElement
    }

    public static var viewAllSubmissionsButton: Element {
        return app.find(id: "assignment-details.assignment-section.submissions")
    }
}

public enum AssignmentsList {
    public static func assignment(id: String) -> Element {
        return app.find(id: "assignment-list.assignment-list-row.cell-\(id)")
    }
}

public enum GradeList {
    public static var title: Element {
        return app.find(label: "Grades")
    }

    public static func cell(assignmentID: String) -> Element {
        return app.find(id: "GradeListCell.\(assignmentID)")
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
