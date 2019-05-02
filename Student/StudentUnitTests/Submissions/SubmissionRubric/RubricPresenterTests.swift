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

@testable import Student
import XCTest
import Core
import TestsFoundation

class RubricPresenterTests: PersistenceTestCase {
    var presenter: RubricPresenter!
    var view: SubmissionCommentsView!
    var courseID = "1"
    var assignmentID = "2"
    var userID = "1"
    var models: [RubricViewModel] = []
    var showEmptyStateFlag = false

    override func setUp() {
        super.setUp()
        models = []
        showEmptyStateFlag = false
        presenter = RubricPresenter(env: env, view: self, courseID: courseID, assignmentID: assignmentID, userID: userID)
    }

    func testViewIsReady() {
        Rubric.make(["id": "1"])
        Submission.make(["assignmentID": "2", "userID": "1", "rubricAssesmentRaw": Set( [RubricAssessment.make()] )])
        let expected: [RubricViewModel] = [
            RubricViewModel(title: "Effort", longDescription: "Did you even try?", selectedDesc: "Great!", selectedIndex: 1, ratings: [10.0, 25.0], comment: "random comment"),
        ]

        presenter.viewIsReady()

        XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
        XCTAssertEqual(models.count, expected.count)
        XCTAssertEqual(models.first, expected.first)
    }

    func testViewEmptyState() {
        presenter.viewIsReady()
        XCTAssertTrue(showEmptyStateFlag)
    }

    func testCustomGradeIsHandled() {
        Rubric.make(["id": "1"])
        let custom = RubricAssessment.make(["points": 1.0, "comments": "this is custom", "ratingID": "3"])
        Submission.make(["assignmentID": "2", "userID": "1", "rubricAssesmentRaw": Set( [custom] )])
        let expected: [RubricViewModel] = [
            RubricViewModel(title: "Effort", longDescription: "Did you even try?", selectedDesc: "Custom Grade", selectedIndex: 2, ratings: [10.0, 25.0, 1.0], comment: "this is custom"),
        ]

        presenter.viewIsReady()

        XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
        XCTAssertEqual(models.count, expected.count)
        XCTAssertEqual(models.first, expected.first)
    }
}

extension RubricPresenterTests: RubricViewProtocol {
    func update(_ rubric: [RubricViewModel]) {
        models = rubric
    }

    func showEmptyState() {
        showEmptyStateFlag = true
    }

    var navigationController: UINavigationController? {
        return nil
    }
}

extension RubricViewModel: Equatable {
    public static func == (lhs: RubricViewModel, rhs: RubricViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.ratings == rhs.ratings &&
        lhs.selectedDesc == rhs.selectedDesc &&
        lhs.selectedIndex == rhs.selectedIndex
    }
}
