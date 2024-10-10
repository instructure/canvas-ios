//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class AssignmentPickerViewModelTests: CoreTestCase {
    private let mockService = MockAssignmentPickerListService()
    private var testee: AssignmentPickerViewModel!

    override func setUp() {
        super.setUp()
        testee = AssignmentPickerViewModel(service: mockService)
        testee.sharedFileExtensions.send(Set())
        environment.userDefaults?.reset()
    }

    func testAPIError() {
        mockService.mockResult = .failure("Custom error")
        testee.courseID = "failingID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error("Custom error"))
    }

    func testAssignmentFetchSuccessful() {
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload")
        ]))
    }

    func testGroupAssignmentFetchSuccessful() {
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: true)
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload", gradeAsGroup: true)
        ]))
    }

    func testAssignmentFetchSuccessfulButSharedFilesArentReady() {
        testee.sharedFileExtensions.send(nil)
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .loading)
    }

    func testSameCourseIdDoesntTriggerRefresh() {
        mockService.mockResult = .success([
            .init(id: "A1", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload")
        ]))

        mockService.mockResult = .failure("Custom error")
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload")
        ]))
    }

    func testDefaultAssignmentSelection() {
        environment.userDefaults?.submitAssignmentID = "A2"
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertEqual(testee.selectedAssignment, .init(id: "A2", name: "online upload"))
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload")
        ]))
        // Keep the assignment ID so if the user submits another attempt without starting the app we'll pre-select
        XCTAssertNotNil(environment.userDefaults?.submitAssignmentID)
    }

    func testCourseChangeRefreshesState() {
        mockService.mockResult = .success([
            .init(id: "A1", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload")
        ]))

        testee.assignmentSelected(.init(id: "A1", name: "online upload"))
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ])
        testee.courseID = "successID2"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload")
        ]))
    }

    func testPreviewInitializer() {
        let testee = AssignmentPickerViewModel(state: .loading)
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .loading)
    }

    func testDismissesViewDelayedAfterAssignmentSelection() {
        let viewDismissed = expectation(description: "View dismissed")
        var isDismissCalled = false
        let dismissSubscription = testee.dismissViewDidTrigger.sink {
            viewDismissed.fulfill()
            isDismissCalled = true
        }
        testee.assignmentSelected(.init(id: "", name: "", notAvailableReason: nil))
        XCTAssertFalse(isDismissCalled)
        waitForExpectations(timeout: 0.3)
        dismissSubscription.cancel()
    }

    func testPresentsIncompatibleFileDialog() {
        XCTAssertNil(testee.incompatibleFilesMessage)
        testee.assignmentSelected(.init(id: "", name: "", notAvailableReason: "error"))
        XCTAssertEqual(testee.incompatibleFilesMessage?.message, "error")
        XCTAssertNil(testee.selectedAssignment)
    }

    func testReportsAssignmentSelectionToAnalytics() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        XCTAssertEqual(analyticsHandler.totalEventCount, 0)

        testee.assignmentSelected(.init(id: "", name: ""))

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "assignment_selected")
        XCTAssertNil(analyticsHandler.lastEventParameters)
    }
}

class MockAssignmentPickerListService: AssignmentPickerListServiceProtocol {
    public private(set) lazy var result: AnyPublisher<APIResult, Never> = resultSubject.eraseToAnyPublisher()
    public var courseID: String? {
        didSet { resultSubject.send(mockResult ?? .failure("No mock result")) }
    }

    var mockResult: APIResult?
    private let resultSubject = PassthroughSubject<APIResult, Never>()
}
