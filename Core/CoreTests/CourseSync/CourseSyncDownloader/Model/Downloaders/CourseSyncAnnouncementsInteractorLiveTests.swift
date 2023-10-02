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

@testable import Core
import Combine
import TestsFoundation
import XCTest

class CourseSyncAnnouncementsInteractorLiveTests: CoreTestCase {

    override class func tearDown() {
        OfflineModeAssembly.reset()
        super.tearDown()
    }

    func testAssociatedTab() {
        XCTAssertEqual(CourseSyncAnnouncementsInteractorLive().associatedTabType, .announcements)
    }

    func testSavedDataPopulatesViewController() {
        // MARK: - GIVEN
        setupMocks()
        XCTAssertFinish(CourseSyncAnnouncementsInteractorLive().getContent(courseId: "testCourse"))
        API.resetMocks()

        // MARK: - WHEN
        OfflineModeAssembly.mock(AlwaysOfflineModeInteractor())
        let testee = AnnouncementListViewController.create(context: .course("testCourse"))
        testee.view.layoutIfNeeded()
        testee.viewWillAppear(false)

        // MARK: - THEN
        XCTAssertEqual((testee.navigationItem.titleView as? TitleSubtitleView)?.subtitle, "Course One")

        guard let announcementCell = testee.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnnouncementListCell else {
            return XCTFail()
        }
        XCTAssertEqual(announcementCell.dateLabel.text?.hasPrefix("Last post "), true)
        XCTAssertEqual(announcementCell.titleLabel.text, "my discussion topic")
    }

    func testFailuresReported() {
        let testee = CourseSyncAnnouncementsInteractorLive()

        setupMocks()
        api.mock(GetCustomColors(),
                 error: NSError.instructureError(""))
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))

        setupMocks()
        api.mock(GetCourse(courseID: "testCourse"),
                 error: NSError.instructureError(""))
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))

        setupMocks()
        api.mock(GetAnnouncements(context: .course("testCourse")),
                 error: NSError.instructureError(""))
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))

        setupMocks()
        api.mock(GetEnabledFeatureFlags(context: .course("testCourse")),
                 error: NSError.instructureError(""))
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    private func setupMocks() {
        api.mock(GetCustomColors(),
                 value: .init(custom_colors: [:]))
        api.mock(GetCourse(courseID: "testCourse"),
                 value: .make(id: "testCourse"))
        api.mock(GetAnnouncements(context: .course("testCourse")),
                 value: [
                    .make(html_url: URL(string: "/courses/testCourse")!,
                          last_reply_at: Date(timeIntervalSince1970: 0),
                          subscription_hold: "topic_is_announcement"),
                 ])
        api.mock(GetEnabledFeatureFlags(context: .course("testCourse")),
                 value: [])
    }
}
