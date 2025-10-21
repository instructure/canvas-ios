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

@testable import Horizon
@testable import Core
import XCTest
import Combine
import CombineSchedulers

final class CompletedWidgetViewModelTests: HorizonTestCase {

    func testSuccessMultipleCoursesDataState() {
        // Given
        let completedWidgetInteractor = CompletedWidgetInteractorMock(response: CompletedWidgetModelStub.listCompletedWidgetModels)
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = CompletedWidgetViewModel(
            interactor: completedWidgetInteractor,
            learnCoursesInteractor: learnCoursesInteractor,
            scheduler: .immediate
        )

        // When
        testee.getCountCompletedModules(ignoreCache: true)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.totalCount, 8)
    }

    func testEmptyResponseShowsEmptyState() {
        // Given
        let completedWidgetInteractor = CompletedWidgetInteractorMock(response: [])
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = CompletedWidgetViewModel(
            interactor: completedWidgetInteractor,
            learnCoursesInteractor: learnCoursesInteractor,
            scheduler: .immediate
        )

        // When
        testee.getCountCompletedModules(ignoreCache: true)

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.totalCount, .zero)
    }

    func testErrorStateWhenInteractorFails() {
        // Given

        let completedWidgetInteractor = CompletedWidgetInteractorMock(response: [], hasError: true)
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = CompletedWidgetViewModel(
            interactor: completedWidgetInteractor,
            learnCoursesInteractor: learnCoursesInteractor,
            scheduler: .immediate
        )

        // When
        testee.getCountCompletedModules(ignoreCache: true)

        // Then
        XCTAssertEqual(testee.state, .error)
        XCTAssertEqual(testee.totalCount, .zero)
    }
}
