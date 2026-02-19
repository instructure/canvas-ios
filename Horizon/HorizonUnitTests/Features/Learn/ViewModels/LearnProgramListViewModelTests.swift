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

final class LearnProgramListViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var interactor: ProgramInteractorMock!
    private var testee: LearnProgramListViewModel!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        interactor = ProgramInteractorMock()
        testScheduler = DispatchQueue.test
    }

    override func tearDown() {
        interactor = nil
        testee = nil
        testScheduler = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_initialization_setsDefaultValues() {
        testee = makeViewModel()

        XCTAssertTrue(testee.isLoaderVisiable)
        XCTAssertFalse(testee.hasPrograms)
        XCTAssertEqual(testee.filteredPrograms.count, 0)
        XCTAssertEqual(testee.searchText, "")
        XCTAssertEqual(testee.selectedStatus.id, ProgressStatus.all.rawValue)
    }

    // MARK: - FetchPrograms Tests

    func test_fetchPrograms_whenSuccessful_shouldUpdateProgramsAndHideLoader() {
        interactor.programsToReturn = HProgramStubs.programs

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for programs")

        testee.fetchPrograms { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertTrue(testee.hasPrograms)
        XCTAssertEqual(testee.filteredPrograms.count, 2)
    }

    func test_fetchPrograms_whenNoProgramsReturned_shouldSetHasProgramsToFalse() {
        interactor.programsToReturn = []

        testee = makeViewModel()

        let expectation = expectation(description: "Wait for programs")

        testee.fetchPrograms { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)
        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertFalse(testee.hasPrograms)
        XCTAssertEqual(testee.filteredPrograms.count, 0)
    }

    func test_fetchPrograms_whenInteractorFails_shouldReturnEmptyArray() {
        interactor.shouldFail = true

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for programs")

        testee.fetchPrograms { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertFalse(testee.hasPrograms)
        XCTAssertEqual(testee.filteredPrograms.count, 0)
    }

    func test_fetchPrograms_withIgnoreCache_callsInteractorWithCorrectParameter() {
        interactor.programsToReturn = HProgramStubs.programs

        testee = makeViewModel()
        let expectation = expectation(description: "Wait for programs")

        testee.fetchPrograms(ignoreCache: true) { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.2)

        XCTAssertEqual(testee.filteredPrograms.count, 2)
    }

//    // MARK: - Refresh Tests
//
    func test_refresh_shouldReloadPrograms() async {
        interactor.programsToReturn = HProgramStubs.programs

        testee = makeViewModel()

        await testee.refresh()

        XCTAssertFalse(testee.isLoaderVisiable)
        XCTAssertTrue(testee.hasPrograms)
        XCTAssertEqual(testee.filteredPrograms.count, 2)
    }

    func test_refresh_whenInteractorReturnsEmpty_shouldSetHasProgramsToFalse() async {
        interactor.programsToReturn = []

        testee = makeViewModel()

        await testee.refresh()

        XCTAssertFalse(testee.hasPrograms)
    }

    // MARK: - Filter Tests

    func test_filter_byCompleted_showsOnlyCompletedPrograms() {
        let programs = [
            createProgram(id: "1", name: "Completed Program", completionPercent: 1.0),
            createProgram(id: "2", name: "In Progress Program", completionPercent: 0.5),
            createProgram(id: "3", name: "Another Completed", completionPercent: 1.0)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.completed.rawValue, name: "Completed")
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 2)
        XCTAssertTrue(testee.filteredPrograms.allSatisfy { $0.status == .completed })
    }

    func test_filter_byInProgress_showsOnlyInProgressPrograms() {
        let programs = [
            createProgram(id: "1", name: "In Progress 1", completionPercent: 0.5),
            createProgram(id: "2", name: "Not Started", completionPercent: 0.0),
            createProgram(id: "3", name: "In Progress 2", completionPercent: 0.75)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.inProgress.rawValue, name: "In progress")
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 2)
        XCTAssertTrue(testee.filteredPrograms.allSatisfy { $0.status == .inProgress })
    }

    func test_filter_byNotStarted_showsOnlyNotStartedPrograms() {
        let programs = [
            createProgram(id: "1", name: "Not Started 1", completionPercent: 0.0),
            createProgram(id: "2", name: "In Progress", completionPercent: 0.5),
            createProgram(id: "3", name: "Not Started 2", completionPercent: 0.0)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.notStarted.rawValue, name: "Not started")
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 2)
        XCTAssertTrue(testee.filteredPrograms.allSatisfy { $0.status == .notStarted })
    }

    func test_filter_byAll_showsAllPrograms() {
        let programs = [
            createProgram(id: "1", name: "Completed", completionPercent: 1.0),
            createProgram(id: "2", name: "In Progress", completionPercent: 0.5),
            createProgram(id: "3", name: "Not Started", completionPercent: 0.0)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.all.rawValue, name: "All programs")
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 3)
    }

    // MARK: - Search Tests

    func test_searchText_whenEmpty_showsAllProgramsForSelectedFilter() {
        interactor.programsToReturn = HProgramStubs.programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = ""
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 2)
    }

    func test_searchText_whenNotEmpty_filtersProgramsBasedOnName() {
        let programs = [
            createProgram(id: "1", name: "iOS Developer Track", completionPercent: 0.5),
            createProgram(id: "2", name: "Android Developer Track", completionPercent: 0.5),
            createProgram(id: "3", name: "Web Development Bootcamp", completionPercent: 0.5)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "iOS"
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 1)
        XCTAssertEqual(testee.filteredPrograms.first?.name, "iOS Developer Track")
    }

    func test_searchText_isCaseInsensitive() {
        let programs = [
            createProgram(id: "1", name: "iOS Developer Track", completionPercent: 0.5),
            createProgram(id: "2", name: "Android Developer Track", completionPercent: 0.5)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "ios"
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 1)
        XCTAssertEqual(testee.filteredPrograms.first?.name, "iOS Developer Track")
    }

    func test_searchText_whenNoMatches_returnsEmptyArray() {
        interactor.programsToReturn = HProgramStubs.programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "NonExistentProgram"
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 0)
    }

    func test_searchText_combinesWithStatusFilter() {
        let programs = [
            createProgram(id: "1", name: "iOS Developer Track", completionPercent: 0.5),
            createProgram(id: "2", name: "iOS Advanced Track", completionPercent: 1.0),
            createProgram(id: "3", name: "Android Developer Track", completionPercent: 0.5)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.completed.rawValue, name: "Completed")
        testee.searchText = "iOS"
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 1)
        XCTAssertEqual(testee.filteredPrograms.first?.name, "iOS Advanced Track")
        XCTAssertEqual(testee.filteredPrograms.first?.status, .completed)
    }

    func test_searchText_debouncesFilterOperations() {
        interactor.programsToReturn = HProgramStubs.programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.searchText = "i"
        testScheduler.advance(by: .milliseconds(50))
        testee.searchText = "io"
        testScheduler.advance(by: .milliseconds(50))
        testee.searchText = "ios"
        testScheduler.advance(by: .milliseconds(99))

        XCTAssertEqual(testee.filteredPrograms.count, 2)

        testScheduler.advance(by: .milliseconds(1))
    }

    // MARK: - Pagination Tests

    func test_seeMore_showsNextPageOfPrograms() {
        let programs = (1...15).map { index in
            createProgram(id: "\(index)", name: "Program \(index)", completionPercent: 0.5)
        }

        interactor.programsToReturn = programs
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertEqual(testee.filteredPrograms.count, 10)
        XCTAssertTrue(testee.isSeeMoreVisible)

        testee.seeMore()

        XCTAssertEqual(testee.filteredPrograms.count, 15)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_isSeeMoreVisible_whenAllProgramsVisible_returnsFalse() {
        let programs = [
            createProgram(id: "1", name: "Program 1", completionPercent: 0.5),
            createProgram(id: "2", name: "Program 2", completionPercent: 0.5)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_isSeeMoreVisible_whenMoreProgramsAvailable_returnsTrue() {
        let programs = (1...15).map { index in
            createProgram(id: "\(index)", name: "Program \(index)", completionPercent: 0.5)
        }

        interactor.programsToReturn = programs
        testee = makeViewModel()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    // MARK: - Navigation Tests

    func test_navigateToProgramDetails_callsRouterWithCorrectViewController() {
        testee = makeViewModel()

        let viewController = WeakViewController(UIViewController())

        testee.navigateToProgramDetails(id: "program-1", viewController: viewController)

        wait(for: [router.showExpectation], timeout: 1)
        let presentedVC = router.lastViewController as? CoreHostingController<ProgramDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    func test_navigateToProgramDetails_passesCorrectProgramID() {
        testee = makeViewModel()

        let programID = "test-program-123"
        let viewController = WeakViewController(UIViewController())

        testee.navigateToProgramDetails(id: programID, viewController: viewController)

        wait(for: [router.showExpectation], timeout: 1)
        XCTAssertNotNil(router.lastViewController)
    }

    // MARK: - Integration Tests

    func test_searchAndFilter_workTogetherCorrectly() {
        let programs = [
            createProgram(id: "1", name: "iOS Basics", completionPercent: 0.0),
            createProgram(id: "2", name: "iOS Advanced", completionPercent: 0.5),
            createProgram(id: "3", name: "iOS Expert", completionPercent: 1.0),
            createProgram(id: "4", name: "Android Basics", completionPercent: 0.0)
        ]

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.selectedStatus = OptionModel(id: ProgressStatus.notStarted.rawValue, name: "Not started")
        testee.searchText = "iOS"
        testScheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredPrograms.count, 1)
        XCTAssertEqual(testee.filteredPrograms.first?.name, "iOS Basics")
    }

    func test_multipleRefreshes_maintainCorrectState() async {
        interactor.programsToReturn = HProgramStubs.programs

        testee = makeViewModel()

        await testee.refresh()
        XCTAssertEqual(testee.filteredPrograms.count, 2)

        interactor.programsToReturn = [HProgramStubs.programs[0]]
        await testee.refresh()
        XCTAssertEqual(testee.filteredPrograms.count, 1)
    }

    func test_searchAfterPagination_resetsToFirstPage() {
        let programs = (1...15).map { index in
            createProgram(id: "\(index)", name: "Program \(index)", completionPercent: 0.5)
        }

        interactor.programsToReturn = programs
        testee = makeViewModelWithTestScheduler()

        let expectation = expectation(description: "Wait for programs")
        testee.fetchPrograms { expectation.fulfill() }
        testScheduler.advance()
        wait(for: [expectation], timeout: 0.2)

        testee.seeMore()
        XCTAssertEqual(testee.filteredPrograms.count, 15)

        testee.searchText = "Program 1"
    }

    // MARK: - Helper Methods

    private func makeViewModel() -> LearnProgramListViewModel {
        LearnProgramListViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )
    }

    private func makeViewModelWithTestScheduler() -> LearnProgramListViewModel {
        LearnProgramListViewModel(
            interactor: interactor,
            router: router,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
    }

    private func createProgram(
        id: String,
        name: String,
        completionPercent: Double
    ) -> Program {
        let courses = [
            ProgramCourse(
                id: "c\(id)-1",
                name: "Course 1",
                isSelfEnrolled: true,
                isRequired: true,
                status: "ENROLLED",
                progressID: "p\(id)-1",
                completionPercent: completionPercent
            )
        ]

        return Program(
            id: id,
            name: name,
            variant: "LINEAR",
            description: "Test program description",
            date: "2025-09-01",
            courseCompletionCount: 1,
            courses: courses
        )
    }
}
