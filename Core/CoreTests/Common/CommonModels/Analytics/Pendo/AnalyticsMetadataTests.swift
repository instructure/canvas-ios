//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation
@testable import Core
import XCTest

class AnalyticsMetadataTests: XCTestCase {

    func testVisitorDataSerialization() throws {
        let data = AnalyticsMetadata.VisitorData(id: "some id", locale: "some locale")

        let result = try XCTUnwrap(data.toMap())

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["id"] as? String, "some id")
        XCTAssertEqual(result["locale"] as? String, "some locale")
    }

    func testAccountDataSerialization() throws {
        let data = AnalyticsMetadata.AccountData(id: "some id", surveyOptOut: true)

        let result = try XCTUnwrap(data.toMap())

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["id"] as? String, "some id")
        XCTAssertEqual(result["surveyOptOut"] as? Bool, true)
    }
}
