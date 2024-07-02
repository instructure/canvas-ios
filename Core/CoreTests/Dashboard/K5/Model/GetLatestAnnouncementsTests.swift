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

class GetLatestAnnouncementsTests: CoreTestCase {

    func testFetchFromAPIAndSortedResults() {
        let mockRequest = GetAllAnnouncementsRequest(contextCodes: ["course_2", "course_3", "course_1"], activeOnly: true, latestOnly: true)
        let mockResponse = [
            APIDiscussionTopic.make(context_code: "course_3", message: "message 3", posted_at: Date(timeIntervalSince1970: 74874), title: "title 3"),
            APIDiscussionTopic.make(context_code: "course_1", message: "message 1", posted_at: Date(timeIntervalSince1970: 84874), title: "title 1")
        ]
        api.mock(mockRequest, value: mockResponse)
        XCTAssertEqual(databaseClient.registeredObjects.count, 0)

        let refreshedExpectation = expectation(description: "Announcement fetch finished")
        let testee = environment.subscribe(GetLatestAnnouncements(courseIds: ["2", "3", "1"]))
        testee.refresh(force: false) { [weak testee] _ in
            if testee?.state == .data {
                refreshedExpectation.fulfill()
            }
        }

        wait(for: [refreshedExpectation], timeout: 1)
        XCTAssertEqual(testee.count, 2)
        XCTAssertEqual(testee[0]?.contextCode, "course_1")
        XCTAssertEqual(testee[0]?.message, "message 1")
        XCTAssertEqual(testee[0]?.postedAt, Date(timeIntervalSince1970: 84874))
        XCTAssertEqual(testee[0]?.title, "title 1")
        XCTAssertEqual(testee[1]?.contextCode, "course_3")
        XCTAssertEqual(testee[1]?.message, "message 3")
        XCTAssertEqual(testee[1]?.postedAt, Date(timeIntervalSince1970: 74874))
        XCTAssertEqual(testee[1]?.title, "title 3")
    }

    func testCacheKeyIncludesSortedCourseContextIds() {
        let testee = GetLatestAnnouncements(courseIds: ["2", "3", "1"])
        XCTAssertEqual(testee.cacheKey, "announcements(course_1,course_2,course_3)")
    }
}
