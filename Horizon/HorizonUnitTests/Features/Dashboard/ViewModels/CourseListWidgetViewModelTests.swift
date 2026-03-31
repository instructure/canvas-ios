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

final class CourseListWidgetViewModelTests: HorizonTestCase {
    private var courseListWidgetInteractor: CourseListWidgetInteractorMock!
    private var programInteractor: ProgramInteractorMock!

    override func setUp() {
        super.setUp()
        courseListWidgetInteractor = CourseListWidgetInteractorMock()
        programInteractor = ProgramInteractorMock()
    }

    override func tearDown() {
        courseListWidgetInteractor = nil
        programInteractor = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationFetchesCourses() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.courses.count, 3)
    }

    // MARK: - Success Cases

    func testFetchCoursesSuccessWithActiveCourses() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.courses.count, 3)
        XCTAssertEqual(testee.courses[0].id, "course-1")
        XCTAssertEqual(testee.courses[0].name, "iOS Development 101")
        XCTAssertEqual(testee.courses[0].progress, 0.75)
        XCTAssertNotNil(testee.courses[0].currentLearningObject)
    }

    func testFetchCoursesSuccessWithEmptyResult() {
        // Given
        courseListWidgetInteractor.coursesToReturn = []

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.courses.count, 0)
    }

    func testFetchCoursesFiltersOnlyActiveCourses() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.mixedStateCourses

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.courses.count, 3)
        XCTAssertTrue(testee.courses.allSatisfy { $0.state == HCourse.EnrollmentState.active.rawValue })
    }

    func testFetchCoursesAttachesProgramsToCourses() {
        // Given
        let program = Program(
            id: "program-1",
            name: "iOS Developer Track",
            variant: "Full-Time",
            description: "Complete iOS development program",
            date: "2025-09-01",
            courseCompletionCount: 1,
            courses: [
                ProgramCourse(
                    id: "course-1",
                    isSelfEnrolled: true,
                    isRequired: true,
                    status: "ENROLLED",
                    progressID: "progress-1",
                    completionPercent: 75.0
                )
            ]
        )

        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        programInteractor.programsToReturn = [program]

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.courses.count, 3)
        XCTAssertEqual(testee.courses[0].programs.count, 1)
        XCTAssertEqual(testee.courses[0].programs[0].id, "program-1")
        XCTAssertEqual(testee.courses[1].programs.count, 0)
    }

    func testIsProgramWidgetVisibleHideWhileLoadig() {
        // Given
        let program = Program(
            id: "mock-program-id",
            name: "iOS Developer Track",
            variant: "Full-Time",
            description: "Complete iOS development program",
            date: "2025-09-01",
            courseCompletionCount: 1,
            courses: [
                ProgramCourse(
                    id: "course-1",
                    isSelfEnrolled: true,
                    isRequired: true,
                    status: "NOT-ENROLLED",
                    progressID: "progress-1",
                    completionPercent: 75.0
                )
            ]
        )

        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        programInteractor.programsToReturn = [program]

        // When
        let testee = createVM()

        // Then
        XCTAssertFalse(testee.isProgramWidgetVisible)
    }

    // MARK: - Error Cases

    func testFetchCoursesFailureShowsError() {
        // Given
        courseListWidgetInteractor.shouldFail = true

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .error)
    }

    func testFetchProgramsFailureShowsError() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        programInteractor.shouldFail = true

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .error)
    }

    // MARK: - Reload Tests

    func testReloadFetchesCoursesAgain() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        let testee = createVM()
        XCTAssertEqual(testee.courses.count, 3)

        // When
        courseListWidgetInteractor.coursesToReturn = [HCourseStubs.activeCourses[0]]

        // Then
        testee.reload(completion: nil)
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.courses.count, 1)
        XCTAssertEqual(testee.courses[0].id, "course-1")
    }

    // MARK: - Navigation Tests

    func testNavigateToItemSequence() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        let testee = createVM()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        let url = URL(string: "https://example.com/courses/1/modules/items/1")!
        let learningObject = HCourse.LearningObjectCard(
            moduleTitle: "Module 1",
            learningObjectName: "Assignment 1",
            learningObjectID: "item-1",
            type: .assignment,
            dueDate: nil,
            url: url,
            estimatedTime: "30 mins",
            isNewQuiz: false
        )

        // When
        testee.navigateToItemSequence(
            url: url,
            learningObject: learningObject,
            viewController: viewController
        )

        // Then
        XCTAssertEqual(router.calls.count, 1)
        XCTAssertEqual(router.calls[0].0?.url, url)
    }

    func testNavigateToCourseDetails() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        let testee = createVM()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateToCourseDetails(
            id: "course-1",
            enrollmentID: "enrollment-1",
            programName: "program-1",
            viewController: viewController
        )

        // Then
        let courseDetailsView = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(courseDetailsView)
    }

    func testNavigateToCourseDetailsWithoutProgramID() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        let testee = createVM()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateToCourseDetails(
            id: "course-1",
            enrollmentID: "enrollment-1",
            programName: nil,
            viewController: viewController
        )

        // Then
        let courseDetailsView = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(courseDetailsView)
    }

    func testNavigateProgram() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        let testee = createVM()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateProgram(id: "program-1", viewController: viewController)

        // Then
        let programDetails = router.lastViewController as? CoreHostingController<ProgramDetailsView>
        XCTAssertNotNil(programDetails)
    }

    func test_isExceededMaxCourses_whenCoursesCountIsLessThanMax() {
        // Given
        courseListWidgetInteractor.coursesToReturn = Array(HCourseStubs.activeCourses.prefix(2)) // 2 courses
        let testee = createVM()

        // Then
        XCTAssertFalse(testee.isExceededMaxCourses)
    }

    func test_isExceededMaxCourses_whenCoursesCountIsEqualToMax() {
        // Given
        courseListWidgetInteractor.coursesToReturn = Array(HCourseStubs.activeCourses.prefix(3)) // 3 courses
        let testee = createVM()

        // Then
        XCTAssertFalse(testee.isExceededMaxCourses)
    }

    func test_isExceededMaxCourses_whenCoursesCountIsGreaterThanMax() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses // 3 active courses
        let extraCourse = HCourse(id: "extra-course", name: "Extra Course", state: "active", enrollmentID: "extra-enrollment")
        courseListWidgetInteractor.coursesToReturn.append(extraCourse) // 4 courses
        let testee = createVM()

        // Then
        XCTAssertTrue(testee.isExceededMaxCourses)
    }

    func test_allowedCourse_returnsAllCoursesWhenLessThanMax() {
        // Given
        let courses = Array(HCourseStubs.activeCourses.prefix(2)) // 2 courses
        courseListWidgetInteractor.coursesToReturn = courses
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.allowedCourse.count, 2)
        XCTAssertEqual(testee.allowedCourse.map(\.id), courses.map(\.id))
    }

    func test_allowedCourse_returnsMaxCoursesWhenGreaterThanMax() {
        // Given
        let courses = HCourseStubs.activeCourses // 3 active courses
        let extraCourse = HCourse(id: "extra-course", name: "Extra Course", state: "active", enrollmentID: "extra-enrollment")
        courseListWidgetInteractor.coursesToReturn = courses + [extraCourse] // 4 courses
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.allowedCourse.count, 3)
        XCTAssertEqual(testee.allowedCourse.map(\.id), courses.map(\.id)) // Should only contain the first 3
    }

    func test_navigateToListCourse_callsRouterWithCorrectView() {
        // Given
        courseListWidgetInteractor.coursesToReturn = HCourseStubs.activeCourses
        let testee = createVM()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateToListCourse(viewController: viewController)

        // Then
        let presentedViewController = router.lastViewController as? CoreHostingController<CourseListView>
        XCTAssertNotNil(presentedViewController)
    }
    // MARK: - Helper Methods

    private func createVM() -> CourseListWidgetViewModel {
        CourseListWidgetViewModel(
            courseCardsInteractor: courseListWidgetInteractor,
            programInteractor: programInteractor,
            router: router,
            scheduler: .immediate
        )
    }
}
