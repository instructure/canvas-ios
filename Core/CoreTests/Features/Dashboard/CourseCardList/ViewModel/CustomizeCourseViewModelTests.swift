//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
@testable import Core
import XCTest

class CustomizeCourseViewModelTests: CoreTestCase {
    private let colorsInteractor = CourseColorsInteractorLive()
    private var testee: CustomizeCourseViewModel!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        subscriptions.removeAll()
        testee = CustomizeCourseViewModel(
            courseId: "1",
            courseImage: .make(),
            courseColor: .course1,
            courseName: "Test Course",
            hideColorOverlay: true,
            courseColorsInteractor: colorsInteractor
        )
    }

    // MARK: - Tests

    func testInitialPropertiesMapped() {
        XCTAssertEqual(testee.isLoading, false)
        XCTAssertTrue(testee.colors.elementsEqual(colorsInteractor.colors) { color1, color2 in
            color1.key == color2.key && color1.value == color2.value
        })
        XCTAssertEqual(testee.courseImage, .make())
        XCTAssertEqual(testee.hideColorOverlay, true)
        XCTAssertEqual(testee.color, .course1)
        XCTAssertEqual(testee.courseName, "Test Course")
        XCTAssertEqual(testee.errorMessage, nil)
    }

    func testCheckmark() {
        XCTAssertEqual(testee.shouldShowCheckmark(for: .course1), true)
        XCTAssertEqual(testee.shouldShowCheckmark(for: .course2), false)
    }

    func testSuccessfulSave() {
        // GIVEN
        setupSuccessfulSaveTest()

        // WHEN
        testee.color = .course2
        testee.courseName = "Another Name"
        testee.didTapDone.send(())

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(testee.isLoading, true)
        XCTAssertEqual(testee.errorMessage, nil)
    }

    func testAPIIsNotCalledWhenNoDataChanged() {
        // GIVEN
        setupNoAPICallTest()

        // WHEN
        testee.didTapDone.send(())

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(testee.isLoading, true)
        XCTAssertEqual(testee.errorMessage, nil)
    }

    func testErrorState() {
        // GIVEN
        setupErrorStateTest()

        // WHEN
        testee.courseName = "Another Name"
        testee.didTapDone.send(())

        // THEN
        waitForExpectations(timeout: 1)
    }

    // MARK: - Private Helpers

    private func setupSuccessfulSaveTest() {
        _ = makeCourseNameAPICallExpectation()
        _ = makeCourseColorAPICallExpectation()
        _ = makeScreenDimissedExpectation()
        let movedToLoadingState = expectation(description: "movedToLoadingState")
        testee
            .$isLoading
            .sink { isLoading in
                if isLoading {
                    movedToLoadingState.fulfill()
                }
            }
            .store(in: &subscriptions)
    }

    private func setupNoAPICallTest() {
        let courseNameSentToAPI = makeCourseNameAPICallExpectation()
        courseNameSentToAPI.isInverted = true
        let courseColorSentToAPI = makeCourseColorAPICallExpectation()
        courseColorSentToAPI.isInverted = true
        _ = makeScreenDimissedExpectation()
        let movedToLoadingState = expectation(description: "movedToLoadingState")
        testee
            .$isLoading
            .dropFirst()
            .first()
            .sink { isLoading in
                if isLoading {
                    movedToLoadingState.fulfill()
                }
            }
            .store(in: &subscriptions)
    }

    private func setupErrorStateTest() {
        _ = makeCourseNameAPICallExpectation(error: .instructureError("Name upload error"))
        let courseColorSentToAPI = makeCourseColorAPICallExpectation()
        courseColorSentToAPI.isInverted = true
        let screenDismissed = makeScreenDimissedExpectation()
        screenDismissed.isInverted = true
        let loadingStateChanged = expectation(description: "loadingStateChanged")
        testee
            .$isLoading
            .dropFirst()
            .collect(2)
            .sink { loadingStates in
                XCTAssertEqual(loadingStates, [true, false])
                loadingStateChanged.fulfill()
            }
            .store(in: &subscriptions)
        let receivedError = expectation(description: "receivedError")
        testee
            .$errorMessage
            .dropFirst()
            .sink { errorMessage in
                receivedError.fulfill()
                XCTAssertEqual(errorMessage, .init(message: "Name upload error"))
            }
            .store(in: &subscriptions)

    }

    private func makeScreenDimissedExpectation() -> XCTestExpectation {
        let screenDismissed = expectation(description: "screenDismissed")
        testee
            .dismissView
            .sink {
                screenDismissed.fulfill()
            }
            .store(in: &subscriptions)
        return screenDismissed
    }

    private func makeCourseColorAPICallExpectation() -> XCTestExpectation {
        let courseColorSentToAPI = expectation(description: "courseColorSentToAPI")
        api.mock(
            UpdateCustomColor(
                context: .course("1"),
                color: UIColor.course2.variantForLightMode.hexString
            ).request) { _ in
                courseColorSentToAPI.fulfill()
                return (nil, nil, nil)
        }
        return courseColorSentToAPI
    }

    private func makeCourseNameAPICallExpectation(error: NSError? = nil) -> XCTestExpectation {
        let courseNameSentToAPI = expectation(description: "courseNameSentToAPI")
        api.mock(
            UpdateCourseNickname(
                courseID: "1",
                nickname: "Another Name"
            ).request) { _ in
                courseNameSentToAPI.fulfill()
                return (nil, nil, error)
        }
        return courseNameSentToAPI
    }
}
