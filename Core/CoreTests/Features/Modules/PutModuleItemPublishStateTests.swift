//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import TestsFoundation

class PutModuleItemPublishStateTests: CoreTestCase {

    func testUpdatesPublishedStateOnModuleItem() {
        let dbItem = ModuleItem.make()
        dbItem.id = "testModuleItem"
        dbItem.courseID = "testCourse"
        dbItem.published = nil
        dbItem.moduleID = "testModule"

        let mockRequest = PutModuleItemPublishRequest(
            courseId: "testCourse",
            moduleId: "testModule",
            moduleItemId: "testModuleItem",
            action: .publish
        )
        api.mock(
            mockRequest,
            value: .make(id: "testModuleItem", published: true),
            response: nil,
            error: nil
        )

        let testee = PutModuleItemPublishState(
            courseId: "testCourse",
            moduleId: "testModule",
            moduleItemId: "testModuleItem",
            action: .publish
        )

        // WHEN
        XCTAssertFinish(testee.fetchWithFuture())

        // THEN
        XCTAssertEqual(dbItem.published, true)
    }
}
