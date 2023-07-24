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
import XCTest

class CourseSyncFrequencyTests: XCTestCase {

    func testSyncFrequencyNames() {
        XCTAssertEqual(CourseSyncFrequency.weekly.stringValue, "Weekly")
        XCTAssertEqual(CourseSyncFrequency.daily.stringValue, "Daily")
    }

    func testSyncFrequenciesToItemPickerData() {
        let testee = CourseSyncFrequency.itemPickerData
        XCTAssertEqual(testee.count, 1)

        guard let section = testee.first else {
            return XCTFail()
        }

        XCTAssertNil(section.title)
        XCTAssertEqual(section.items.count, 2)
        XCTAssertEqual(section.items[0].title, "Daily")
        XCTAssertEqual(section.items[0].accessibilityIdentifier, nil)
        XCTAssertEqual(section.items[0].image, nil)
        XCTAssertEqual(section.items[0].subtitle, nil)
        XCTAssertEqual(section.items[1].title, "Weekly")
        XCTAssertEqual(section.items[1].accessibilityIdentifier, nil)
        XCTAssertEqual(section.items[1].image, nil)
        XCTAssertEqual(section.items[1].subtitle, nil)
    }
}
