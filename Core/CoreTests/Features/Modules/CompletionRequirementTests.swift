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

class CompletionRequirementTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(CompletionRequirement.make(type: .must_view, completed: false).description, "View")
        XCTAssertEqual(CompletionRequirement.make(type: .must_submit, completed: false).description, "Submit")
        XCTAssertEqual(CompletionRequirement.make(type: .must_contribute, completed: false).description, "Contribute")
        XCTAssertEqual(CompletionRequirement.make(type: .min_score, completed: false, min_score: 8.0).description, "Score at least 8")
        XCTAssertEqual(CompletionRequirement.make(type: .min_score, completed: false, min_score: 8.001).description, "Score at least 8.001")
        XCTAssertEqual(CompletionRequirement.make(type: .min_score, completed: false, min_score: 8.11111111).description, "Score at least 8.11111111")
        XCTAssertEqual(CompletionRequirement.make(type: .min_score, completed: false, min_score: nil).description, nil)
        XCTAssertEqual(CompletionRequirement.make(type: .must_mark_done, completed: false).description, "Mark done")
        XCTAssertEqual(CompletionRequirement.make(type: .must_view, completed: true).description, "Viewed")
        XCTAssertEqual(CompletionRequirement.make(type: .must_submit, completed: true).description, "Submitted")
        XCTAssertEqual(CompletionRequirement.make(type: .must_contribute, completed: true).description, "Contributed")
        XCTAssertEqual(CompletionRequirement.make(type: .min_score, completed: true, min_score: 8).description, "Scored at least 8")
        XCTAssertEqual(CompletionRequirement.make(type: .min_score, completed: true, min_score: nil).description, nil)
        XCTAssertEqual(CompletionRequirement.make(type: .must_mark_done, completed: true).description, "Marked done")
    }
}
