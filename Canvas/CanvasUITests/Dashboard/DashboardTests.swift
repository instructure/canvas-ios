//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum Dashboard {
    static var coursesLabel: Element {
        return app.find(labelContaining: "Courses")
    }

    static func courseCard(id: String) -> Element {
        return app.find(id: "course-\(id)")
    }

    static func courseGrade(percent: String) -> Element {
        return app.find(labelContaining: "\(percent)%")
    }

    static var dashboardTab: Element {
        return app.find(label: "Dashboard")
    }

    static var calendarTab: Element {
        return app.find(label: "Calendar")
    }

    static var dashboardList: Element {
        return app.find(id: "favorited-course-list.profile-btn")
    }

    static func username(_ username: String) -> Element {
        return XCUIElementWrapper(app.staticTexts[username])
    }

    static var showGrades: Element {
        return app.find(label: "Show Grades")
    }

    static var changeUser: Element {
        return app.find(label: "Change User")
    }

    static var logOut: Element {
        return app.find(label: "Log Out")
    }
}

enum CourseDetails {
    static var grades: Element {
        return app.find(id: "courses-details.grades-cell")
    }

    static var announcements: Element {
        return app.find(id: "courses-details.announcements-cell")
    }

    static var people: Element {
        return app.find(id: "courses-details.people-cell")
    }

    static var files: Element {
        return app.find(id: "courses-details.files-cell")
    }
}

class DashboardTests: CanvasUITests {
    override var user: User? { return .student1 }

    func testAnnouncementBelowInvite() {
        CourseInvitation.acceptButton(id: "998").waitToExist()
        GlobalAnnouncement.toggle(id: "2").waitToExist()
        XCTAssertLessThan(CourseInvitation.acceptButton(id: "998").frame.maxY, GlobalAnnouncement.toggle(id: "2").frame.minY)
    }

    func testAnnouncementToggle() {
        let label = "This is a global announcement for students."
        GlobalAnnouncement.toggle(id: "2").waitToExist()
        XCTAssertFalse(GlobalAnnouncement.dismiss(id: "2").isVisible)
        XCTAssertFalse(app.find(label: label).isVisible)

        GlobalAnnouncement.toggle(id: "2").tap()
        GlobalAnnouncement.dismiss(id: "2").waitToExist()
        app.find(label: label).waitToExist()

        GlobalAnnouncement.toggle(id: "2").tap()
        GlobalAnnouncement.dismiss(id: "2").waitToVanish()
    }

    func testNavigationDrawerDisplaysUsername() {
        Dashboard.dashboardList.waitToExist()
        Dashboard.dashboardList.tap()
        Dashboard.username("Student One").waitToExist()
    }

    func testNavigationDrawerChangesUser() {
        Dashboard.dashboardList.waitToExist()
        Dashboard.dashboardList.tap()
        Dashboard.changeUser.tap()
        LoginStart.previousUser(name: "Student One").waitToExist()
    }

    func testNavigationDrawerLogsOut() {
        Dashboard.dashboardList.waitToExist()
        Dashboard.dashboardList.tap()
        Dashboard.logOut.tap()
        LoginStart.findMySchool.waitToExist()
        XCTAssertFalse(LoginStart.previousUser(name: "Student One").exists)
    }

}
