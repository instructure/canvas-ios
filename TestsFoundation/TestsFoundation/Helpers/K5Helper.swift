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
    public static var homeroom: XCUIElement { app.find(label: "Homeroom") }
    public static var schedule: XCUIElement { app.find(label: "Schedule") }
    public static var grades: XCUIElement { app.find(label: "Grades") }
    public static var resources: XCUIElement { app.find(label: "Resources") }
    public static var accountNotification: XCUIElement { app.find(id: "AccountNotification.2.toggleButton") }
    public static var accountNotificationString: XCUIElement {
        app.find(label: "FYI, Tap to view announcement", type: XCUIElement.ElementType.button)
    }

    public static var homeTab: XCUIElement { app.find(label: "Home") }
    public static var scheduleTab: XCUIElement { app.find(label: "Schedule") }
    public static var modulesTab: XCUIElement { app.find(label: "Modules") }
    public static var gradesTab: XCUIElement { app.find(label: "Grades") }
    public static var emptyPage: XCUIElement { app.find(label: "Your modules will appear here after they're assembled.") }
    public static var emptyPage2: XCUIElement { app.find(label: "This is where you'll land when your home is complete.") }

    public static func courseCard(id: String) -> XCUIElement {
        return app.find(id: "DashboardCourseCell.\(id)")
    }

    public static var gradingPeriodSelectorClosed: XCUIElement { app.find(label: "Select Grading Period, Closed") }
    public static var gradingPeriodSelectorOpen: XCUIElement { app.find(label: "Select Grading Period, Open") }
    public static var currentGradingPeriod: XCUIElement { app.find(label: "Current Grading Period") }
    public static var emptyGradesForCourse: XCUIElement { app.find(label: "You don't have any grades yet.") }

    public static func gradedPointsOutOf(actual: String, outOf: String) -> XCUIElement {
        return app.find(label: "Grade, \(actual) out of \(outOf)")
    }

    public static func gradedPointsMax(maxPoints: String) -> XCUIElement {
        return app.find(label: "Out of \(maxPoints) pts")
    }

    public static func gradedPointsActual(actualPoints: String) -> XCUIElement {
        return app.find(label: "\(actualPoints) pts")
    }

    public static var previousWeekButton: XCUIElement { app.find(label: "Previous Week", type: .button) }
    public static var nextWeekButton: XCUIElement { app.find(label: "Next Week", type: .button) }
    public static var todayHeader: XCUIElement { app.find(labelContaining: "Today", type: .staticText) }
    public static var todayButton: XCUIElement { app.find(label: "Today", type: .button) }
    public static var today: XCUIElement { app.find(id: "K5Schedule.today") }
}
