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

        let assessment: APIRubricAssessmentMap = ["criterion1": .init(comments: "comment", points: 8.0, rating_id: "rating1")]
        let commentExp = XCTestExpectation(description: "userComment should update")
        let pointsExp = XCTestExpectation(description: "userPoints should update")
        let ratingIdExp = XCTestExpectation(description: "userRatingId should update")

        viewModel.$userComment
            .dropFirst()
            .sink {
                if $0 == "comment" {
                    commentExp.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$userPoints
            .dropFirst()
            .sink {
                if $0 == 8.0 {
                    pointsExp.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$userRatingId
            .dropFirst()
            .sink {
                if $0 == "rating1" {
                    ratingIdExp.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.updateUserValues(assessment)

        // Then
        wait(for: [commentExp, pointsExp, ratingIdExp], timeout: 1.0)
    }
}
