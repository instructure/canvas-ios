//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public class LearnerDashboardHelper: BaseHelper {
    public static var bottomSettingsButton: XCUIElement { app.find(id: "Dashboard.bottomSettingsButton", type: .button) }

    public struct Settings {
        public static var doneButton: XCUIElement { app.find(id: "DashboardSettings.doneButton", type: .button) }
        public static var newDashboardToggle: XCUIElement { app.find(id: "DashboardSettings.newDashboardToggle") }
        public static var feedbackButton: XCUIElement { app.find(id: "Dashboard.Settings.feedbackButton") }
        public static var showGradesToggle: XCUIElement { app.find(id: "Dashboard.Settings.showGradesToggle") }

        public enum WidgetID: String {
            case helloWidget
            case coursesAndGroups
            case weeklySummary
            case todo
        }

        public static func widgetToggle(id: WidgetID) -> XCUIElement {
            app.find(id: "Dashboard.Settings.widgetToggle.\(id.rawValue)")
        }
    }

    public struct CoursesWidget {
        public static var coursesHeader: XCUIElement { app.find(id: "Dashboard.Courses.coursesHeader") }
        public static var groupsHeader: XCUIElement { app.find(id: "Dashboard.Courses.groupsHeader") }
        public static var allCoursesButton: XCUIElement { app.find(id: "Dashboard.Courses.allCoursesButton") }
        public static var courseCardGradePill: XCUIElement { app.find(id: "Dashboard.Courses.CourseCard.gradePill") }
        public static var courseCardCustomizeButton: XCUIElement { app.find(id: "Dashboard.Courses.CourseCard.customizeButton") }
        public static var courseCardAnnouncementsButton: XCUIElement { app.find(id: "Dashboard.Courses.CourseCard.announcementsButton") }

        public static func courseCard(courseID: String) -> XCUIElement {
            app.find(id: "Dashboard.Courses.CourseCard.cardButton.\(courseID)")
        }
    }

    public struct AnnouncementsWidget {
        public static var cardButton: XCUIElement { app.find(id: "Dashboard.Announcements.GlobalAnnouncement.cardButton") }
        public static var detailsDismissButton: XCUIElement { app.find(id: "Dashboard.Announcements.GlobalAnnouncementDetails.dismissButton") }

        public static func announcementCard(announcement: DSAccountNotification) -> XCUIElement {
            app.find(id: "Dashboard.Announcements.GlobalAnnouncement.Id.\(announcement.id)")
        }
    }

    public struct WeeklySummaryWidget {
        public static var currentWeekButton: XCUIElement { app.find(id: "Dashboard.Forecast.currentWeekButton") }
        public static var prevWeekButton: XCUIElement { app.find(id: "Dashboard.Forecast.prevWeekButton") }
        public static var nextWeekButton: XCUIElement { app.find(id: "Dashboard.Forecast.nextWeekButton") }
        public static var dueButton: XCUIElement { app.find(id: "Dashboard.Forecast.CategorySelector.dueButton") }
        public static var missingButton: XCUIElement { app.find(id: "Dashboard.Forecast.CategorySelector.missingButton") }
        public static var newGradesButton: XCUIElement { app.find(id: "Dashboard.Forecast.CategorySelector.newGradesButton") }
        public static var itemCellButton: XCUIElement { app.find(id: "Dashboard.Forecast.Item.cellButton") }
    }

    public struct ToDoWidget {
        public static var todayButton: XCUIElement { app.find(id: "Dashboard.Todo.todayButton") }
        public static var showCompletedToggle: XCUIElement { app.find(id: "Dashboard.Todo.showCompletedToggle") }
        public static var addTodoButton: XCUIElement { app.find(id: "Dashboard.Todo.TodoList.addTodoButton") }
        public static var todoItem: XCUIElement { app.find(id: "Dashboard.Todo.TodoList.Item") }
    }

    public struct InvitationsWidget {
        public static var acceptButton: XCUIElement { app.find(id: "Dashboard.Invitations.CourseInvitation.acceptButton") }
        public static var declineButton: XCUIElement { app.find(id: "Dashboard.Invitations.CourseInvitation.declineButton") }

        public static func invitationCard(enrollmentId: String) -> XCUIElement {
            app.find(id: "Dashboard.Invitations.CourseInvitation.Id.\(enrollmentId)")
        }
    }
}
