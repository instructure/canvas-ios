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

@testable import Core
import XCTest
@testable import Student

final class APIPlannableParentAssignmentIdTests: XCTestCase {

    func test_returnsPlannableIdForRegularAssignment() {
        XCTAssertEqual(
            APIPlannable.parentAssignmentId(plannableType: .assignment, htmlUrl: nil, plannableId: "123"),
            "123"
        )
    }

    func test_returnsPlannableIdForDiscussion() {
        XCTAssertEqual(
            APIPlannable.parentAssignmentId(plannableType: .discussion_topic, htmlUrl: nil, plannableId: "456"),
            "456"
        )
    }

    func test_extractsAssignmentIdFromSimpleSubAssignmentUrl() {
        let url = APIURL(rawValue: URL(string: "https://canvas.example.com/courses/2054/assignments/50882")!)
        XCTAssertEqual(
            APIPlannable.parentAssignmentId(plannableType: .sub_assignment, htmlUrl: url, plannableId: "50883"),
            "50882"
        )
    }

    func test_extractsAssignmentIdFromSubAssignmentUrlWithSubmissionPath() {
        let url = APIURL(rawValue: URL(string: "https://canvas.example.com/courses/1192/assignments/49881/submissions/465")!)
        XCTAssertEqual(
            APIPlannable.parentAssignmentId(plannableType: .sub_assignment, htmlUrl: url, plannableId: "49883"),
            "49881"
        )
    }

    func test_fallsBackToPlannableIdWhenHtmlUrlIsNil() {
        XCTAssertEqual(
            APIPlannable.parentAssignmentId(plannableType: .sub_assignment, htmlUrl: nil, plannableId: "50883"),
            "50883"
        )
    }

    func test_fallsBackToPlannableIdWhenUrlHasNoAssignmentsComponent() {
        let url = APIURL(rawValue: URL(string: "https://canvas.example.com/courses/2054")!)
        XCTAssertEqual(
            APIPlannable.parentAssignmentId(plannableType: .sub_assignment, htmlUrl: url, plannableId: "50883"),
            "50883"
        )
    }
}
