//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class APIPostPolicyInfoTests: XCTestCase {
    func testInfoModel() {
        let model = APIPostPolicyInfo(sections: [], submissions: [])
        XCTAssertNotNil(model)
    }

    func testSubmissionNodeIsHidden() {
        let node = APIPostPolicyInfo.SubmissionNode(score: 0.5, excused: false, state: "graded", postedAt: nil)
        XCTAssertTrue(node.isHidden)
    }

    func testSubmissionNodeIsHiddenWhenExcused() {
        let node = APIPostPolicyInfo.SubmissionNode(score: nil, excused: true, state: "not graded", postedAt: nil)
        XCTAssertTrue(node.isHidden)
    }

    func testSubmissionNodeIsNotHidden() {
        let node = APIPostPolicyInfo.SubmissionNode(score: 0.5, excused: false, state: "graded", postedAt: Date())
        XCTAssertFalse(node.isHidden)
    }
}
