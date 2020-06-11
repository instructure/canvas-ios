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

@testable import Student
import XCTest
import Core
import TestsFoundation

class RubricPresenterTests: StudentTestCase {
    var presenter: RubricPresenter!
    var view: SubmissionCommentsView!
    var courseID = "1"
    var assignmentID = "1"
    var userID = "1"
    var models: [RubricViewModel] = []
    var showEmptyStateFlag = false

    override func setUp() {
        super.setUp()
        env.mockStore = true
        models = []
        showEmptyStateFlag = false
        presenter = RubricPresenter(env: env, view: self, courseID: courseID, assignmentID: assignmentID, userID: userID)
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.assignments.useCase.courseID, presenter.courseID)
        XCTAssertEqual(presenter.assignments.useCase.assignmentID, presenter.assignmentID)
        XCTAssertEqual(presenter.assignments.useCase.include, [.submission])

        XCTAssertEqual(presenter.submissions.useCase.context.canvasContextID, "course_\(presenter.courseID)")
        XCTAssertEqual(presenter.submissions.useCase.assignmentID, presenter.assignmentID)
        XCTAssertEqual(presenter.submissions.useCase.userID, presenter.userID)

        XCTAssertEqual(presenter.courses.useCase.courseID, presenter.courseID)
    }

    func setupData() -> [RubricViewModel] {
        Assignment.make()
        Course.make()
        ContextColor.make()
        let rubric = Rubric.make(from: .make(id: "1", ratings: [
            .make(id: "1", points: 10, position: 1),
            .make(id: "2", points: 25, position: 2),
        ]))
        Submission.make(from: .make(rubric_assessment: [
            "1": .make(points: 10.0, rating_id: "1"),
            "2": .make(points: 25.0, rating_id: "2"),
        ]))
        return [
            RubricViewModel(
                id: "1",
                title: "Effort",
                longDescription: "Did you even try?",
                selectedDesc: "Excellent",
                selectedIndex: 0,
                ratings: [10.0, 25.0],
                descriptions: ["Excellent", "Excellent"],
                comment: "You failed at punctuation!",
                rubricRatings: Array(rubric.ratings!).sorted { $0.points < $1.points },
                isCustomAssessment: false,
                hideRubricPoints: false,
                freeFormCriterionComments: false
            ),
        ]
    }

    func testLoadAssignments() {
        let expected = setupData()

        presenter.assignments.eventHandler()
        XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
        XCTAssertEqual(models.count, expected.count)
        XCTAssertEqual(models.first, expected.first)
    }

    func testLoadSubmissions() {
         let expected = setupData()

         presenter.submissions.eventHandler()
         XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
         XCTAssertEqual(models.count, expected.count)
         XCTAssertEqual(models.first, expected.first)
    }

    func testLoadRubrics() {
         let expected = setupData()

         presenter.rubrics.eventHandler()
         XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
         XCTAssertEqual(models.count, expected.count)
         XCTAssertEqual(models.first, expected.first)
    }

    func testLoadColors() {
         let expected = setupData()

         presenter.colors.eventHandler()
         XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
         XCTAssertEqual(models.count, expected.count)
         XCTAssertEqual(models.first, expected.first)
    }

    func testLoadCourses() {
         let expected = setupData()

         presenter.courses.eventHandler()
         XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
         XCTAssertEqual(models.count, expected.count)
         XCTAssertEqual(models.first, expected.first)
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        let assignmentsStore = presenter.assignments as! TestStore
        let submissionsStore = presenter.submissions as! TestStore
        let rubricsStore = presenter.rubrics as! TestStore
        let colorsStore = presenter.colors as! TestStore
        let coursesStore = presenter.courses as! TestStore

        wait(for: [
            assignmentsStore.refreshExpectation,
            submissionsStore.refreshExpectation,
            rubricsStore.refreshExpectation,
            colorsStore.refreshExpectation,
            coursesStore.refreshExpectation,
        ], timeout: 0.1)
    }

    func testViewEmptyState() {
        presenter.update()
        XCTAssertTrue(showEmptyStateFlag)
    }

    func testCustomGradeIsHandled() {
        let ratings: [APIRubricRating] = [
            .make(id: "1", points: 10, position: 1),
            .make(id: "2", points: 25, position: 2),
        ]

        let rubric = Rubric.make(from: .make(id: "1", ratings: ratings))
        Submission.make(from: .make(rubric_assessment: [
            "1": .make(points: 1.0, comments: "this is custom", rating_id: "3"),
        ]))
        Course.make()
        Assignment.make()
        ContextColor.make()
        let expected: [RubricViewModel] = [
            RubricViewModel(
                id: "1",
                title: "Effort",
                longDescription: "Did you even try?",
                selectedDesc: "Custom Grade",
                selectedIndex: 2,
                ratings: [10.0, 25.0, 1.0],
                descriptions: ["Excellent", "Excellent", "Custom Grade"],
                comment: "this is custom",
                rubricRatings: Array(rubric.ratings!).sorted { $0.points < $1.points },
                isCustomAssessment: true,
                hideRubricPoints: false,
                freeFormCriterionComments: false
            ),
        ]

        presenter.update()

        XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
        XCTAssertEqual(models.count, expected.count)
        XCTAssertEqual(models.first, expected.first)
    }

    func testCustomGradeAndFreeFormCriterionCommentsTrue() {
        let ratings: [APIRubricRating] = [
            .make(id: "1", points: 10, position: 1),
            .make(id: "2", points: 25, position: 2),
        ]

        let rubric = Rubric.make(from: .make(id: "1", ratings: ratings))
        Submission.make(from: .make(rubric_assessment: [
            "1": .make(points: 1.0, comments: "this is custom", rating_id: "2"),
        ]))
        Course.make()
        Assignment.make(from: .make(rubric_settings: .make(free_form_criterion_comments: true)))
        ContextColor.make()
        let expected: [RubricViewModel] = [
            RubricViewModel(
                id: "1",
                title: "Effort",
                longDescription: "Did you even try?",
                selectedDesc: "Custom Grade",
                selectedIndex: 2,
                ratings: [10.0, 25.0, 1.0],
                descriptions: ["Excellent", "Excellent", "Custom Grade"],
                comment: "this is custom",
                rubricRatings: Array(rubric.ratings!).sorted { $0.points < $1.points },
                isCustomAssessment: true,
                hideRubricPoints: false,
                freeFormCriterionComments: true
            ),
        ]

        presenter.update()

        XCTAssertEqual(presenter.rubrics.first?.ratings?.count, 2)
        XCTAssertEqual(models.count, expected.count)
        XCTAssertEqual(models.first, expected.first)
    }

    func testRubricViewModelRatingBlurb() {
        let r = Rubric.make()
        let rating = RubricRating.make()
        let model = RubricViewModel(id: r.id,
                                    title: r.desc,
                                    longDescription: r.longDesc,
                                    selectedDesc: "Custom Grade",
                                    selectedIndex: 1,
                                    ratings: [1.0, 2.0],
                                    descriptions: ["Bad"],
                                    comment: nil,
                                    rubricRatings: [rating],
                                    isCustomAssessment: true,
                                    hideRubricPoints: false,
                                    freeFormCriterionComments: false)

        let a = model.ratingBlurb(0)
        let b = model.ratingBlurb(1)

        XCTAssertEqual(a.header, "Excellent")
        XCTAssertEqual(a.subHeader, "Like the best!")

        XCTAssertEqual(b.header, "Custom Grade")
        XCTAssertEqual(b.subHeader, "")
    }
}

extension RubricPresenterTests: RubricViewProtocol {
    func showEmptyState(_ show: Bool) {
        showEmptyStateFlag = show
    }

    func update(_ rubric: [RubricViewModel]) {
        models = rubric
    }

    func showAlert(title: String?, message: String?) {}
}
