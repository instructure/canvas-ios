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

import XCTest
@testable import Core

final class DeletePlannerNoteTests: CoreTestCase {

    func testRequest() {
        let testee = DeletePlannerNote(id: "42")
        XCTAssertEqual(testee.request.id, "42")
    }

    func testWrite() {
        Plannable.save(.make(id: "1"), contextName: nil, in: databaseClient)
        Plannable.save(.make(id: "2"), contextName: nil, in: databaseClient)
        Plannable.save(.make(id: "3"), contextName: nil, in: databaseClient)
        let testee = DeletePlannerNote(id: "2")

        testee.write(response: .make(id: "3"), urlResponse: nil, to: databaseClient)

        let plannable1: Plannable? = databaseClient.first(where: #keyPath(Plannable.id), equals: "1")
        let plannable2: Plannable? = databaseClient.first(where: #keyPath(Plannable.id), equals: "2")
        let plannable3: Plannable? = databaseClient.first(where: #keyPath(Plannable.id), equals: "3")
        XCTAssertEqual(plannable1?.id, "1")
        XCTAssertEqual(plannable2?.id, nil)
        XCTAssertEqual(plannable3?.id, "3")
    }
}
