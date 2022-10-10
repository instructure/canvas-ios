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

import XCTest

public enum K5Grades: ElementWrapper {

    public static var gradingPeriodSelectorClosed: Element {
        app.find(label: "Select Grading Period, Closed")
    }

    public static var gradingPeriodSelectorOpen: Element {
        app.find(label: "Select Grading Period, Open")
    }

    public static var currentGradingPeriod: Element {
        app.find(label: "Current Grading Period")
    }
}

public enum K5CourseGrades: ElementWrapper {

    public static var emptyGradesForCourse: Element {
        app.find(label: "You don't have any grades yet.")
    }

    public static func gradedPointsOutOf(actual: String, outOf: String) -> Element {
        app.find(label: "Grade, \(actual) out of \(outOf)")
    }

    public static func gradedPointsMax(maxPoints: String) -> Element {
        app.find(label: "Out of \(maxPoints) pts")
    }

    public static func gradedPointsActual(actualPoints: String) -> Element {
        app.find(label: "\(actualPoints) pts")
    }
}
