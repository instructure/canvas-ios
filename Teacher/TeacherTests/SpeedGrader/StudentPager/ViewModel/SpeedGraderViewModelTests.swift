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

import XCTest
import CoreData
import Combine
import Core
@testable import Teacher
import TestsFoundation

class SpeedGraderViewModelTests: TeacherTestCase {
    private var testee: SpeedGraderViewModel!
    private var interactorMock: SpeedGraderInteractorMock!

    override func setUp() {
        super.setUp()
        interactorMock = SpeedGraderInteractorMock()
        testee = SpeedGraderViewModel(interactor: interactorMock, environment: environment)
    }

    override func tearDown() {
        testee = nil
        interactorMock = nil
        super.tearDown()
    }

    // MARK: - Outputs

    func test_interactorState_mapsToViewModelStateState() {
        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.isPostPolicyButtonVisible, false)

        interactorMock.state.send(.data)
        XCTAssertSingleOutputEquals(testee.$state.filter { $0 != .loading }, .data(loadingOverlay: false))
        XCTAssertEqual(testee.isPostPolicyButtonVisible, true)

        interactorMock.state.send(.error(.submissionNotFound))
        XCTAssertSingleOutputEquals(testee.$state.filter { $0 != .data(loadingOverlay: false) }, .empty)
        XCTAssertEqual(testee.isPostPolicyButtonVisible, false)
    }

    func test_interactorContextInfo_mapsToViewModelContextInfo() {
        let contextInfo = SpeedGraderContextInfo(
            courseName: "Test Assignment",
            courseColor: .red,
            assignmentName: "Test Course"
        )

        // WHEN
        interactorMock.contextInfo.send(contextInfo)

        XCTAssertEqual(testee.navigationTitle, contextInfo.assignmentName)
        XCTAssertEqual(testee.navigationSubtitle, contextInfo.courseName)
        XCTAssertEqual(testee.navigationBarColor, .red)
    }

    func test_interactorData_mapsToViewModelData() {
        let pagesController = PagesViewController()
        interactorMock.mockData(viewContext: databaseClient)
        interactorMock.state.send(.data)
        XCTAssertEqual(interactorMock.isLoadCalled, true)

        // WHEN
        testee.didShowPagesViewController.send(pagesController)

        // THEN
        XCTAssertTrue(pagesController.children.allSatisfy { $0 is CoreHostingController<SubmissionGraderView> })
    }

    // MARK: - User Actions

    func test_didTapPostPolicyButton() {
        // WHEN
        testee.didTapPostPolicyButton.send(WeakViewController())

        // THEN
        let expectedRoute = "/\(interactorMock.context.pathComponent)/assignments/\(interactorMock.assignmentID)/post_policy"
        XCTAssertEqual(router.lastRoutedTo(expectedRoute, withOptions: .modal(embedInNav: true, addDoneButton: true)), true)
    }

    func test_didTapDoneButton() {
        let controller = UIViewController()

        // WHEN
        testee.didTapDoneButton.send(WeakViewController(controller))

        // THEN
        wait(for: [router.dismissExpectation])
        XCTAssertEqual(router.dismissed, controller)
    }
}

private class SpeedGraderInteractorMock: SpeedGraderInteractor {
    var state = CurrentValueSubject<SpeedGraderInteractorState, Never>(.loading)
    var data: SpeedGraderData?
    var contextInfo = CurrentValueSubject<SpeedGraderContextInfo?, Never>(nil)

    var assignmentID: String = "assignmentID"
    var userID: String = "userID"
    var context: Context = .course("courseID")

    private(set) var isLoadCalled = false

    func load() {
        isLoadCalled = true
    }

    func refreshSubmission(forUserId: String) {
        // Mock implementation for refreshing submission
    }

    func mockData(viewContext: NSManagedObjectContext) {
        let assignment = Assignment.save(.make(), in: viewContext, updateSubmission: false, updateScoreStatistics: false)
        let submission = Submission.save(.make(), in: viewContext)

        data = SpeedGraderData(
            assignment: assignment,
            submissions: [submission],
            focusedSubmissionIndex: 0
        )
    }
}
