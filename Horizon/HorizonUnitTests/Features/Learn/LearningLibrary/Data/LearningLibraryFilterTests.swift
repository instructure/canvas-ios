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

@testable import Horizon
import XCTest

final class LearningLibraryFilterTests: XCTestCase {

    func testAllCases() {
        let allCases = LearningLibraryFilter.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.completed))
        XCTAssertTrue(allCases.contains(.bookmarked))
    }

    func testRawValues() {
        XCTAssertEqual(LearningLibraryFilter.all.rawValue, "all")
        XCTAssertEqual(LearningLibraryFilter.completed.rawValue, "completed")
        XCTAssertEqual(LearningLibraryFilter.bookmarked.rawValue, "bookmarked")
    }

    func testNames() {
        XCTAssertEqual(LearningLibraryFilter.all.name, "Any status")
        XCTAssertEqual(LearningLibraryFilter.completed.name, "Completed")
        XCTAssertEqual(LearningLibraryFilter.bookmarked.name, "Bookmarked")
    }

    func testFirstOption() {
        let firstOption = LearningLibraryFilter.firstOption
        XCTAssertEqual(firstOption.id, LearningLibraryFilter.all.rawValue)
        XCTAssertEqual(firstOption.name, LearningLibraryFilter.all.name)
    }

    func testOptionsWithAllFilters() {
        let filters: [LearningLibraryFilter] = [.all, .completed, .bookmarked]
        let options = LearningLibraryFilter.options(excluding: filters)

        XCTAssertEqual(options.count, 3)
        XCTAssertEqual(options[0].id, "all")
        XCTAssertEqual(options[0].name, "Any status")
        XCTAssertEqual(options[1].id, "completed")
        XCTAssertEqual(options[1].name, "Completed")
        XCTAssertEqual(options[2].id, "bookmarked")
        XCTAssertEqual(options[2].name, "Bookmarked")
    }

    func testOptionsWithSubsetOfFilters() {
        let filters: [LearningLibraryFilter] = [.completed, .bookmarked]
        let options = LearningLibraryFilter.options(excluding: filters)

        XCTAssertEqual(options.count, 2)
        XCTAssertEqual(options[0].id, "completed")
        XCTAssertEqual(options[1].id, "bookmarked")
    }

    func testOptionsWithEmptyFilters() {
        let options = LearningLibraryFilter.options(excluding: [])

        XCTAssertEqual(options.count, 0)
    }
}
