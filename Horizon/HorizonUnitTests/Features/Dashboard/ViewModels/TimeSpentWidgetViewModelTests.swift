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

import CombineSchedulers
@testable import Core
@testable import Horizon
import XCTest
import Combine

final class TimeSpentWidgetViewModelTests: HorizonTestCase {
    // MARK: - Tests

    func testInitializationSuccessMultipleFilteredCoursesAddsAllCoursesEntry() {
        // Given
        let times = [
            TimeSpentWidgetModel(id: "1", courseName: "Intro", minutesPerDay: 30),
            TimeSpentWidgetModel(id: "2", courseName: "Advanced", minutesPerDay: 90),
            TimeSpentWidgetModel(id: "3", courseName: "Other", minutesPerDay: 10)
        ]
        let learnCourses = [LearnCourse(id: "1", name: "Intro", enrollmentId: "e1"), LearnCourse(id: "2", name: "Advanced", enrollmentId: "e2")]

        // When
        let testee = makeViewModel(times: times, learnCourses: learnCourses)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertTrue(testee.isListCoursesVisiable)
        XCTAssertEqual(testee.courses.first?.id, "-1")
        XCTAssertEqual(testee.courses.count, 3) // all + 2 filtered
        XCTAssertEqual(testee.selectedCourse?.id, "-1")
    }

    func testInitializationSuccessSingleFilteredCourseNoAggregate() {
        // Given
        let times = [
            TimeSpentWidgetModel(id: "1", courseName: "Intro", minutesPerDay: 45),
            TimeSpentWidgetModel(id: "2", courseName: "Advanced", minutesPerDay: 90)
        ]
        let learnCourses = [LearnCourse(id: "1", name: "Intro", enrollmentId: "e1")] // Only id=1 matches

        // When
        let testee = makeViewModel(times: times, learnCourses: learnCourses)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertFalse(testee.isListCoursesVisiable)
        XCTAssertEqual(testee.courses.count, 1)
        XCTAssertEqual(testee.courses.first?.id, "1")
        XCTAssertEqual(testee.selectedCourse?.id, "1")
    }

    func testInitializationEmptySetsEmptyState() {
        // Given
        let testee = makeViewModel(times: [], learnCourses: [])

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertTrue(testee.courses.isEmpty)
        XCTAssertNil(testee.selectedCourse)
        XCTAssertNil(testee.courseDurationText)
        XCTAssertFalse(testee.isListCoursesVisiable)
    }

    func testInitializationFailureSetsErrorState() {
        // Given failing interactor
        let learnCourses: [LearnCourse] = [LearnCourse(id: "1", name: "Intro", enrollmentId: "e1")]
        let interactor = TimeSpentWidgetInteractorMock()
        interactor.shouldFail = true
        let learnInteractor = GetLearnCoursesInteractorLocalMock()
        learnInteractor.coursesToReturn = learnCourses

        let testee = TimeSpentWidgetViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnInteractor,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.state, .error)
        XCTAssertEqual(testee.courses, TimeSpentWidgetModel.loadingModels)
        XCTAssertEqual(testee.selectedCourse, TimeSpentWidgetModel.loadingModels.first)
    }

    func testGetTimeSpentIgnoreCachePropagatesFlag() {
        let interactor = TimeSpentWidgetInteractorMock()
        interactor.timesToReturn = [TimeSpentWidgetModel(id: "1", courseName: "Intro", minutesPerDay: 10)]
        let learnInteractor = GetLearnCoursesInteractorLocalMock()
        learnInteractor.coursesToReturn = [LearnCourse(id: "1", name: "Intro", enrollmentId: "e1")]
        let testee = TimeSpentWidgetViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnInteractor,
            scheduler: .immediate
        )

        testee.getTimeSpent(ignoreCache: true)
        XCTAssertEqual(interactor.lastIgnoreCache, true)
        testee.getTimeSpent(ignoreCache: false)
        XCTAssertEqual(interactor.lastIgnoreCache, false)
    }

    private func makeViewModel(
        times: [TimeSpentWidgetModel],
        learnCourses: [LearnCourse],
        shouldFail: Bool = false
    ) -> TimeSpentWidgetViewModel {
        let interactor = TimeSpentWidgetInteractorMock()
        interactor.timesToReturn = times
        interactor.shouldFail = shouldFail
        let learnInteractor = GetLearnCoursesInteractorLocalMock()
        learnInteractor.coursesToReturn = learnCourses
        return TimeSpentWidgetViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnInteractor,
            scheduler: .immediate
        )
    }
}

private final class GetLearnCoursesInteractorLocalMock: GetLearnCoursesInteractor {
    var coursesToReturn: [LearnCourse] = []
    var lastIgnoreCache: Bool?
    func getFirstCourse(ignoreCache: Bool) -> AnyPublisher<LearnCourse?, Error> {
        Just(coursesToReturn.first).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    func getCourses(ignoreCache: Bool) -> AnyPublisher<[LearnCourse], Never> {
        lastIgnoreCache = ignoreCache
        return Just(coursesToReturn).eraseToAnyPublisher()
    }
}
