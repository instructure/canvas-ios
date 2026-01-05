//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import TestsFoundation
import XCTest

class TodoListTests: E2ETestCase {
    var student: DSUser!
    var course: DSCourse!
    var assignmentToday: DSAssignment!
    var assignmentTomorrow: DSAssignment!
    var assignmentNextWeek: DSAssignment!
    var assignmentPastDue: DSAssignment!
    var quiz: DSQuiz!
    var calendarEvent: DSCalendarEvent!

    func testTodoListAndFilterFlow() {
        seedTestData()
        navigateToTodoTab()
        verifyDefaultFilterState()
        verifyDefaultTodoList()
        applyFilters()
        verifyFilteredTodoList()
        verifyCreateTodoViaCalendar()
        verifyTabBarBadgeCount(expectedCount: 6)
        markTodoAsDone()
        verifyShowCompletedFilter()
        verifyMarkTodoAsUndone()
        verifyFilterPersistence()
    }

    private func seedTestData() {
        XCTContext.runActivity(named: "Seed test data") { _ in
            student = seeder.createUser()
            course = seeder.createCourse()
            seeder.enrollStudent(student, in: course)

            assignmentToday = AssignmentsHelper.createAssignment(
                course: course,
                name: "Assignment Due Today",
                dueDate: Date.now
            )

            assignmentTomorrow = AssignmentsHelper.createAssignment(
                course: course,
                name: "Assignment Due Tomorrow",
                dueDate: Date.now.addDays(1)
            )

            assignmentNextWeek = AssignmentsHelper.createAssignment(
                course: course,
                name: "Assignment Due Next Week",
                dueDate: Date.now.addDays(7)
            )

            assignmentPastDue = AssignmentsHelper.createAssignment(
                course: course,
                name: "Past Due Assignment",
                dueDate: Date.now.addDays(-2)
            )

            quiz = QuizzesHelper.createTestQuizWith2Questions(
                course: course,
                due_at: Date.now.addDays(1)
            )

            calendarEvent = CalendarHelper.createCalendarEvent(
                course: course,
                title: "Calendar Event Tomorrow",
                description: "Course calendar event",
                startDate: Date.now.addDays(1),
                endDate: Date.now.addDays(1).addHours(1)
            )

            logInDSUser(student)
        }
    }

    private func navigateToTodoTab() {
        XCTContext.runActivity(named: "Navigate to Todo tab") { _ in
            let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
            XCTAssertVisible(profileButton)

            let todoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
            XCTAssertVisible(todoTab)
            todoTab.hit()

            let filterButton = ToDoHelper.filterButton.waitUntil(.visible)
            XCTAssertVisible(filterButton)
        }
    }

    private func verifyDefaultFilterState() {
        XCTContext.runActivity(named: "Verify default filter state") { _ in
            openFilterScreen()

            let showPersonalTodosSwitch = ToDoHelper.Filter.showPersonalTodosSwitch.waitUntil(.visible)
            XCTAssertVisible(showPersonalTodosSwitch)
            XCTAssertNotSelected(showPersonalTodosSwitch)

            let showCalendarEventsSwitch = ToDoHelper.Filter.showCalendarEventsSwitch.waitUntil(.visible)
            XCTAssertVisible(showCalendarEventsSwitch)
            XCTAssertNotSelected(showCalendarEventsSwitch)

            let showCompletedSwitch = ToDoHelper.Filter.showCompletedSwitch.waitUntil(.visible)
            XCTAssertVisible(showCompletedSwitch)
            XCTAssertNotSelected(showCompletedSwitch)

            let favouriteCoursesOnlySwitch = ToDoHelper.Filter.favouriteCoursesOnlySwitch.waitUntil(.visible)
            XCTAssertVisible(favouriteCoursesOnlySwitch)
            XCTAssertNotSelected(favouriteCoursesOnlySwitch)

            let startFourWeeksAgoOption = ToDoHelper.Filter.startFourWeeksAgoOption.waitUntil(.visible)
            XCTAssertVisible(startFourWeeksAgoOption)
            XCTAssertSelected(startFourWeeksAgoOption)

            let endThisWeekOption = ToDoHelper.Filter.endThisWeekOption.waitUntil(.visible)
            XCTAssertVisible(endThisWeekOption)
            XCTAssertSelected(endThisWeekOption)

            closeFilterScreen()
        }
    }

    private func verifyDefaultTodoList() {
        XCTContext.runActivity(named: "Verify todo list with default filters") { _ in
            let todayCell = ToDoHelper.cell(id: assignmentToday.id).waitUntil(.visible)
            XCTAssertVisible(todayCell)

            let tomorrowCell = ToDoHelper.cell(id: assignmentTomorrow.id).waitUntil(.visible)
            XCTAssertVisible(tomorrowCell)

            let nextWeekCell = ToDoHelper.cell(id: assignmentNextWeek.id).waitUntil(.vanish)
            XCTAssertNotVisible(nextWeekCell)

            let pastDueCell = ToDoHelper.cell(id: assignmentPastDue.id).waitUntil(.visible)
            XCTAssertVisible(pastDueCell)

            let quizCell = ToDoHelper.cell(id: quiz.id).waitUntil(.visible)
            XCTAssertVisible(quizCell)

            let calendarEventCell = ToDoHelper.cell(id: calendarEvent.id).waitUntil(.vanish)
            XCTAssertNotVisible(calendarEventCell)
        }
    }

