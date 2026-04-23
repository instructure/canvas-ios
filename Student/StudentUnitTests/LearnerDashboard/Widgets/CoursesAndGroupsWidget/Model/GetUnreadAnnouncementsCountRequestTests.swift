//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Student

final class GetUnreadAnnouncementsCountRequestTests: XCTestCase {

    // MARK: - unreadAnnouncementCount

    func test_unreadAnnouncementCount() {
        // WHEN no nodes
        var testee = GetUnreadAnnouncementsCountResponse.CourseData.make(nodes: [])
        // THEN
        XCTAssertEqual(testee.unreadAnnouncementCount, 0)

        // WHEN all nodes are read
        testee = .make(nodes: [
            .make(id: "a1", read: true),
            .make(id: "a2", read: true)
        ])
        // THEN
        XCTAssertEqual(testee.unreadAnnouncementCount, 0)

        // WHEN mixed read and unread nodes
        testee = .make(nodes: [
            .make(id: "a1", read: false),
            .make(id: "a2", read: true),
            .make(id: "a3", read: false)
        ])
        // THEN
        XCTAssertEqual(testee.unreadAnnouncementCount, 2)
    }

    func test_unreadAnnouncementCount_whenParticipantIsNil_shouldCountAsRead() {
        let testee = GetUnreadAnnouncementsCountResponse.CourseData.make(nodes: [
            GetUnreadAnnouncementsCountResponse.DiscussionNode(_id: "a1", participant: nil)
        ])

        XCTAssertEqual(testee.unreadAnnouncementCount, 0)
    }
}
