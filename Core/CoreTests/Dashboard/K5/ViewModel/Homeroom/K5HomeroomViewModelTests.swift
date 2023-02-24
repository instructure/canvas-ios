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

import SwiftUI
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

    func testRefreshesWelcomeText() async {
        mockUserProfile(name: "testName")
        let testee = K5HomeroomViewModel()

        mockUserProfile(name: "new testName")
        await testee.refresh()

        XCTAssertEqual(testee.welcomeText, "Welcome, new testName!")
    }

    // MARK: - Announcement Tests

    func testLoadsHomeroomAnnouncements() {
        mockAnnouncements(homeroomTitle: "title 2")
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
        mockAnnouncements(homeroomTitle: "original title")
        mockDashboardCards()
        let testee = K5HomeroomViewModel()
        let refrehCompleted = expectation(description: "Refresh completed")
        refrehCompleted.assertForOverFulfill = true

        mockAnnouncements(homeroomTitle: "updated title")
        testee.refresh {
            refrehCompleted.fulfill()
        }

        wait(for: [refrehCompleted], timeout: 1)
        XCTAssertEqual(testee.announcements.count, 1)
        guard let announcement = testee.announcements.first else { return }
        XCTAssertEqual(announcement.htmlContent, "message 2")
    }

    // MARK: - Account Announcement Tests

    func testLoadsAccountAnnouncements() {
        api.mock(GetAccountNotificationsRequest(), value: [.make()])

        let testee = K5HomeroomViewModel()

        XCTAssertEqual(testee.accountAnnouncements.count, 1)
        XCTAssertEqual(testee.accountAnnouncements.first?.message, "The financial aid office is closed on Tuesdays.")
    }

    // MARK: - Subject Card Tests

    func testLoadsNonHomeroomCourses() {
        mockCourses()
        mockDashboardCards()
        mockAnnouncements(nonHomeroomTitle: "Non homeroom announcement")
        mockDueItems()
        mockMissingSubmissions()

        let testee = K5HomeroomViewModel()

        XCTAssertEqual(testee.subjectCards.count, 1)
        guard let card = testee.subjectCards.first else { return }
        XCTAssertEqual(card.name, "COURSE 1")
        XCTAssertEqual(card.courseRoute, "/courses/1")
        XCTAssertEqual(card.imageURL, URL(string: "https://instructure.com"))
        XCTAssertEqual(card.color, Color(hexString: "#DEAD00"))

        guard card.infoLines.count == 2 else { XCTFail("Info line count mismatch"); return }
        XCTAssertEqual(card.infoLines[0], K5HomeroomSubjectCardViewModel.InfoLine(icon: .k5dueToday, route: "/courses/1#schedule", text: "1 due today | ", highlightedText: "2 missing"))
        XCTAssertEqual(card.infoLines[1], K5HomeroomSubjectCardViewModel.InfoLine(icon: .announcementLine, route: "/courses/1", text: "Non homeroom announcement"))
    }

    // MARK: - Private Helpers

    private func mockCourses() {
        let course = APICourse.make(id: "1",
                                    name: "Homeroom",
                                    course_code: "course_1",
                                    enrollments: [
                                        .make(
                                            id: "1",
                                            course_id: "1",
                                            user_id: "1"
                                        ),
                                    ],
                                    homeroom_course: false
        )
        let getCourses = GetCourses()
        getCourses.write(response: [course], urlResponse: nil, to: databaseClient)
    }

    private func mockUserProfile(name: String) {
        let mockRequest = GetUserProfileRequest(userID: "self")
        let mockResponse = APIProfile.make(name: name)
        api.mock(mockRequest, value: mockResponse)
    }

    private func mockAnnouncements(homeroomTitle: String = "", nonHomeroomTitle: String = "") {
        let mockRequest = GetAllAnnouncementsRequest(contextCodes: ["course_2", "course_1"], activeOnly: true, latestOnly: true)
        let mockResponse = [
            APIDiscussionTopic.make(context_code: "course_1", message: "message 1", posted_at: Date(timeIntervalSince1970: 74874), title: nonHomeroomTitle),
            APIDiscussionTopic.make(context_code: "course_2", message: "message 2", posted_at: Date(timeIntervalSince1970: 74874), title: homeroomTitle),
        ]
        api.mock(mockRequest, value: mockResponse)
    }

    private func mockDashboardCards() {
        let mockRequest = GetDashboardCardsRequest()
        let mockResponse = [
            APIDashboardCard.make(color: "#DEAD00", id: "1", image: "https://instructure.com", isHomeroom: false),
            APIDashboardCard.make(id: "2", isHomeroom: true, shortName: "course2 name"),
        ]
        api.mock(mockRequest, value: mockResponse)
    }

    private func mockDueItems() {
        let mockRequest = GetK5HomeroomDueItemCount(courseIds: ["1"])
        let mockResponse = [
            APIPlannable.make(course_id: "1", submissions: APIPlannable.Submissions.make(submitted: false)),
        ]
        api.mock(mockRequest, value: mockResponse)
    }

    private func mockMissingSubmissions() {
        let mockRequest = GetK5HomeroomMissingSubmissionsCount(courseIds: ["1"])
        let mockResponse = [
            APIAssignment.make(course_id: "1", id: "1", planner_override: .make(dismissed: false)),
            APIAssignment.make(course_id: "1", id: "2", planner_override: .make(dismissed: true)),
            APIAssignment.make(course_id: "1", id: "3", planner_override: nil),
        ]
        api.mock(mockRequest, value: mockResponse)
    }
}
