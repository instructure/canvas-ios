//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class FileAvailabilityTests: XCTestCase {

    func testHiddenStateFromAPIResponse() {
        let apiModuleItem = APIModuleItem.make(published: true, content_details: .make(hidden: true))

        let testee = FileAvailability(moduleItem: apiModuleItem)

        XCTAssertEqual(testee, .hidden)
    }

    func testPublishedStateFromAPIResponse() {
        let apiModuleItem = APIModuleItem.make(published: true, content_details: nil)

        let testee = FileAvailability(moduleItem: apiModuleItem)

        XCTAssertEqual(testee, .published)
    }

    func testUnPublishedStateFromAPIResponse() {
        let apiModuleItem = APIModuleItem.make(published: false, content_details: nil)

        let testee = FileAvailability(moduleItem: apiModuleItem)

        XCTAssertEqual(testee, .unpublished)
    }

    func testScheduledWithUnlockStateFromAPIResponse() {
        let apiModuleItem = APIModuleItem.make(published: true, content_details: .make(unlock_at: Date()))

        let testee = FileAvailability(moduleItem: apiModuleItem)

        XCTAssertEqual(testee, .scheduledAvailability)
    }

    func testScheduledWithLockDateStateFromAPIResponse() {
        let apiModuleItem = APIModuleItem.make(published: true, content_details: .make(lock_at: Date()))

        let testee = FileAvailability(moduleItem: apiModuleItem)

        XCTAssertEqual(testee, .scheduledAvailability)
    }
}
