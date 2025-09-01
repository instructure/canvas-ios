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

class RubricRatingViewModelTests: TeacherTestCase {

    // MARK: - Properties

    private var viewModel: RubricRatingViewModel!
    private var interactor: RubricGradingInteractorMock!
    private var cancellables = Set<AnyCancellable>()
    private var assignment: Assignment!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        interactor = RubricGradingInteractorMock()
        assignment = .make(from: .make())
    }

    override func tearDown() {
        viewModel = nil
        interactor = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_isSelected_whenRatingIdMatches() {
        interactor.assessmentsSubject.send(["criterion1": .init(rating_id: "rating1")])

        // When
        let rating = CDRubricRating.save(.make(id: "rating1"), assignmentID: assignment.id, in: databaseClient)
        viewModel = RubricRatingViewModel(rating: rating, criterionId: "criterion1", interactor: interactor)

        // Then
        XCTAssertTrue(viewModel.isSelected)
    }

    func test_init_isNotSelected_whenNoMatch() {
        interactor.assessmentsSubject.send(["criterion1": .init(rating_id: "rating2")])

        // When
        let rating = CDRubricRating.save(.make(id: "rating1"), assignmentID: assignment.id, in: databaseClient)
        viewModel = RubricRatingViewModel(rating: rating, criterionId: "criterion1", interactor: interactor)

        // Then
        XCTAssertFalse(viewModel.isSelected)
    }

    // MARK: - Logic Tests

    func test_matchPoints_strict() {
        let rating = CDRubricRating.save(.make(points: 10), assignmentID: assignment.id, in: databaseClient)
        viewModel = RubricRatingViewModel(rating: rating, criterionId: "criterion1", interactor: interactor)

        // Then
        XCTAssertTrue(viewModel.matchPoints(10, strict: true))
        XCTAssertFalse(viewModel.matchPoints(9.9, strict: true))
    }

    func test_matchPoints_ranged() {
        let rating = CDRubricRating.save(.make(points: 10), assignmentID: assignment.id, in: databaseClient)
        viewModel = RubricRatingViewModel(rating: rating, ratingPointsLowerBound: 5, criterionId: "criterion1", interactor: interactor)

        // Then
        XCTAssertTrue(viewModel.matchPoints(7))
        XCTAssertTrue(viewModel.matchPoints(10))
        XCTAssertFalse(viewModel.matchPoints(5))
        XCTAssertFalse(viewModel.matchPoints(10.1))
    }
}
