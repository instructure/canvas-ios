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

class RubricsViewModelTests: TeacherTestCase {

    // MARK: - Properties

    private var viewModel: RedesignedRubricsViewModel!
    private var interactor: RubricGradingInteractorMock!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        interactor = RubricGradingInteractorMock()
    }

    override func tearDown() {
        viewModel = nil
        interactor = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_createsCriterionViewModels() {
        let apiAssignment = APIAssignment.make(rubric: [.make(id: "rubric1"), .make(id: "rubric2")])
        viewModel = RedesignedRubricsViewModel(assignment: .make(from: apiAssignment), submission: .make(), interactor: interactor, router: router)

        // Then
        XCTAssertEqual(viewModel.criterionViewModels.count, 2)
    }

    // MARK: - Combine Publisher Tests

    func test_isSaving_isBoundToInteractor() {
        viewModel = RedesignedRubricsViewModel(assignment: .make(), submission: .make(), interactor: interactor, router: router)
        let expectation = XCTestExpectation(description: "isSaving should update when interactor's isSaving updates")

        viewModel.$isSaving
            .dropFirst() // Ignore initial value
            .sink { isSaving in
                XCTAssertTrue(isSaving)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        interactor.isSaving.send(true)

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
