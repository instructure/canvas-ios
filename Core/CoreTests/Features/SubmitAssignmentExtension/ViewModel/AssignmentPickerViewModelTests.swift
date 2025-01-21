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
        mockService.mockResult = .failure(.failedToGetAssignments)
        testee.courseID = "failingID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error(AssignmentPickerListServiceError.failedToGetAssignments.localizedDescription))
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

    func testGroupAssignmentPageFetchingSuccessful() {
        let firstItem: APIAssignmentPickerListItem = .init(
            id: "A1", name: "online upload", allowedExtensions: [], gradeAsGroup: true
        )

        mockService.mockResult = .success([firstItem])
        testee.courseID = "successID"
        drainMainQueue()

        let firstExpected = [AssignmentPickerItem(apiItem: firstItem, sharedFileExtensions: [])]
        XCTAssertEqual(testee.state, .data(firstExpected))

        let nextPageList: [APIAssignmentPickerListItem] = [
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: true),
            .init(id: "A3", name: "online upload", allowedExtensions: [], gradeAsGroup: true)
        ]

        mockService.mockPageInfo = APIPageInfo(endCursor: "next_cursor", hasNextPage: true)
        mockService.mockNextPageResult = .success(nextPageList)

        testee.loadNextPage()
        drainMainQueue()

        let lastExpected = firstExpected + nextPageList.map { AssignmentPickerItem(apiItem: $0, sharedFileExtensions: []) }
        XCTAssertEqual(testee.endCursor, "next_cursor")
        XCTAssertEqual(testee.state, .data(lastExpected))
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

        mockService.mockResult = .failure(.failedToGetAssignments)
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
        didSet { resultSubject.send(mockResult ?? .failure(.failedToGetAssignments)) }
    }

    var mockResult: APIResult?
    private let resultSubject = CurrentValueSubject<APIResult, Never>(.success([]))

    var mockPageInfo: APIPageInfo?
    var mockNextPageResult: APIResult?

    private let endCursorSubject = CurrentValueSubject<String?, Never>(nil)
    public private(set) lazy var endCursor: AnyPublisher<String?, Never> = endCursorSubject.eraseToAnyPublisher()

    func loadNextPage(completion: PageLoadingCompletion?) {
        let nextResult = mockNextPageResult ?? .failure(.failedToGetAssignments)

        switch nextResult {
        case .success(let list):
            let newList = (resultSubject.value.value ?? []) + list
            resultSubject.send(.success(newList))
            endCursorSubject.send(mockPageInfo?.nextCursor)
        case .failure(let error):
            print(error)
        }

        completion?()
    }
}
