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

@testable import Core
@testable import Horizon
import XCTest

final class LearnViewModelTests: HorizonTestCase {

    func testFeatchProgramsSuccessResponse() {
        // Given
        let interactor = ProgramInteractorMock()
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnCoursesInteractor,
            router: router,
            programID: "ID-1"
        )
        // When
        let expection = expectation(description: "Wait for completion")
        testee.fetchPrograms {
            expection.fulfill()
            XCTAssertTrue(testee.shouldShowProgress)
            XCTAssertEqual(testee.currentProgram?.id, HProgramStubs.programs.first?.id)
            XCTAssertFalse(testee.isLoaderVisible)
            XCTAssertFalse(testee.hasError)

            XCTAssertEqual(testee.currentProgram?.courses[0].index, 1)
            XCTAssertEqual(testee.currentProgram?.courses[1].index, 2)
            XCTAssertEqual(testee.currentProgram?.courses[2].index, 0)

        }
        // Then
        wait(for: [expection], timeout: 0.2)
    }

    func testFeatchProgramsFailureResponse() {
        // Given
        let interactor = ProgramInteractorMock()
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        interactor.shouldFail = true
        let testee = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnCoursesInteractor,
            router: router,
            programID: "12"
        )
        // When
        let expection = expectation(description: "Wait for completion")
        testee.fetchPrograms {
            expection.fulfill()
            XCTAssertNil(testee.currentProgram)
            XCTAssertFalse(testee.isLoaderVisible)
            XCTAssertTrue(testee.hasError)
            XCTAssertTrue(testee.toastIsPresented)

        }
        // Then
        wait(for: [expection], timeout: 0.2)
    }

    func testNavigateToCourseDetails() {
        // Given
        let interactor = ProgramInteractorMock()
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnCoursesInteractor,
            router: router,
            programID: "ID-1",
            scheduler: .immediate
        )
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.fetchPrograms()
        testee.navigateToCourseDetails(
            courseID: "ID-1",
            isEnrolled: true,
            viewController: viewController
        )
        // Then
        let courseDetailsView = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(courseDetailsView)
        wait(for: [router.showExpectation], timeout: 1)
    }

    func testEnrollInProgramSuccessResponse() {
        // Given
        let interactor = ProgramInteractorMock()
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnCoursesInteractor,
            router: router,
            programID: "12",
            scheduler: .immediate
        )

        // When
        testee.enrollInProgram(course: HProgramStubs.courses[0])
        // Then
        XCTAssertEqual(testee.toastMessage, "You’ve been enrolled in Course Introduction to SwiftUI")
        XCTAssertTrue(testee.toastIsPresented)
        XCTAssertFalse(testee.isLoadingEnrollButton)
    }

    func testEnrollInProgramFailureResponse() {
        // Given
        let interactor = ProgramInteractorMock()
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        interactor.shouldFail = true
        let testee = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnCoursesInteractor,
            router: router,
            programID: "12",
            scheduler: .immediate
        )

        // When
        testee.enrollInProgram(course: HProgramStubs.courses[0])
        // Then
        XCTAssertNotEqual(testee.toastMessage, "You’ve been enrolled in Course Introduction to SwiftUI")
        XCTAssertTrue(testee.toastIsPresented)
        XCTAssertFalse(testee.isLoadingEnrollButton)
        XCTAssertTrue(testee.hasError)
    }

    func testConfigureSelectionProgram() async {
        // Given
        let interactor = ProgramInteractorMock()
        let learnCoursesInteractor = GetLearnCoursesInteractorMock()
        let testee = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: learnCoursesInteractor,
            router: router,
            programID: "ID-1"
        )

        // When
        await testee.refreshPrograms()

        XCTAssertEqual(testee.currentProgram?.id, HProgramStubs.programs.first!.id)
    }
}
