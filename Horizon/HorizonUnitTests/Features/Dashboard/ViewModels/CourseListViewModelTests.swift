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
import SwiftUI

final class CourseListViewModelTests: HorizonTestCase {
    private var testee: CourseListViewModel!
    private var courses: [CourseCardModel]!

    override func setUp() {
        super.setUp()
        courses = [
            .init(course: .init(id: "1", name: "Course 1", progress: 100)), // Completed
            .init(course: .init(id: "2", name: "Course 2", progress: 50)),  // In Progress
            .init(course: .init(id: "3", name: "Course 3", progress: 0)),   // Not Started
            .init(course: .init(id: "4", name: "Course 4", progress: 100)), // Completed
            .init(course: .init(id: "5", name: "Course 5", progress: 20)),  // In Progress
            .init(course: .init(id: "6", name: "Course 6", progress: 0)),   // Not Started
            .init(course: .init(id: "7", name: "Course 7", progress: 100)), // Completed
            .init(course: .init(id: "8", name: "Course 8", progress: 80)),  // In Progress
            .init(course: .init(id: "9", name: "Course 9", progress: 0)),   // Not Started
            .init(course: .init(id: "10", name: "Course 10", progress: 90)), // In Progress
            .init(course: .init(id: "11", name: "Course 11", progress: 100)),// Completed
            .init(course: .init(id: "12", name: "Course 12", progress: 30)) // In Progress
        ]
    }

    override func tearDown() {
        testee = nil
        courses = nil
        super.tearDown()
    }
    func test_filter_byCompleted_showsCompletedCourses() {
        // Given
        createtestee(courses: courses)

        // When
        testee.filter(status: .completed)

        // Then
        XCTAssertEqual(testee.filteredCourses.count, 4)
        XCTAssertTrue(testee.filteredCourses.allSatisfy { $0.status == .completed })
    }

    func test_filter_byInProgress_showsInProgressCourses() {
        // Given
        createtestee(courses: courses)

        // When
        testee.filter(status: .inProgress)

        // Then
        XCTAssertEqual(testee.filteredCourses.count, 5)
        XCTAssertTrue(testee.filteredCourses.allSatisfy { $0.status == .inProgress })
    }

    func test_filter_byNotStarted_showsNotStartedCourses() {
        // Given
        createtestee(courses: courses)

        // When
        testee.filter(status: .notStarted)

        // Then
        XCTAssertEqual(testee.filteredCourses.count, 3)
        XCTAssertTrue(testee.filteredCourses.allSatisfy { $0.status == .notStarted })
    }

    func test_filter_byAll_showsAllCourses() {
        // Given
        createtestee(courses: courses)

        // When
        testee.filter(status: .inProgress) // Filter first
        testee.filter(status: .all) // Then select all

        // Then
        XCTAssertEqual(testee.filteredCourses.count, 10) // Paginated
    }

    func test_seeMoreButton_isVisibleWhenThereAreMorePages() {
        // Given
        createtestee(courses: courses) // 12 courses, 2 pages

        // Then
        XCTAssertTrue(testee.isSeeMoreButtonVisible)
    }

    func test_seeMoreButton_isHiddenWhenThereIsOnlyOnePage() {
        // Given
        createtestee(courses: Array(courses.prefix(5))) // 5 courses, 1 page

        // Then
        XCTAssertFalse(testee.isSeeMoreButtonVisible)
    }

    func test_seeMore_loadsNextPage() {
        // Given
        createtestee(courses: courses) // 12 courses, 2 pages
        XCTAssertEqual(testee.filteredCourses.count, 10)

        // When
        testee.seeMore()

        // Then
        XCTAssertEqual(testee.filteredCourses.count, 12)
        XCTAssertFalse(testee.isSeeMoreButtonVisible)
    }

    func test_navigateToCourseDetails_callsRouter() {
        // Given
        createtestee(courses: courses)
        let courseToNavigate = courses[0]
        let viewController = WeakViewController(UIViewController())
        // When
        testee.navigateToCourseDetails(course: courseToNavigate, viewController: viewController)

        // Then
        wait(for: [router.showExpectation], timeout: 1)
        let messageDetailsVC = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(messageDetailsVC)
    }

    func test_navigateProgram_callsOnTapProgram() {
        // Given
        createtestee(courses: courses)
        let viewController = WeakViewController(UIViewController())
        // When
        testee.navigateProgram(id: "program1", viewController: viewController)

        // Then
        let programDetails = router.lastViewController as? CoreHostingController<ProgramDetailsView>
        XCTAssertNotNil(programDetails)
    }
}

extension CourseListViewModelTests {
    private func createtestee(courses: [CourseCardModel]) {
        testee = CourseListViewModel(
            courses: courses,
            router: router
        )
    }
}
