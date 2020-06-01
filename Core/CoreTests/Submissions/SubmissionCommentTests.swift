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

import Foundation
import XCTest
@testable import Core

class SubmissionCommentTests: CoreTestCase {
    func testMediaType() {
        let comment = SubmissionComment.make()
        XCTAssertNil(comment.mediaType)
        comment.mediaType = .audio
        XCTAssertEqual(comment.mediaType, .audio)
        XCTAssertEqual(comment.mediaTypeRaw, "audio")
    }

    func testAttempt() {
        XCTAssertNil(SubmissionComment.make().attempt)
        XCTAssertEqual(SubmissionComment.make(from: .make(id: "submission-1-2")).attempt, 2)
    }
}
