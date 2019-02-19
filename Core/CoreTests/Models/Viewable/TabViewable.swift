//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class TabViewableTests: XCTestCase {
    struct Model: TabViewable {
        let id: String
    }

    func testIcon() {
        XCTAssertEqual(Model(id: "announcements").icon, .icon(.announcement, .line))
        XCTAssertEqual(Model(id: "application").icon, .icon(.lti, .solid))
        XCTAssertEqual(Model(id: "assignments").icon, .icon(.assignment, .line))
        XCTAssertEqual(Model(id: "attendance").icon, .icon(.attendance))
        XCTAssertEqual(Model(id: "collaborations").icon, .icon(.collaborations))
        XCTAssertEqual(Model(id: "conferences").icon, .icon(.conferences))
        XCTAssertEqual(Model(id: "discussions").icon, .icon(.discussion, .line))
        XCTAssertEqual(Model(id: "files").icon, .icon(.folder, .line))
        XCTAssertEqual(Model(id: "grades").icon, .icon(.gradebook, .line))
        XCTAssertEqual(Model(id: "link").icon, .icon(.link, .line))
        XCTAssertEqual(Model(id: "modules").icon, .icon(.module, .line))
        XCTAssertEqual(Model(id: "outcomes").icon, .icon(.outcomes, .line))
        XCTAssertEqual(Model(id: "pages").icon, .icon(.document, .line))
        XCTAssertEqual(Model(id: "people").icon, .icon(.group, .line))
        XCTAssertEqual(Model(id: "quizzes").icon, .icon(.quiz, .line))
        XCTAssertEqual(Model(id: "settings").icon, .icon(.settings, .line))
        XCTAssertEqual(Model(id: "syllabus").icon, .icon(.rubric, .line))
        XCTAssertEqual(Model(id: "tools").icon, .icon(.lti, .solid))
        XCTAssertEqual(Model(id: "user").icon, .icon(.user, .line))
        XCTAssertEqual(Model(id: "context_external_tool_1").icon, .icon(.lti, .solid))
        XCTAssertEqual(Model(id: "1234").icon, .icon(.courses, .line))
    }
}
