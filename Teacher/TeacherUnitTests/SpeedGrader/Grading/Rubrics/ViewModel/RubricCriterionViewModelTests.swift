//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Combine
@testable import Core
@testable import Teacher

class RubricCriterionViewModelTests: TeacherTestCase {

    // MARK: - Properties

    private var viewModel: RubricCriterionViewModel!
    private var interactor: RubricGradingInteractorMock!
    private var cancellables = Set<AnyCancellable>()
    private var assignment: Assignment!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        interactor = RubricGradingInteractorMock()
        assignment = Assignment.save(.make(), in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
    }

    override func tearDown() {
        viewModel = nil
        interactor = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_withRangedCriterion_createsCorrectRatingViewModels() {
        let ratings: [APIRubricRating] = [.make(id: "rating1", points: 5), .make(id: "rating2", points: 10)]
        let criterion = CDRubricCriterion.save(.make(criterion_use_range: true, id: "criterion1", ratings: ratings), assignmentID: assignment.id, in: databaseClient)

        // When
        viewModel = RubricCriterionViewModel(criterion: criterion, isFreeFormCommentsEnabled: false, hideRubricPoints: false, interactor: interactor)

        // Then
        XCTAssertEqual(viewModel.ratingViewModels.count, 2)
        XCTAssertEqual(viewModel.ratingViewModels.first?.ratingPointsLowerBound, 0)
        XCTAssertEqual(viewModel.ratingViewModels.last?.ratingPointsLowerBound, 5)
    }

    // MARK: - State Update Tests

    func test_updateUserValues_updatesPublishedProperties() {
        let criterion = CDRubricCriterion.save(.make(id: "criterion1"), assignmentID: assignment.id, in: databaseClient)
        viewModel = RubricCriterionViewModel(criterion: criterion, isFreeFormCommentsEnabled: false, hideRubricPoints: false, interactor: interactor)

        let assessmentMap: APIRubricAssessmentMap = [
            "criterion1": .init(comments: "comment", points: 8.0, rating_id: "rating1")
        ]

        // When
        interactor.assessmentsSubject.send(assessmentMap)

        // Then
        XCTAssertEqual(viewModel.userComment, "comment")
        XCTAssertEqual(viewModel.userPoints, 8.0)
        XCTAssertEqual(viewModel.userRatingId, "rating1")
    }

    func test_showRubricRatings() {
        let criterion = CDRubricCriterion.save(.make(id: "criterion1"), assignmentID: assignment.id, in: databaseClient)

        // When
        viewModel = RubricCriterionViewModel(
            criterion: criterion,
            isFreeFormCommentsEnabled: false,
            hideRubricPoints: false,
            interactor: interactor
        )

        // Then
        XCTAssertTrue(viewModel.shouldShowRubricRatings)

        // When
        viewModel = RubricCriterionViewModel(
            criterion: criterion,
            isFreeFormCommentsEnabled: true,
            hideRubricPoints: false,
            interactor: interactor
        )

        // Then
        XCTAssertFalse(viewModel.shouldShowRubricRatings)
    }

    // MARK: - State Update Tests

    func test_saving() {
        let criterion = CDRubricCriterion.save(.make(id: "criterion1"), assignmentID: assignment.id, in: databaseClient)
        viewModel = RubricCriterionViewModel(criterion: criterion, isFreeFormCommentsEnabled: false, hideRubricPoints: false, interactor: interactor)

        // When
        interactor.isSaving.send(true)

        // Then
        XCTAssertTrue(viewModel.isSaving.value)

        // When
        interactor.isSaving.send(false)

        // Then
        XCTAssertFalse(viewModel.isSaving.value)
    }

    func test_textual_properties() {
        // Given
        let criterion = CDRubricCriterion
            .save(
                .make(
                    description: "short desc 111",
                    id: "criterion1",
                    long_description: "long desc 22",
                    points: 7.0
                ),
                assignmentID: assignment.id,
                in: databaseClient
            )

        // When
        viewModel = RubricCriterionViewModel(
            criterion: criterion,
            isFreeFormCommentsEnabled: false,
            hideRubricPoints: false,
            interactor: interactor
        )

        // Then
        XCTAssertEqual(viewModel.title, "short desc 111")
        XCTAssertEqual(viewModel.longDescription, "long desc 22")
        XCTAssertEqual(viewModel.pointsPossibleText, String.format(pts: 7.0))
        XCTAssertEqual(viewModel.pointsPossibleAccessibilityText, String.format(points: 7.0))
    }

    func test_update_calling() {
        // Given
        let criterion = CDRubricCriterion
            .save(
                .make(
                    description: "short desc 111",
                    id: "criterion345",
                    long_description: "long desc 22",
                    points: 7.0
                ),
                assignmentID: assignment.id,
                in: databaseClient
            )

        viewModel = RubricCriterionViewModel(
            criterion: criterion,
            isFreeFormCommentsEnabled: false,
            hideRubricPoints: false,
            interactor: interactor
        )

        // When
        viewModel.updateComment("new comment 11")

        // Then
        XCTAssertEqual(interactor.updatedComment?.comment, "new comment 11")
        XCTAssertEqual(interactor.updatedComment?.criterionId, "criterion345")

        // When
        viewModel.updateCustomRating(4.5)

        // Then
        XCTAssertEqual(interactor.selectedRating?.criterionId, "criterion345")
        XCTAssertEqual(interactor.selectedRating?.points, 4.5)
    }
}
