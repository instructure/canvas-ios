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
@testable import Core
import XCTest
import TestsFoundation

class ActivityTests: CoreTestCase {
    func testModel() {
        let url = URL(string: "/courses/1/assignments/1")
        let a = Activity.make(from: .make(course_id: "1", assignment: .init(id: "12", html_url: url)))
        let all: [Activity] =  databaseClient.fetch()
        XCTAssertEqual(all.count, 1)
        let aa = try! XCTUnwrap( all.first )

        XCTAssertEqual(a.id, aa.id)
        XCTAssertEqual(a.context?.canvasContextID, aa.context?.canvasContextID)
        XCTAssertEqual(a.htmlURL, aa.htmlURL)
        XCTAssertEqual(a.message, aa.message)
        XCTAssertEqual(a.title, aa.title)
        XCTAssertEqual(a.assignmentURL, url)
        XCTAssertEqual(a.announcementId, "123")
    }
}
