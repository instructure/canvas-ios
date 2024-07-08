//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest

class GetInboxMessageListTests: CoreTestCase {

    // MARK: - Cache Invalidation

    func testInvalidateCaches() {
        // MARK: - GIVEN
        let cacheKeys = [
            "inbox/all?contextCode=course_20783",
            "inbox/all?contextCode=course_23500",
            "inbox/all?contextCode=course_23498",
            "inbox/all?contextCode=course_21978",
            "inbox/sent?contextCode=course_23500",
            "inbox/unread?contextCode=course_23498",
            "inbox/all?contextCode=all",
            "inbox/starred?contextCode=all",
            "inbox/unread?contextCode=all",
            "inbox/archived?contextCode=all",
            "imbox/archived?contextCode=all"
        ]
        var ttls: [TTL] = []

        for key in cacheKeys {
            let ttl: TTL = databaseClient.insert()
            ttl.key = key
            ttl.lastRefresh = .distantFuture
            ttls.append(ttl)
        }

        XCTAssertEqual(databaseClient.registeredObjects.count, 11)
        let testee = GetInboxMessageList(currentUserId: "")

        // MARK: - WHEN
        testee.invalidateCaches(in: databaseClient)

        // MARK: - THEN
        XCTAssertEqual(databaseClient.registeredObjects.count, 1)
        guard let ttl = databaseClient.registeredObjects.first as? TTL else { return XCTFail() }
        XCTAssertEqual(ttl.key, "imbox/archived?contextCode=all")
        XCTAssertEqual(ttl.lastRefresh, .distantFuture)
    }
}
