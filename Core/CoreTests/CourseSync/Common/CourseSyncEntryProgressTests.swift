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

class CourseSyncEntryProgressTests: CoreTestCase {
    func testCourseSelectionMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.selection = .course("course-1")

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.entryID, "course-1")
        XCTAssertEqual(testee.selection, .course("course-1"))
        XCTAssertEqual(testee.selectionRaw, 0)
    }

    func testTabSelectionMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.selection = .tab("course-1", "tab-1")

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.entryID, "course-1")
        XCTAssertEqual(testee.tabID, "tab-1")
        XCTAssertEqual(testee.selection, .tab("course-1", "tab-1"))
        XCTAssertEqual(testee.selectionRaw, 1)
    }

    func testFileSelectionMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.selection = .file("course-1", "file-1")

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.entryID, "course-1")
        XCTAssertEqual(testee.fileID, "file-1")
        XCTAssertEqual(testee.selection, .file("course-1", "file-1"))
        XCTAssertEqual(testee.selectionRaw, 2)
    }

    func testIdleStateMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.state = .idle

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.state, .idle)
        XCTAssertEqual(testee.stateRaw, 0)
    }

    func testNilProgressLoadingStateMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.state = .loading(nil)

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.state, .loading(nil))
        XCTAssertEqual(testee.stateRaw, 1)
        XCTAssertEqual(testee.progress, nil)
    }

    func testNotNilProgressLoadingStateMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.state = .loading(0.75)

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.state, .loading(0.75))
        XCTAssertEqual(testee.stateRaw, 1)
        XCTAssertEqual(testee.progress, 0.75)
    }

    func testErrorStateMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.state = .error

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.state, .error)
        XCTAssertEqual(testee.stateRaw, 2)
    }

    func testDownloadedStateMapping() {
        let progress: CourseSyncStateProgress = databaseClient.insert()
        progress.state = .downloaded

        let testee: CourseSyncStateProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.state, .downloaded)
        XCTAssertEqual(testee.stateRaw, 3)
    }
}
