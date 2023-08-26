//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class K5Helper: BaseHelper {
    static let dateFormatter = DateFormatter()
    public static var homeroom: XCUIElement { app.find(label: "Homeroom", type: .button) }
    public static var schedule: XCUIElement { app.find(label: "Schedule", type: .button) }
    public static var grades: XCUIElement { app.find(label: "Grades", type: .button) }
    public static var resources: XCUIElement { app.find(label: "Resources", type: .button) }
    public static var importantDates: XCUIElement { app.find(label: "Important Dates", type: .button) }

    public struct Homeroom {
        public static var mySubjects: XCUIElement { app.find(label: "My Subjects", type: .staticText) }
        public static func welcomeMessage(student: DSUser) -> XCUIElement {
            return app.find(label: "Welcome, \(student.name)!")
        }
    }

    public struct Schedule {
        public static var today: XCUIElement { app.find(id: "K5Schedule.today") }
        public static var nextWeekButton: XCUIElement { app.find(label: "Next Week", type: .button) }

        public static func assignmentItemButton(assignment: DSAssignment) -> XCUIElement {
            if assignment.due_at!.isFutureDate && Date.now.weekdayName == "Saturday" { nextWeekButton.hit() }
            K5Helper.dateFormatter.dateFormat = "h:mm a"
            let due = K5Helper.dateFormatter.string(from: assignment.due_at!)
            let pointsString = assignment.points_possible! == 1 ? "pt" : "pts"
            let labelToFind = "\(assignment.name), \(assignment.points_possible!) \(pointsString), Due: \(due)"
            let element = app.find(label: labelToFind, type: .button)
            app.actionUntilElementCondition(action: .swipeUp(), element: element, condition: .visible)
            app.actionUntilElementCondition(action: .swipeUp(), element: element, condition: .hittable)
            return element
        }

        public static func quizItemButton(quiz: DSQuiz) -> XCUIElement {
            if quiz.due_at!.isFutureDate && Date.now.weekdayName == "Saturday" { nextWeekButton.hit() }
            K5Helper.dateFormatter.dateFormat = "h:mm a"
            let due = K5Helper.dateFormatter.string(from: quiz.due_at!)
            let pointsString = quiz.points_possible! == 1 ? "pt" : "pts"
            let labelToFind = "\(quiz.title), \(quiz.points_possible!) \(pointsString), Due: \(due)"
            let element = app.find(label: labelToFind, type: .button)
            app.actionUntilElementCondition(action: .swipeUp(), element: element, condition: .visible)
            app.actionUntilElementCondition(action: .swipeUp(), element: element, condition: .hittable)
            return element
        }
    }

    public struct Grades {
        public static var selectGradingPeriodButton: XCUIElement { app.find(labelContaining: "Select Grading Period", type: .button) }
        public static var currentGradingPeriodButton: XCUIElement { app.find(label: "Current Grading Period", type: .button) }

        public static func courseProgressCard(course: DSCourse) -> XCUIElement { return app.find(labelContaining: course.name.uppercased()) }
    }
}
