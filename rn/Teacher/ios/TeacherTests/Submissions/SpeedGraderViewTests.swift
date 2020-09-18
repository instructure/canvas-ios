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

import SwiftUI
import Combine
@testable import Core
@testable import Teacher
import TestsFoundation

class SpeedGraderViewTests: TeacherTestCase {
    lazy var controller: CoreHostingController<SpeedGraderView> = {
        api.mock(GetAssignment(courseID: "1", assignmentID: "1", include: [ .overrides ]), value: .make())
        api.mock(GetSubmissions(context: .course("1"), assignmentID: "1", filter: nil), value: [
            .make(),
        ])
        return hostSwiftUIController(SpeedGraderView(context: .course("1"), assignmentID: "1", userID: "1", filter: nil))
    }()

    func getTestTree() -> TestTree? {
        _ = controller
        drainMainQueue()
        return controller.testTree
    }

    func testSpeedGrader() throws {
        let tree = getTestTree()
        XCTAssertNotNil(tree?.find(id: "SpeedGrader.submission.1"))
        XCTAssertNil(tree?.find(id: "SpeedGrader.emptyCloseButton"))
    }

    func testEmpty() throws {
        controller = hostSwiftUIController(SpeedGraderView(context: .course("1"), assignmentID: "1", userID: "bogus", filter: nil))
        let tree = getTestTree()
        XCTAssertNil(tree?.find(id: "SpeedGrader.submission.1"))
        XCTAssertNotNil(tree?.find(id: "SpeedGrader.emptyCloseButton"))
    }
}
