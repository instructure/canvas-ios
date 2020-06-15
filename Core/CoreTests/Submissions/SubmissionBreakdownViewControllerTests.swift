//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import TestsFoundation

class SubmissionBreakdownViewControllerTests: CoreTestCase {
    let now = DateComponents(calendar: .current, year: 2020, month: 12, day: 5).date!
    let course = Context(.course, id: "1")
    lazy var controller = SubmissionBreakdownViewController.create(courseID: course.id, assignmentID: "1", submissionTypes: [.discussion_topic])

    override func setUp() {
        super.setUp()
        Clock.mockNow(now)
        api.mock(controller.summary, value: .make(graded: 10, ungraded: 20, not_submitted: 30))
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.onPaperLabel.isHidden, true)
        XCTAssertEqual(controller.noSubmissionsLabel.isHidden, true)
        XCTAssertEqual(controller.gradedView.isHidden, false)
        XCTAssertEqual(controller.ungradedView.isHidden, false)
        XCTAssertEqual(controller.unsubmittedView.isHidden, false)

        XCTAssertNotNil(controller.animateLink)
        XCTAssertEqual(controller.gradedCountLabel.text, "0")
        XCTAssertEqual(controller.gradedProgress.progress, 0)
        XCTAssertEqual(controller.ungradedCountLabel.text, "0")
        XCTAssertEqual(controller.ungradedProgress.progress, 0)
        XCTAssertEqual(controller.unsubmittedCountLabel.text, "0")
        XCTAssertEqual(controller.unsubmittedProgress.progress, 0)

        Clock.mockNow(now.add(.second, number: 5))
        controller.stepAnimate()
        XCTAssertNil(controller.animateLink)
        XCTAssertEqual(controller.gradedCountLabel.text, "10")
        XCTAssertEqual(controller.gradedProgress.progress, 1 / 6)
        XCTAssertEqual(controller.ungradedCountLabel.text, "20")
        XCTAssertEqual(controller.ungradedProgress.progress, 2 / 6)
        XCTAssertEqual(controller.unsubmittedCountLabel.text, "30")
        XCTAssertEqual(controller.unsubmittedProgress.progress, 3 / 6)

        controller.button.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/assignments/1/submissions")))

        controller.gradedButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/assignments/1/submissions?filterType=graded")))

        controller.ungradedButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/assignments/1/submissions?filterType=ungraded")))

        controller.unsubmittedButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/assignments/1/submissions?filterType=not_submitted")))

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testOnPaper() {
        controller.submissionTypes = [.on_paper]
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.onPaperLabel.isHidden, false)
        XCTAssertEqual(controller.noSubmissionsLabel.isHidden, true)
        XCTAssertEqual(controller.gradedView.isHidden, false)
        XCTAssertEqual(controller.ungradedView.isHidden, true)
        XCTAssertEqual(controller.unsubmittedView.isHidden, true)
    }

    func testEmpty() {
        api.mock(controller.summary, value: .make(graded: 0, ungraded: 0, not_submitted: 0))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.onPaperLabel.isHidden, true)
        XCTAssertEqual(controller.noSubmissionsLabel.isHidden, false)
        XCTAssertEqual(controller.gradedView.isHidden, true)
        XCTAssertEqual(controller.ungradedView.isHidden, true)
        XCTAssertEqual(controller.unsubmittedView.isHidden, true)
    }
}
