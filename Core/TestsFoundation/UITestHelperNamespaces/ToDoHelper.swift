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

import XCTest

public class ToDoHelper: BaseHelper {
    public static var navBar: XCUIElement { app.find(type: .navigationBar) }
    public static var toDoBackButton: XCUIElement { navBar.find(label: "To-do", type: .button) }

    public static func cell(id: String) -> XCUIElement {
        return app.find(id: "to-do.list.\(id).row", type: .button)
    }

    public static func cellItemTitle(cell itemCell: XCUIElement) -> XCUIElement {
        return itemCell.find(type: .staticText)
    }

    public static var filterButton: XCUIElement { app.find(id: "ToDos.filterButton", type: .button) }

    public enum TabBar {
        public static var dashboardTab: XCUIElement { app.find(id: "TabBar.dashboardTab", type: .button) }
        public static var todoTab: XCUIElement { app.find(id: "TabBar.todoTab", type: .button) }
        public static var calendarTab: XCUIElement { app.find(id: "TabBar.calendarTab", type: .button) }
    }

    public static func checkbox(id: String) -> XCUIElement {
        return app.find(id: "to-do.list.\(id).checkbox", type: .image)
    }

    public enum Filter {
        public static var navBar: XCUIElement { app.find(id: "To-do List Preferences") }
        public static var cancelButton: XCUIElement { navBar.find(label: "Cancel", type: .button) }
        public static var doneButton: XCUIElement { navBar.find(label: "Done", type: .button) }

        public static var showPersonalTodosSwitch: XCUIElement { app.find(id: "showPersonalTodos") }
        public static var showCalendarEventsSwitch: XCUIElement { app.find(id: "showCalendarEvents") }
        public static var showCompletedSwitch: XCUIElement { app.find(id: "showCompleted") }
        public static var favouriteCoursesOnlySwitch: XCUIElement { app.find(id: "favouriteCoursesOnly") }

        public static var startTodayOption: XCUIElement { app.find(id: "start-today") }
        public static var startThisWeekOption: XCUIElement { app.find(id: "start-thisWeek") }
        public static var startLastWeekOption: XCUIElement { app.find(id: "start-lastWeek") }
        public static var startTwoWeeksAgoOption: XCUIElement { app.find(id: "start-twoWeeksAgo") }
        public static var startThreeWeeksAgoOption: XCUIElement { app.find(id: "start-threeWeeksAgo") }
        public static var startFourWeeksAgoOption: XCUIElement { app.find(id: "start-fourWeeksAgo") }

        public static var endTodayOption: XCUIElement { app.find(id: "end-today") }
        public static var endThisWeekOption: XCUIElement { app.find(id: "end-thisWeek") }
        public static var endNextWeekOption: XCUIElement { app.find(id: "end-nextWeek") }
        public static var endInTwoWeeksOption: XCUIElement { app.find(id: "end-inTwoWeeks") }
        public static var endInThreeWeeksOption: XCUIElement { app.find(id: "end-inThreeWeeks") }
        public static var endInFourWeeksOption: XCUIElement { app.find(id: "end-inFourWeeks") }
    }
}
