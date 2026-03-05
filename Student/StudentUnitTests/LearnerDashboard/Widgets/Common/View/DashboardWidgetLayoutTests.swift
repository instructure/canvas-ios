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

final class DashboardWidgetLayoutTests: XCTestCase {

    func test_columnCount() {
        // WHEN width < 600
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 0), 1)
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 320), 1)
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 599), 1)

        // WHEN 600 ..< 840
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 600), 2)
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 720), 2)
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 839), 2)

        // WHEN width >= 840
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 840), 3)
        XCTAssertEqual(DashboardWidgetLayout.columnCount(for: 1024), 3)
    }
}
