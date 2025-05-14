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

@testable import Core
import Combine
import SwiftUI
import XCTest

class SubmitAssignmentExtensionViewModelTests: CoreTestCase {
    private var testee: SubmitAssignmentExtensionViewModel!
    private var uiRefreshExpectation: XCTestExpectation!
    private var uiRefreshSubscription: AnyCancellable!
    private var isShareCompletebBlockExecuted: Bool = false

    override func setUp() {
        super.setUp()
        isShareCompletebBlockExecuted = false
        testee = SubmitAssignmentExtensionViewModel(attachmentCopyService: AttachmentCopyService(extensionContext: nil),
                                                    submissionService: AttachmentSubmissionService(submissionAssembly: .makeShareExtensionAssembly()),
                                                    shareCompleted: { [weak self] in self?.isShareCompletebBlockExecuted = true })
    }

    func testInitialState() {
        XCTAssertEqual(testee.selectCourseButtonTitle, Text("Select course", bundle: .core))
        XCTAssertEqual(testee.selectAssignmentButtonTitle, Text("Select assignment", bundle: .core))
        XCTAssertTrue(testee.comment.isEmpty)
        XCTAssertTrue(testee.isSubmitButtonDisabled)
        XCTAssertTrue(testee.isProcessingFiles)
        XCTAssertTrue(testee.previews.isEmpty)
    }

    func testCourseButtonTitleUpdates() {
        makeExpectation()
        testee.coursePickerViewModel.selectedCourse = .init(id: "1", name: "selected course")
        XCTAssertEqual(testee.selectCourseButtonTitle, Text(verbatim: "selected course"))

        wait(for: [uiRefreshExpectation], timeout: 1)
    }

    func testAssignmentButtonTitleUpdates() {
        makeExpectation()
        uiRefreshExpectation.expectedFulfillmentCount = 2 // assignment selector title update and submit button state update

        testee.assignmentPickerViewModel.assignmentSelected(.init(id: "1", name: "selected assignment"))
        XCTAssertEqual(testee.selectAssignmentButtonTitle, Text(verbatim: "selected assignment"))

        wait(for: [uiRefreshExpectation], timeout: 1)
    }

    func testAssignmentSelectionEnablesSubmitButton() {
        makeExpectation()
        uiRefreshExpectation.expectedFulfillmentCount = 2 // assignment selector title update and submit button state update

        testee.assignmentPickerViewModel.assignmentSelected(.init(id: "1", name: "selected assignment"))
        XCTAssertFalse(testee.isSubmitButtonDisabled)

        wait(for: [uiRefreshExpectation], timeout: 1)
    }

    func testCourseSelectionTriggersAssignmentListLoad() {
        testee.coursePickerViewModel.selectedCourse = .init(id: "randomID", name: "course")
        XCTAssertEqual(testee.assignmentPickerViewModel.courseID, "randomID")
    }

    func testCourseSwitchResetsSelectedAssignment() {
        testee.coursePickerViewModel.selectedCourse = .init(id: "random CourseID", name: "course")
        testee.assignmentPickerViewModel.assignmentSelected(.init(id: "random AssignmentID", name: "assignment"))

        testee.coursePickerViewModel.selectedCourse = .init(id: "random CourseID 2", name: "course 2")
        XCTAssertNil(testee.assignmentPickerViewModel.selectedAssignment)
        XCTAssertEqual(testee.selectAssignmentButtonTitle, Text("Select assignment", bundle: .core))
    }

    func testCancelTapInvokesShareCompletedBlock() {
        testee.cancelTapped()
        XCTAssertTrue(isShareCompletebBlockExecuted)
    }

    func testReportsCancelToAnalytics() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        XCTAssertEqual(analyticsHandler.totalEventCount, 0)

        testee.cancelTapped()

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "share_cancelled")
        XCTAssertNil(analyticsHandler.lastEventParameters)
    }

    func testReportsSubmitToAnalytics() {
        testee.coursePickerViewModel.selectedCourse = .init(id: "", name: "")
        testee.assignmentPickerViewModel.assignmentSelected(.init(id: "", name: ""))
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        XCTAssertEqual(analyticsHandler.totalEventCount, 0)

        testee.submitTapped()

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "submit_tapped")
        XCTAssertNil(analyticsHandler.lastEventParameters)
    }

    private func makeExpectation() {
        drainMainQueue() // To swallow initial UI update triggers
        uiRefreshExpectation = expectation(description: "UI refresh triggered")
        uiRefreshSubscription = testee.objectWillChange.sink { [weak self] _ in
            self?.uiRefreshExpectation.fulfill()
        }
    }
}
