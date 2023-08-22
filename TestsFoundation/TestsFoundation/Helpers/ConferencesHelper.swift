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

public class ConferencesHelper: BaseHelper {
    public static var navBar: XCUIElement { app.find(id: "Conferences", type: .navigationBar) }
    public static var emptyLabel: XCUIElement { app.find(id: "ConferenceList.emptyTitleLabel", type: .staticText) }
    public static var newConferencesHeader: XCUIElement { app.find(id: "ConferencesList.header-0", type: .staticText) }

    public static func cellTitle(conference: DSConference) -> XCUIElement {
        return app.find(id: "ConferencesList.cell-\(conference.id).title", type: .staticText)
    }

    public static func cellStatus(conference: DSConference) -> XCUIElement {
        return app.find(id: "ConferencesList.cell-\(conference.id).status", type: .staticText)
    }

    public static func cellDetails(conference: DSConference) -> XCUIElement {
        return app.find(id: "ConferencesList.cell-\(conference.id).details", type: .staticText)
    }

    public static func navigateToConferences(course: DSCourse) {
        DashboardHelper.courseCard(course: course).waitUntil(.visible).hit()
        CourseDetailsHelper.cell(type: .bigBlueButton).waitUntil(.visible).hit()
    }

    public struct Details {
        public static var title: XCUIElement { app.find(id: "ConferenceDetails.title", type: .staticText) }
        public static var status: XCUIElement { app.find(id: "ConferenceDetails.status", type: .staticText) }
        public static var details: XCUIElement { app.find(id: "ConferenceDetails.details", type: .staticText) }
    }

    // MARK: DataSeeding
    public static func createConference(
            course: DSCourse,
            title: String = "Sample Conference",
            duration: TimeInterval = 60,
            description: String = "This is a conference description",
            longRunning: Int = 1) -> DSConference {
        let webConference = CreateDSConferencesRequest.WebConference(
                title: title,
                duration: duration,
                description: description,
                long_running: longRunning)
        let body = CreateDSConferencesRequest.Body(web_conference: webConference)
        return seeder.createConference(course: course, body: body)
    }
}
