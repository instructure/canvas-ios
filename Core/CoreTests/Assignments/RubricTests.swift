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

class RubricTests: CoreTestCase {
    func testRubricScope() {
        let two = Rubric.make(from: .make(id: "2", position: 2))
        let one = Rubric.make(from: .make(id: "1", position: 1))
        let scope = Rubric.scope(assignmentID: "1")

        let rubrics: [Rubric] = databaseClient.fetch(scope.predicate, sortDescriptors: scope.order)
        XCTAssertEqual(rubrics.count, 2)
        XCTAssertEqual(rubrics.first, one)
        XCTAssertEqual(rubrics.last, two)
    }

    func testSaveRating() {
        RubricRating.make(from: .make(id: "1", assignmentID: "2"))
        let item = APIRubricRating.make(id: "1", points: 100.0, assignmentID: "2")

        RubricRating.save(item, in: databaseClient)
        let ratings: [RubricRating] = databaseClient.fetch()

        XCTAssertEqual(ratings.count, 1)
        XCTAssertEqual(ratings.first?.points, 100)
    }

    func testSaveAssessment() {
        RubricAssessment.make(from: .make(submissionID: "1", points: 2.0), id: "1")
        let item = APIRubricAssessment.make(points: 200.0)

        RubricAssessment.save(item, in: databaseClient, id: "1", submissionID: "1")
        let assessments: [RubricAssessment] = databaseClient.fetch()

        XCTAssertEqual(assessments.count, 1)
        XCTAssertEqual(assessments.first?.points, 200)
    }
}
