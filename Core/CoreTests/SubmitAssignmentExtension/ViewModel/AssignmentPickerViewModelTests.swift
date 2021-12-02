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
import XCTest

class AssignmentPickerViewModelTests: CoreTestCase {
    private var testee: AssignmentPickerViewModel!

    override func setUp() {
        super.setUp()
        testee = AssignmentPickerViewModel()
    }

    func testUnknownAPIError() {
        testee.courseID = "failingID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error("Something went wrong"))
    }

    func testAPIError() {
        api.mock(GetAssignmentsRequest(courseID: "failingID", perPage: 100), data: nil, response: nil, error: NSError.instructureError("Custom error"))
        testee.courseID = "failingID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error("Custom error"))
    }

    func testAssignmentFetchSuccessful() {
        api.mock(GetAssignmentsRequest(courseID: "successID", perPage: 100), value: [
            APIAssignment.make(id: "A1", name: "unknown submission type"),
            APIAssignment.make(id: "A2", name: "online upload", submission_types: [.online_upload]),
            APIAssignment.make(id: "A3", locked_for_user: true, name: "online upload, locked", submission_types: [.online_upload]),
            APIAssignment.make(id: "A4", name: "external tool", submission_types: [.external_tool]),
        ])
        testee.courseID = "successID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload"),
        ]))
    }

    func testSameCourseIdDoesntTriggerRefresh() {
        api.mock(GetAssignmentsRequest(courseID: "successID", perPage: 100), value: [
            APIAssignment.make(id: "A1", name: "online upload", submission_types: [.online_upload]),
        ])
        testee.courseID = "successID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload"),
        ]))

        api.mock(GetAssignmentsRequest(courseID: "failingID", perPage: 100), data: nil, response: nil, error: NSError.instructureError("Custom error"))
        testee.courseID = "successID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload"),
        ]))
    }

    func testDefaultAssignmentSelection() {
        environment.userDefaults?.submitAssignmentID = "A2"
        api.mock(GetAssignmentsRequest(courseID: "successID", perPage: 100), value: [
            APIAssignment.make(id: "A2", name: "online upload", submission_types: [.online_upload]),
        ])
        testee.courseID = "successID"
        XCTAssertEqual(testee.selectedAssignment, .init(id: "A2", name: "online upload"))
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload"),
        ]))
        XCTAssertNil(environment.userDefaults?.submitAssignmentID)
    }

    func testCourseChangeRefreshesState() {
        api.mock(GetAssignmentsRequest(courseID: "successID", perPage: 100), value: [
            APIAssignment.make(id: "A1", name: "online upload", submission_types: [.online_upload]),
        ])
        testee.courseID = "successID"
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload"),
        ]))

        testee.selectedAssignment = .init(id: "A1", name: "online upload")
        api.mock(GetAssignmentsRequest(courseID: "successID2", perPage: 100), value: [
            APIAssignment.make(id: "A2", name: "online upload", submission_types: [.online_upload]),
        ])
        testee.courseID = "successID2"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload"),
        ]))
    }

    func testPreviewInitializer() {
        let testee = AssignmentPickerViewModel(state: .loading)
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .loading)
    }
}
