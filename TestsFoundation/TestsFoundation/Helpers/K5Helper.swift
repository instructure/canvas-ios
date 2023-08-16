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
        public static var cells: [XCUIElement] { app.find(type: .collectionView).findAll(type: .cell) }

        public static func cellOfDate(date: Date) -> XCUIElement {
            dateFormatter.dateFormat = "MMMM d"
            let formattedDate = dateFormatter.string(from: date)
            let allCells = cells
            let cell = allCells.filter({ $0.find(label: formattedDate, type: .staticText).isVisible })[0]
            return allCells[allCells.firstIndex(of: cell)! + 1]
        }

        public static func titleOfItem(cell: XCUIElement, title: String) -> XCUIElement { return cell.find(label: title, type: .staticText) }
    }

    public struct Grades {
        public static var selectGradingPeriodButton: XCUIElement { app.find(labelContaining: "Select Grading Period", type: .button) }
        public static var currentGradingPeriodButton: XCUIElement { app.find(label: "Current Grading Period", type: .button) }

        public static func courseProgressCard(course: DSCourse) -> XCUIElement { return app.find(labelContaining: course.name.uppercased()) }
    }
}
