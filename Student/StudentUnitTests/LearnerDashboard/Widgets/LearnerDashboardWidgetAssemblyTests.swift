//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import TestsFoundation
@testable import Core
@testable import Student

final class LearnerDashboardWidgetAssemblyTests: StudentTestCase {

    // MARK: - CoursesInteractor caching

    func test_makeCoursesInteractor_shouldReuseSameInstance() {
        let interactor1 = LearnerDashboardWidgetAssembly.makeCoursesInteractor()
        let interactor2 = LearnerDashboardWidgetAssembly.makeCoursesInteractor()

        XCTAssertTrue(interactor1 === interactor2)
    }

    func test_makeCoursesInteractor_afterDeallocation_shouldCreateNewInstance() {
        var interactor1: CoursesInteractorLive? = LearnerDashboardWidgetAssembly.makeCoursesInteractor()
        weak let weakInteractor1 = interactor1

        interactor1 = nil

        XCTAssertNil(weakInteractor1)

        let interactor2 = LearnerDashboardWidgetAssembly.makeCoursesInteractor()

        XCTAssertNotNil(interactor2)
    }

    func test_makeCoursesInteractor_withConcurrentAccess_shouldReuseSameInstance() {
        let expectation = expectation(description: "All tasks complete")
        expectation.expectedFulfillmentCount = 5

        var interactors: [CoursesInteractorLive?] = Array(repeating: nil, count: 5)

        DispatchQueue.concurrentPerform(iterations: 5) { index in
            interactors[index] = LearnerDashboardWidgetAssembly.makeCoursesInteractor()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        let firstInteractor = interactors[0]
        XCTAssertTrue(interactors.allSatisfy { $0 === firstInteractor })
    }
}
