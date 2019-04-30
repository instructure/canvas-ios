//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class RubricTests: CoreTestCase {
    func testRubricScope() {
        let two = Rubric.make(["position": 2, "id": "2"])
        let one = Rubric.make(["position": 1, "id": "1"])
        let scope = Rubric.scope(assignmentID: "2")

        let rubrics: [Rubric] = databaseClient.fetch(predicate: scope.predicate, sortDescriptors: scope.order)
        XCTAssertEqual(rubrics.count, 2)
        XCTAssertEqual(rubrics.first, one)
        XCTAssertEqual(rubrics.last, two)
    }

    func testSaveRating() {
        RubricRating.make(["id": "1", "assignmentID": "2"])
        let item = APIRubricRating.make(["id": "1", "assignmentID": "2", "points": 100.0])

        let rating = try? RubricRating.save(item, in: databaseClient)

        XCTAssertNotNil(rating)
        let ratings: [RubricRating] = databaseClient.fetch(predicate: NSPredicate.all)

        XCTAssertEqual(ratings.count, 1)
        XCTAssertEqual(ratings.first?.points, 100)
    }

    func testSaveAssessment() {
        RubricAssessment.make(["id": "1", "submissionID": "1", "points": 2.0])
        let item = APIRubricAssessment.make(["points": 200.0])

        let assessment = try? RubricAssessment.save(item, in: databaseClient, id: "1", submissionID: "1")

        XCTAssertNotNil(assessment)
        let assessments: [RubricAssessment] = databaseClient.fetch(predicate: NSPredicate.all)

        XCTAssertEqual(assessments.count, 1)
        XCTAssertEqual(assessments.first?.points, 200)
    }
}
