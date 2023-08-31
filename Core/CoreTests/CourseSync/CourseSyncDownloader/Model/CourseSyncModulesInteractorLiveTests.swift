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
import Foundation
import XCTest

class CourseSyncModulesInteractorLiveTests: CoreTestCase {
    private var testee: CourseSyncModulesInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CourseSyncModulesInteractorLive()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testSuccess() {
        mockModules()
        XCTAssertFinish(testee.getContent(courseId: "course-1"))
    }

    func testFailure() {
        mockModulesError()
        XCTAssertFailure(testee.getContent(courseId: "course-1"))
    }

    private func mockModules() {
        api.mock(
            GetModulesRequest(courseID: "course-1"),
            value: [
                .make(
                    id: "module-1",
                    name: "module-1",
                    items: [
                        .make(id: "module-item-1", module_id: "module-1"),
                        .make(id: "module-item-2", module_id: "module-1"),
                    ]
                ),
            ]
        )
    }

    private func mockModulesError() {
        api.mock(
            GetModulesRequest(courseID: "course-1"),
            error: NSError.instructureError("")
        )
    }
}
