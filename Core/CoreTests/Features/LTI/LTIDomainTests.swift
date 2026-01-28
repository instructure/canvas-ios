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

class LTIDomainTests: XCTestCase {

    func testIcons() {
        XCTAssertEqual(LTIDomain.studio.icon, .studioLine)
        XCTAssertEqual(LTIDomain.gauge.icon, .ltiLine)
        XCTAssertEqual(LTIDomain.gauge.icon, LTIDomain.defaultIcon)
        XCTAssertEqual(LTIDomain.masteryConnect.icon, .masteryLTI)
        XCTAssertEqual(LTIDomain.eportfolio.icon, .eportfolioLine)
    }

    func testRawValues() {
        XCTAssertEqual(LTIDomain.studio.rawValue, "arc.instructure.com")
        XCTAssertEqual(LTIDomain.gauge.rawValue, "gauge.instructure.com")
        XCTAssertEqual(LTIDomain.masteryConnect.rawValue, "app.masteryconnect.com")
        XCTAssertEqual(LTIDomain.eportfolio.rawValue, "portfolio.instructure.com")
    }

    func testIntialization() {
        XCTAssertEqual(LTIDomain(rawValue: "arc.instructure.com"), .studio)
        XCTAssertEqual(LTIDomain(rawValue: "gauge.instructure.com"), .gauge)
        XCTAssertEqual(LTIDomain(rawValue: "app.masteryconnect.com"), .masteryConnect)

        XCTAssertEqual(LTIDomain(rawValue: "portfolio.instructure.com"), .eportfolio)
        XCTAssertEqual(LTIDomain(rawValue: "iad.portfolio.instructure.com"), .eportfolio)
        XCTAssertEqual(LTIDomain(rawValue: "dub.portfolio.instructure.com"), .eportfolio)
        XCTAssertNil(LTIDomain(rawValue: ".portfolio.instructure.com"))
    }
}
