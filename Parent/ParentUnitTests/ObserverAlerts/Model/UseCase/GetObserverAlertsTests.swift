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

import XCTest
@testable import Core
@testable import Parent

class GetObserverAlertsTests: ParentTestCase {

    func testProperties() {
        let useCase = GetObserverAlerts(studentID: "3")

        XCTAssertEqual(useCase.cacheKey, "users/self/observer_alerts/3")
        
        XCTAssertEqual(useCase.request.studentID, "3")

        XCTAssertEqual(useCase.scope, Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(ObserverAlert.userID), equals: "3"),
                NSPredicate(
                    format: "%K != %@",
                    #keyPath(ObserverAlert.workflowStateRaw),
                    "dismissed"
                )
            ]),
            orderBy: #keyPath(ObserverAlert.actionDate),
            ascending: false
        ))
    }
}
