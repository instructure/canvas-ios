//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation
@testable import Core

class ExternalToolLaunchPlacementTests: CoreTestCase {
    func testLocation() {
        let placement: ExternalToolLaunchPlacement = databaseClient.insert()
        placement.location = .global_navigation
        XCTAssertEqual(placement.locationRaw, "global_navigation")
        placement.locationRaw = "account_navigation"
        XCTAssertEqual(placement.location, .account_navigation)
        placement.locationRaw = "bogus"
        XCTAssertEqual(placement.location, .account_navigation)
    }
}
