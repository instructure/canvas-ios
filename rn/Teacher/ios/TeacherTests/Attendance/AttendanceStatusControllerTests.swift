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
@testable import Teacher
import TestsFoundation

class AttendanceStatusControllerTests: TeacherTestCase {
    func testUpdate() {
        let context = Context(.course, id: "1")
        let session = RollCallSession(context: context, toolID: "2")
        session.state = .active(API())

        let controller = AttendanceStatusController(status: .make(attendance: .present), in: session)
        XCTAssertNoThrow(controller.statusDidChange())
        XCTAssertNoThrow(controller.statusUpdateDidFail(NSError.internalError()))

        let url = URL(string: "/statuses/1", relativeTo: session.baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = APIMethod.put.rawValue
        api.mock(request, error: NSError.internalError())
        controller.update(attendance: .absent)
        XCTAssertEqual(controller.status.attendance, .absent)

        let errored = expectation(description: "errored")
        controller.statusUpdateDidFail = { _ in errored.fulfill() }
        controller.timer?.fire()
        wait(for: [errored], timeout: 1)
        XCTAssertEqual(controller.status.attendance, .present)

        api.mock(request, data: try? session.encoder.encode(Status.make(id: "2")))
        controller.update(attendance: .absent)
        XCTAssertEqual(controller.status.attendance, .absent)

        let changed = expectation(description: "changed")
        controller.statusDidChange = { changed.fulfill() }
        controller.timer?.fire()
        wait(for: [changed], timeout: 1)
        XCTAssertEqual(controller.status.attendance, .absent)
        XCTAssertEqual(controller.status.id, ID("2"))
    }
}
