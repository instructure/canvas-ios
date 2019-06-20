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

class DashboardTests: CanvasUITests {
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

    func testCourseCardGrades() {
        Dashboard.profileButton.tap()
        Profile.showGradesToggle.waitToExist()
        if !Profile.showGradesToggle.isSelected {
            Profile.showGradesToggle.tap()
        }
        Profile.close()
        Dashboard.courseCard(id: "263").waitToExist()
        XCTAssertEqual(Dashboard.courseCard(id: "263").label, "Assignments 70%")

        Dashboard.profileButton.tap()
        Profile.showGradesToggle.tap()
        Profile.close()
        Dashboard.courseCard(id: "263").waitToExist()
        XCTAssertEqual(Dashboard.courseCard(id: "263").label.trimmingCharacters(in: .whitespacesAndNewlines), "Assignments")
    }
}