    private func applyFilters() {
        XCTContext.runActivity(named: "Apply filters to show all item types") { _ in
            openFilterScreen()

            let showPersonalTodosSwitch = ToDoHelper.Filter.showPersonalTodosSwitch.waitUntil(.visible)
            showPersonalTodosSwitch.hit()
            showPersonalTodosSwitch.waitUntil(.selected)
            XCTAssertSelected(showPersonalTodosSwitch)

            let showCalendarEventsSwitch = ToDoHelper.Filter.showCalendarEventsSwitch.waitUntil(.visible)
            showCalendarEventsSwitch.hit()
            showCalendarEventsSwitch.waitUntil(.selected)
            XCTAssertSelected(showCalendarEventsSwitch)

            let todayStartOption = ToDoHelper.Filter.startTodayOption.waitUntil(.visible)
            todayStartOption.hit()
            todayStartOption.waitUntil(.selected)
            XCTAssertSelected(todayStartOption)

            todayStartOption.swipeUp()

            let nextWeekEndOption = ToDoHelper.Filter.endNextWeekOption.waitUntil(.visible)
            nextWeekEndOption.hit()
            nextWeekEndOption.waitUntil(.selected)
            XCTAssertSelected(nextWeekEndOption)

            closeFilterScreen()
        }
    }

    private func verifyFilteredTodoList() {
        XCTContext.runActivity(named: "Verify filtered todo list with all item types") { _ in
            let todayCell = ToDoHelper.cell(id: assignmentToday.id).waitUntil(.visible)
            XCTAssertVisible(todayCell)

            let tomorrowCell = ToDoHelper.cell(id: assignmentTomorrow.id).waitUntil(.visible)
            XCTAssertVisible(tomorrowCell)

            let quizCell = ToDoHelper.cell(id: quiz.id).waitUntil(.visible)
            XCTAssertVisible(quizCell)

            let nextWeekCell = ToDoHelper.cell(id: assignmentNextWeek.id).waitUntil(.visible)
            XCTAssertVisible(nextWeekCell)

            let calendarEventCell = ToDoHelper.cell(id: calendarEvent.id).waitUntil(.visible)
            XCTAssertVisible(calendarEventCell)

            let pastDueCell = ToDoHelper.cell(id: assignmentPastDue.id).waitUntil(.vanish)
            XCTAssertNotVisible(pastDueCell)
        }
    }

    private func verifyCreateTodoViaCalendar() {
        XCTContext.runActivity(named: "Verify creating todo via calendar updates todo tab") { _ in
            let calendarTab = CalendarHelper.TabBar.calendarTab.waitUntil(.visible)
            XCTAssertVisible(calendarTab)
            calendarTab.hit()

            CalendarHelper.navigateToAddToDoScreen()

            let titleInput = CalendarHelper.EditToDo.titleInput.waitUntil(.visible)
            XCTAssertVisible(titleInput)
            titleInput.writeText(text: "Personal Calendar Todo")

            let addButton = CalendarHelper.EditToDo.addButton.waitUntil(.visible)
            XCTAssertVisible(addButton)
            addButton.hit()

            let todoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
            XCTAssertVisible(todoTab)
            todoTab.hit()

            let filterButton = ToDoHelper.filterButton.waitUntil(.visible)
            XCTAssertVisible(filterButton)

            let tabBadgeValue = todoTab.value as? String
            XCTAssertEqual(tabBadgeValue, "6 items", "Tab bar badge should show 6 items after adding calendar todo")
        }
    }

    private func verifyTabBarBadgeCount(expectedCount: Int) {
        XCTContext.runActivity(named: "Verify badge count matches todo list item count") { _ in
            let todoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
            XCTAssertVisible(todoTab)

            let tabBadgeValue = todoTab.value as? String
            let expectedTabSuffix = expectedCount == 1 ? "item" : "items"
            XCTAssertEqual(tabBadgeValue, "\(expectedCount) \(expectedTabSuffix)", "Tab bar badge should show \(expectedCount) \(expectedTabSuffix)")
        }
    }

    private func markTodoAsDone() {
        XCTContext.runActivity(named: "Mark todo as done via checkbox") { _ in
            let todayCheckbox = ToDoHelper.checkbox(id: assignmentToday.id).waitUntil(.visible)
            XCTAssertVisible(todayCheckbox)
            todayCheckbox.hit()

            let todayCell = ToDoHelper.cell(id: assignmentToday.id).waitUntil(.vanish, timeout: 5)
            XCTAssertNotVisible(todayCell)

            let todoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
            XCTAssertVisible(todoTab)

            let tabBadgeValue = todoTab.value as? String
            XCTAssertEqual(tabBadgeValue, "5 items", "Tab bar badge should show 5 items after marking one as done")
        }
    }

