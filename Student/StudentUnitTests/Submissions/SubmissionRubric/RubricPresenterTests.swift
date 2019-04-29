//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
            RubricViewModel(title: "Effort", selectedDesc: "Great!", selectedIndex: 1, ratings: [10.0, 25.0], comment: "random comment"),
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
            RubricViewModel(title: "Effort", selectedDesc: "Custom Grade", selectedIndex: 2, ratings: [10.0, 25.0, 1.0], comment: "this is custom"),
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
