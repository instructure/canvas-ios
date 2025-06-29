//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
@testable import Core

class AssignmentSubmissionBreakdownViewModelTests: CoreTestCase {
    func testProperties() {
        let useCase = GetSubmissionSummary(context: .course("1"), assignmentID: "2")
        let submissionSummary = APISubmissionSummary.make(graded: 1, ungraded: 2, not_submitted: 3)
        api.mock(useCase, value: submissionSummary)
        let testee = AssignmentSubmissionBreakdownViewModel(env: environment, courseID: "1", assignmentID: "2", submissionTypes: [])
        testee.viewDidAppear()

        XCTAssertEqual(testee.graded, 1)
        XCTAssertEqual(testee.ungraded, 2)
        XCTAssertEqual(testee.unsubmitted, 3)
        XCTAssertEqual(testee.submissionCount, 6)
    }

    func testSubmissionTypes() {
        var testee = AssignmentSubmissionBreakdownViewModel(env: environment, courseID: "1", assignmentID: "2", submissionTypes: [.online_upload, .basic_lti_launch])
        XCTAssertFalse(testee.noSubmissionTypes)
        XCTAssertFalse(testee.paperSubmissionTypes)

        testee = AssignmentSubmissionBreakdownViewModel(env: environment, courseID: "1", assignmentID: "2", submissionTypes: [.not_graded])
        XCTAssertTrue(testee.noSubmissionTypes)

        testee = AssignmentSubmissionBreakdownViewModel(env: environment, courseID: "1", assignmentID: "2", submissionTypes: [.on_paper])
        XCTAssertTrue(testee.paperSubmissionTypes)
    }

    func testRouting() {
        let testee = AssignmentSubmissionBreakdownViewModel(env: environment, courseID: "1", assignmentID: "2", submissionTypes: [])

        testee.routeToAll(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/assignments/2/submissions")!))

        testee.routeToGraded(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/assignments/2/submissions?filter=graded")!))

        testee.routeToUngraded(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/assignments/2/submissions?filter=needs_grading")!))

        testee.routeToUnsubmitted(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "courses/1/assignments/2/submissions?filter=not_submitted")!))
    }
}
