//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class PlannerOverrideUpdaterTests: CoreTestCase {

    func testCreatedOverrideIdSave() {
        let testee = PlannerOverrideUpdater(api: api, plannableId: ID("1"), plannableType: "calendar_event", overrideId: nil)

        XCTAssertNil(testee.overrideId)
        api.mock(CreatePlannerOverrideRequest(body: .init(plannable_type: "calendar_event", plannable_id: "1", marked_complete: true)), value: .make(id: ID("overrideID")))
        testee.markAsComplete(isComplete: true, completion: { _ in })
        XCTAssertEqual(testee.overrideId, ID("overrideID"))
    }
}
