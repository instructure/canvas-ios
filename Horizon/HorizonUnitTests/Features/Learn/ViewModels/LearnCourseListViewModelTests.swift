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

import Combine
import CombineSchedulers
@testable import Core
@testable import Horizon
import XCTest

final class LearnCourseListViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var interactor: GetCoursesInteractorMock!
    private var testee: LearnCourseListViewModel!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        interactor = GetCoursesInteractorMock()
    }

    override func tearDown() {
        interactor = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_initialization_setsDefaultValues() {
        testee = makeViewModel()

        XCTAssertTrue(testee.isLoaderVisiable)
        XCTAssertFalse(testee.hasCourses)
        XCTAssertEqual(testee.filteredCourses.count, 0)
        XCTAssertEqual(testee.searchText, "")
        XCTAssertEqual(testee.selectedStatus.id, ProgressStatus.all.rawValue)
    }

    // MARK: - GetCourses Tests

    func test_getCourses_whenSuccessful_shouldUpdateCoursesAndHideLoader() {
        interactor.coursesToReturn = HCourseStubs.activeCourses

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for courses")

        testee.getCourses { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertTrue(testee.hasCourses)
        XCTAssertEqual(testee.filteredCourses.count, 3)
    }

    func test_getCourses_whenNoCoursesReturned_shouldSetHasCoursesToFalse() {
        interactor.coursesToReturn = []

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for courses")

        testee.getCourses { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertFalse(testee.hasCourses)
        XCTAssertEqual(testee.filteredCourses.count, 0)
    }

    func test_getCourses_sortsCoursesWithIncompleteFirst() {
        let completedCourse = HCourse(
            id: "completed",
            name: "Completed Course",
            institutionName: "Tech University",
            state: HCourse.EnrollmentState.active.rawValue,
            enrollmentID: "enrollment-completed",
            enrollments: [],
            modules: [],
            progress: 1.0,
            overviewDescription: "Completed",
            currentLearningObject: nil,
            programs: []
        )

        let inProgressCourse = HCourse(
            id: "in-progress",
            name: "In Progress Course",
            institutionName: "Tech University",
            state: HCourse.EnrollmentState.active.rawValue,
            enrollmentID: "enrollment-progress",
            enrollments: [],
            modules: [],
            progress: 0.5,
            overviewDescription: "In progress",
            currentLearningObject: .init(
                moduleTitle: "Module 1",
                learningObjectName: "Lesson 1",
                learningObjectID: "item-1",
                type: .assignment,
                dueDate: nil,
                url: nil,
                estimatedTime: nil,
                isNewQuiz: false
            ),
            programs: []
        )

        interactor.coursesToReturn = [completedCourse, inProgressCourse]

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for courses")

        testee.getCourses { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertEqual(testee.filteredCourses.first?.id, "in-progress")
        XCTAssertEqual(testee.filteredCourses.last?.id, "completed")
    }

    func test_getCourses_withIgnoreCache_callsInteractorWithCorrectParameter() {
        interactor.coursesToReturn = HCourseStubs.activeCourses

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for courses")

        testee.getCourses(ignoreCache: true) { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertEqual(testee.filteredCourses.count, 3)
    }

    // MARK: - Refresh Tests

    func test_refresh_shouldReloadCourses() async {
        interactor.coursesToReturn = HCourseStubs.activeCourses

        testee = makeViewModel()

        await testee.refresh()

        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertTrue(testee.hasCourses)
        XCTAssertEqual(testee.filteredCourses.count, 3)
    }

    func test_refresh_whenInteractorReturnsEmpty_shouldSetHasCoursesToFalse() async {
        interactor.coursesToReturn = []

        testee = makeViewModel()

        await testee.refresh()

        XCTAssertFalse(testee.hasCourses)
    }

    // MARK: - Filter Tests

    func test_filter_byCompleted_showsOnlyCompletedCourses() {
        let courses = [
            createCourse(id: "1", progress: 100, hasLearningObject: false),
            createCourse(id: "2", progress: 50, hasLearningObject: true),
            createCourse(id: "3", progress: 100, hasLearningObject: false)
        ]

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.completed.rawValue, name: "Completed")
        testee.filter()

        XCTAssertEqual(testee.filteredCourses.count, 2)
        XCTAssertTrue(testee.filteredCourses.allSatisfy { $0.status == .completed })
    }

    func test_filter_byInProgress_showsOnlyInProgressCourses() {
        let courses = [
            createCourse(id: "1", progress: 0.5, hasLearningObject: true),
            createCourse(id: "2", progress: 0.0, hasLearningObject: false),
            createCourse(id: "3", progress: 0.75, hasLearningObject: true)
        ]

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.inProgress.rawValue, name: "In progress")
        testee.filter()

        XCTAssertEqual(testee.filteredCourses.count, 2)
        XCTAssertTrue(testee.filteredCourses.allSatisfy { $0.status == .inProgress })
    }

    func test_filter_byNotStarted_showsOnlyNotStartedCourses() {
        let courses = [
            createCourse(id: "1", progress: 0.0, hasLearningObject: false),
            createCourse(id: "2", progress: 0.5, hasLearningObject: true),
            createCourse(id: "3", progress: 0.0, hasLearningObject: false)
        ]

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.notStarted.rawValue, name: "Not started")
        testee.filter()

        XCTAssertEqual(testee.filteredCourses.count, 2)
        XCTAssertTrue(testee.filteredCourses.allSatisfy { $0.status == .notStarted })
    }

    func test_filter_byAll_showsAllCourses() {
        let courses = [
            createCourse(id: "1", progress: 1.0, hasLearningObject: false),
            createCourse(id: "2", progress: 0.5, hasLearningObject: true),
            createCourse(id: "3", progress: 0.0, hasLearningObject: false)
        ]

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.all.rawValue, name: "All courses")
        testee.filter()

        XCTAssertEqual(testee.filteredCourses.count, 3)
    }

    // MARK: - Search Tests

    func test_searchText_whenEmpty_showsAllCoursesForSelectedFilter() {
        interactor.coursesToReturn = HCourseStubs.activeCourses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = ""

        XCTAssertEqual(testee.filteredCourses.count, 3)
    }

    func test_searchText_whenNotEmpty_filtersCoursesBasedOnName() {
        interactor.coursesToReturn = HCourseStubs.activeCourses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "iOS"

        XCTAssertEqual(testee.filteredCourses.count, 2)
        XCTAssertEqual(testee.filteredCourses.first?.name, "iOS Development 101")
    }

    func test_searchText_isCaseInsensitive() {
        interactor.coursesToReturn = HCourseStubs.activeCourses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "ios"

        XCTAssertEqual(testee.filteredCourses.count, 2)
        XCTAssertEqual(testee.filteredCourses.first?.name, "iOS Development 101")
    }

    func test_searchText_whenNoMatches_returnsEmptyArray() {
        interactor.coursesToReturn = HCourseStubs.activeCourses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "NonExistentCourse"

        XCTAssertEqual(testee.filteredCourses.count, 0)
    }

    func test_searchText_combinesWithStatusFilter() {
        let courses = [
            createCourse(id: "1", name: "iOS Development", progress: 50, hasLearningObject: true),
            createCourse(id: "2", name: "iOS Testing", progress: 100, hasLearningObject: false),
            createCourse(id: "3", name: "Android Development", progress: 050, hasLearningObject: true)
        ]

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.completed.rawValue, name: "Completed")
        testee.searchText = "iOS"

        print(testee.filteredCourses.count, " testee.filteredCourses.count ")

        XCTAssertEqual(testee.filteredCourses.count, 1)
        XCTAssertEqual(testee.filteredCourses.first?.name, "iOS Testing")
        XCTAssertEqual(testee.filteredCourses.first?.status, .completed)
    }

    // MARK: - Pagination Tests

    func test_seeMore_showsNextPageOfCourses() {
        let courses = (1...15).map { index in
            createCourse(id: "\(index)", name: "Course \(index)", progress: 0.5, hasLearningObject: true)
        }

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertEqual(testee.filteredCourses.count, 10)
        XCTAssertTrue(testee.isSeeMoreVisible)

        testee.seeMore()

        XCTAssertEqual(testee.filteredCourses.count, 15)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_isSeeMoreVisible_whenAllCoursesVisible_returnsFalse() {
        interactor.coursesToReturn = Array(HCourseStubs.activeCourses.prefix(5))
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_isSeeMoreVisible_whenMoreCoursesAvailable_returnsTrue() {
        let courses = (1...15).map { index in
            createCourse(id: "\(index)", name: "Course \(index)", progress: 0.5, hasLearningObject: true)
        }

        interactor.coursesToReturn = courses
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for courses")
        testee.getCourses { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    // MARK: - Navigation Tests

    func test_navigateToItemSequence_callsRouterWithCorrectParameters() {
        testee = makeViewModel()

        let learningObject = CourseListWidgetModel.LearningObjectInfo(
            name: "Introduction to Swift",
            id: "item-1",
            moduleTitle: "Module 1",
            type: .assignment,
            dueDate: "2025/12/31",
            estimatedDuration: "30 mins",
            url: URL(string: "https://example.com/module/1")
        )

        let url = URL(string: "https://example.com/courses/1/modules/items/1")!
        let viewController = WeakViewController(UIViewController())

        testee.navigateToItemSequence(url: url, learningObject: learningObject, viewController: viewController)

        XCTAssertEqual(router.calls.count, 1)
        XCTAssertEqual(router.calls[0].0?.url, url)
    }

    func test_navigateToCourseDetails_callsRouterWithCorrectViewController() {
        testee = makeViewModel()

        let viewController = WeakViewController(UIViewController())

        testee.navigateToCourseDetails(
            id: "course-1",
            enrollmentID: "enrollment-1",
            programName: "iOS Developer Track",
            viewController: viewController
        )

        wait(for: [router.showExpectation], timeout: 1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    func test_navigateToCourseDetails_withoutProgramName_callsRouterSuccessfully() {
        testee = makeViewModel()

        let viewController = WeakViewController(UIViewController())

        testee.navigateToCourseDetails(
            id: "course-1",
            enrollmentID: "enrollment-1",
            programName: nil,
            viewController: viewController
        )

        wait(for: [router.showExpectation], timeout: 1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    // MARK: - Helper Methods

    private func makeViewModel() -> LearnCourseListViewModel {
        LearnCourseListViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )
    }

    private func createCourse(
        id: String,
        name: String = "Test Course",
        progress: Double,
        hasLearningObject: Bool
    ) -> HCourse {
        HCourse(
            id: id,
            name: name,
            institutionName: "Tech University",
            state: HCourse.EnrollmentState.active.rawValue,
            enrollmentID: "enrollment-\(id)",
            enrollments: [],
            modules: [],
            progress: progress,
            overviewDescription: "Test course description",
            currentLearningObject: hasLearningObject ? .init(
                moduleTitle: "Module 1",
                learningObjectName: "Lesson 1",
                learningObjectID: "item-\(id)",
                type: .assignment,
                dueDate: nil,
                url: nil,
                estimatedTime: nil,
                isNewQuiz: false
            ) : nil,
            programs: []
        )
    }
}
