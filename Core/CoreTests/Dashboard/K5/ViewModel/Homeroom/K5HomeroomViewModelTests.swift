//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
@testable import Core

class K5HomeroomViewModelTests: CoreTestCase {

    // MARK: - Welcome Text Tests

    func testIncludesProfileNameInWelcomeText() {
        mockUserProfile(name: "testName")

        let testee = K5HomeroomViewModel()

        XCTAssertEqual(testee.welcomeText, "Welcome, testName!")
    }

    func testDefaultWelcomeText() {
        let testee = K5HomeroomViewModel()

        XCTAssertEqual(testee.welcomeText, "Welcome!")
    }

    func testRefreshesWelcomeText() {
        mockUserProfile(name: "testName")
        let testee = K5HomeroomViewModel()

        mockUserProfile(name: "new testName")
        testee.refresh()

        XCTAssertEqual(testee.welcomeText, "Welcome, new testName!")
    }

    // MARK: - Announcement Tests

    func testLoadsHomeroomAnnouncements() {
        mockAnnouncements(message: "message 2")
        mockDashboardCards()

        let testee = K5HomeroomViewModel()

        XCTAssertEqual(testee.announcements.count, 1)
        guard let announcement = testee.announcements.first else { return }
        XCTAssertEqual(announcement.courseName, "course2 name")
        XCTAssertEqual(announcement.title, "title 2")
        XCTAssertEqual(announcement.htmlContent, "message 2")
        XCTAssertEqual(announcement.allAnnouncementsRoute, "/courses/2/announcements")
    }

    func testRefreshesAnnouncements() {
        mockAnnouncements(message: "original message")
        mockDashboardCards()
        let testee = K5HomeroomViewModel()
        let refrehCompleted = expectation(description: "Refresh completed")
        refrehCompleted.assertForOverFulfill = true

        mockAnnouncements(message: "updated message")
        testee.refresh {
            refrehCompleted.fulfill()
        }

        wait(for: [refrehCompleted], timeout: 1)
        XCTAssertEqual(testee.announcements.count, 1)
        guard let announcement = testee.announcements.first else { return }
        XCTAssertEqual(announcement.htmlContent, "updated message")
    }

    // MARK: - Private Helpers

    private func mockUserProfile(name: String) {
        let mockRequest = GetUserProfileRequest(userID: "self")
        let mockResponse = APIProfile.make(name: name)
        api.mock(mockRequest, value: mockResponse)
    }

    private func mockAnnouncements(message: String) {
        let mockRequest = GetAllAnnouncementsRequest(contextCodes: ["course_2", "course_1"], activeOnly: true, latestOnly: true)
        let mockResponse = [
            APIDiscussionTopic.make(context_code: "course_2", message: message, posted_at: Date(timeIntervalSince1970: 74874), title: "title 2"),
        ]
        api.mock(mockRequest, value: mockResponse)
    }

    private func mockDashboardCards() {
        let mockRequest = GetDashboardCardsRequest()
        let mockResponse = [
            APIDashboardCard.make(id: "1", isHomeroom: false),
            APIDashboardCard.make(id: "2", isHomeroom: true, shortName: "course2 name"),
        ]
        api.mock(mockRequest, value: mockResponse)

    }
}
