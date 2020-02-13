//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import XCTest
@testable import Core

class PlannableTests: CoreTestCase {

    func testPlannable() {
        let p = Plannable.make(from: .make())
        XCTAssertEqual(p.id, "1")
    }

    func testAPIPlannable() {
        let p = APIPlannable.make()
        XCTAssertEqual(p.plannable_id, "1")
        XCTAssertEqual(p.context_type, "course")
        XCTAssertEqual(p.course_id, "1")
        XCTAssertEqual(p.plannable_type, "Assignment")
        XCTAssertNil(p.planner_override)
    }

    func testPlannerOverride() {
        let override = APIPlannerOverride.make()
        XCTAssertEqual(override.id, "1")
        XCTAssertEqual(override.dismissed, false)
        XCTAssertEqual(override.marked_complete, false)
    }

    func testIcon() {
        var p = Plannable.make(from: .make(plannable_type: "assignment"))
        XCTAssertEqual(p.icon(), UIImage.icon(.assignment, .line))

        p = Plannable.make(from: .make(plannable_type: "quiz"))
        XCTAssertEqual(p.icon(), UIImage.icon(.quiz, .line))

        p = Plannable.make(from: .make(plannable_type: "discussion_topic"))
        XCTAssertEqual(p.icon(), UIImage.icon(.discussion, .line))

        p = Plannable.make(from: .make(plannable_type: "wiki_page"))
        XCTAssertEqual(p.icon(), UIImage.icon(.document, .line))

        p = Plannable.make(from: .make(plannable_type: "planner_note"))
        XCTAssertEqual(p.icon(), UIImage.icon(.document, .line))

        p = Plannable.make(from: .make(plannable_type: "other"))
        XCTAssertEqual(p.icon(), UIImage.icon(.warning, .line))

        p = Plannable.make(from: .make(plannable_type: "announcement"))
        XCTAssertEqual(p.icon(), UIImage.icon(.announcement, .line))
    }
}
