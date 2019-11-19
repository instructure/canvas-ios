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
        XCTAssertEqual(Model(id: "announcements").icon, .icon(.announcement, .line))
        XCTAssertEqual(Model(id: "application").icon, .icon(.lti, .line))
        XCTAssertEqual(Model(id: "assignments").icon, .icon(.assignment, .line))
        XCTAssertEqual(Model(id: "attendance").icon, .icon(.attendance))
        XCTAssertEqual(Model(id: "collaborations").icon, .icon(.collaborations))
        XCTAssertEqual(Model(id: "conferences").icon, .icon(.conferences))
        XCTAssertEqual(Model(id: "discussions").icon, .icon(.discussion, .line))
        XCTAssertEqual(Model(id: "files").icon, .icon(.folder, .line))
        XCTAssertEqual(Model(id: "grades").icon, .icon(.gradebook, .line))
        XCTAssertEqual(Model(id: "home").icon, .icon(.home, .line))
        XCTAssertEqual(Model(id: "link").icon, .icon(.link, .line))
        XCTAssertEqual(Model(id: "modules").icon, .icon(.module, .line))
        XCTAssertEqual(Model(id: "outcomes").icon, .icon(.outcomes, .line))
        XCTAssertEqual(Model(id: "pages").icon, .icon(.document, .line))
        XCTAssertEqual(Model(id: "people").icon, .icon(.group, .line))
        XCTAssertEqual(Model(id: "quizzes").icon, .icon(.quiz, .line))
        XCTAssertEqual(Model(id: "settings").icon, .icon(.settings, .line))
        XCTAssertEqual(Model(id: "syllabus").icon, .icon(.rubric, .line))
        XCTAssertEqual(Model(id: "tools").icon, .icon(.lti, .line))
        XCTAssertEqual(Model(id: "user").icon, .icon(.user, .line))
        XCTAssertEqual(Model(id: "context_external_tool_1").icon, .icon(.lti, .line))
        XCTAssertEqual(Model(id: "1234").icon, .icon(.courses, .line))
    }
}
