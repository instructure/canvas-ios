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

class LatestAnnouncementTests: CoreTestCase {

    func testSaveDefaultValues() {
        let emptyAPIEntity = APIDiscussionTopic.make(context_code: nil, message: nil, posted_at: nil, title: nil)
        LatestAnnouncement.save(emptyAPIEntity, in: databaseClient)

        let savedEntities = databaseClient.registeredObjects.filter { $0 is LatestAnnouncement }
        guard savedEntities.count == 1 else {
            XCTFail("Multiple entities found")
            return
        }

        let testee = savedEntities.first! as! LatestAnnouncement
        XCTAssertEqual(testee.contextCode, "")
        XCTAssertEqual(testee.message, "")
        XCTAssertEqual(testee.title, "")
        XCTAssertEqual(testee.postedAt, Date.distantPast)
    }

    func testSave() {
        let apiAnnouncement = APIDiscussionTopic.make(context_code: "testContext", message: "testMessage", posted_at: Date(timeIntervalSince1970: 74874), title: "testTitle")
        LatestAnnouncement.save(apiAnnouncement, in: databaseClient)

        let savedEntities = databaseClient.registeredObjects.filter { $0 is LatestAnnouncement }
        guard savedEntities.count == 1 else {
            XCTFail("Multiple entities found")
            return
        }

        let testee = savedEntities.first! as! LatestAnnouncement
        XCTAssertEqual(testee.contextCode, "testContext")
        XCTAssertEqual(testee.message, "testMessage")
        XCTAssertEqual(testee.title, "testTitle")
        XCTAssertEqual(testee.postedAt, Date(timeIntervalSince1970: 74874))
    }

    func testUpdate() {
        let oldAnnouncement: LatestAnnouncement = databaseClient.insert()
        oldAnnouncement.contextCode = "testContext"
        oldAnnouncement.message = "testMessage"
        oldAnnouncement.title = "testTitle"
        oldAnnouncement.postedAt = Date(timeIntervalSince1970: 74874)

        let newAPIAnnouncement = APIDiscussionTopic.make(context_code: "testContext", message: "new testMessage", posted_at: Date(timeIntervalSince1970: 85985), title: "new testTitle")
        LatestAnnouncement.save(newAPIAnnouncement, in: databaseClient)

        let savedEntities = databaseClient.registeredObjects.filter { $0 is LatestAnnouncement }
        guard savedEntities.count == 1 else {
            XCTFail("Multiple entities found")
            return
        }

        let testee = savedEntities.first! as! LatestAnnouncement
        XCTAssertEqual(testee.contextCode, "testContext")
        XCTAssertEqual(testee.message, "new testMessage")
        XCTAssertEqual(testee.title, "new testTitle")
        XCTAssertEqual(testee.postedAt, Date(timeIntervalSince1970: 85985))
    }
}