    private func verifyShowCompletedFilter() {
        XCTContext.runActivity(named: "Verify Show Completed filter hides completed items by default") { _ in
            let todayCell = ToDoHelper.cell(id: assignmentToday.id).waitUntil(.vanish, timeout: 5)
            XCTAssertNotVisible(todayCell)

            openFilterScreen()

            let showCompletedSwitch = ToDoHelper.Filter.showCompletedSwitch.waitUntil(.visible)
            XCTAssertVisible(showCompletedSwitch)
            XCTAssertNotSelected(showCompletedSwitch)
            showCompletedSwitch.hit()

            showCompletedSwitch.waitUntil(.selected)
            XCTAssertSelected(showCompletedSwitch)

            closeFilterScreen()

            let completedCell = ToDoHelper.cell(id: assignmentToday.id).waitUntil(.visible)
            XCTAssertVisible(completedCell)
        }
    }

    private func verifyMarkTodoAsUndone() {
        XCTContext.runActivity(named: "Verify marking todo as undone via checkbox") { _ in
            let todayCell = ToDoHelper.cell(id: assignmentToday.id).waitUntil(.visible)
            XCTAssertVisible(todayCell)

            let checkbox = ToDoHelper.checkbox(id: assignmentToday.id).waitUntil(.visible)
            XCTAssertVisible(checkbox)
            checkbox.hit()

            XCTAssertVisible(todayCell)

            let todoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
            XCTAssertVisible(todoTab)

            let tabBadgeValue = todoTab.value as? String
            XCTAssertEqual(tabBadgeValue, "6 items", "Tab bar badge should show 6 items after marking todo as undone")
        }
    }

    private func verifyFilterPersistence() {
        XCTContext.runActivity(named: "Verify filter persistence after navigation") { _ in
            let dashboardTab = ToDoHelper.TabBar.dashboardTab.waitUntil(.visible)
            XCTAssertVisible(dashboardTab)
            dashboardTab.hit()

            let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
            XCTAssertVisible(profileButton)

            let todoTab = ToDoHelper.TabBar.todoTab.waitUntil(.visible)
            XCTAssertVisible(todoTab)
            todoTab.hit()

            openFilterScreen()

            let showPersonalTodosSwitch = ToDoHelper.Filter.showPersonalTodosSwitch.waitUntil(.visible)
            XCTAssertVisible(showPersonalTodosSwitch)
            XCTAssertSelected(showPersonalTodosSwitch)

            let showCalendarEventsSwitch = ToDoHelper.Filter.showCalendarEventsSwitch.waitUntil(.visible)
            XCTAssertVisible(showCalendarEventsSwitch)
            XCTAssertSelected(showCalendarEventsSwitch)

            let showCompletedSwitch = ToDoHelper.Filter.showCompletedSwitch.waitUntil(.visible)
            XCTAssertVisible(showCompletedSwitch)
            XCTAssertSelected(showCompletedSwitch)

            let favouriteCoursesOnlySwitch = ToDoHelper.Filter.favouriteCoursesOnlySwitch.waitUntil(.visible)
            XCTAssertVisible(favouriteCoursesOnlySwitch)
            XCTAssertNotSelected(favouriteCoursesOnlySwitch)

            let todayStartOption = ToDoHelper.Filter.startTodayOption.waitUntil(.visible)
            XCTAssertVisible(todayStartOption)
            XCTAssertSelected(todayStartOption)

            todayStartOption.swipeUp()

            let nextWeekEndOption = ToDoHelper.Filter.endNextWeekOption.waitUntil(.visible)
            XCTAssertVisible(nextWeekEndOption)
            XCTAssertSelected(nextWeekEndOption)

            closeFilterScreen()
        }
    }

    // MARK: - Helper Methods

    private func openFilterScreen() {
        XCTContext.runActivity(named: "Open filter screen") { _ in
            let filterButton = ToDoHelper.filterButton.waitUntil(.visible)
            XCTAssertVisible(filterButton)
            filterButton.hit()

            let filterNavBar = ToDoHelper.Filter.navBar.waitUntil(.visible)
            XCTAssertVisible(filterNavBar)
        }
    }

    private func closeFilterScreen() {
        XCTContext.runActivity(named: "Close filter screen") { _ in
            let doneButton = ToDoHelper.Filter.doneButton.waitUntil(.visible)
            XCTAssertVisible(doneButton)
            doneButton.hit()

            let filterNavBar = ToDoHelper.Filter.navBar.waitUntil(.vanish)
            XCTAssertTrue(filterNavBar.isVanished)
        }
    }
}
