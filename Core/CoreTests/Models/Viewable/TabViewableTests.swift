//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class TabViewableTests: XCTestCase {
    struct Model: TabViewable {
        let id: String
    }

    func testIcon() {
        XCTAssertEqual(Model(id: "announcements").icon, .announcementLine)
        XCTAssertEqual(Model(id: "application").icon, .ltiLine)
        XCTAssertEqual(Model(id: "assignments").icon, .assignmentLine)
        XCTAssertEqual(Model(id: "attendance").icon, .attendance)
        XCTAssertEqual(Model(id: "collaborations").icon, .collaborations)
        XCTAssertEqual(Model(id: "conferences").icon, .conferences)
        XCTAssertEqual(Model(id: "discussions").icon, .discussionLine)
        XCTAssertEqual(Model(id: "files").icon, .folderLine)
        XCTAssertEqual(Model(id: "grades").icon, .gradebookLine)
        XCTAssertEqual(Model(id: "home").icon, .homeLine)
        XCTAssertEqual(Model(id: "link").icon, .linkLine)
        XCTAssertEqual(Model(id: "modules").icon, .moduleLine)
        XCTAssertEqual(Model(id: "outcomes").icon, .outcomesLine)
        XCTAssertEqual(Model(id: "pages").icon, .documentLine)
        XCTAssertEqual(Model(id: "people").icon, .groupLine)
        XCTAssertEqual(Model(id: "quizzes").icon, .quizLine)
        XCTAssertEqual(Model(id: "settings").icon, .settingsLine)
        XCTAssertEqual(Model(id: "syllabus").icon, .rubricLine)
        XCTAssertEqual(Model(id: "tools").icon, .ltiLine)
        XCTAssertEqual(Model(id: "user").icon, .userLine)
        XCTAssertEqual(Model(id: "context_external_tool_1").icon, .ltiLine)
        XCTAssertEqual(Model(id: "1234").icon, .coursesLine)
    }
}
