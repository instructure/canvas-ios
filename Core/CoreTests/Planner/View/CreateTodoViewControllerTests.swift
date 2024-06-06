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

class CreateTodoViewControllerTests: CoreTestCase {
    let date = Clock.now

    override func setUp() {
        super.setUp()
        Clock.mockNow(date)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testLayout() {
        let title = "title"
        let details = "details"
        let course = APICourse.make()

        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: []
        )
        api.mock(coursesRequest, value: [course])
        let groupsRequest = GetGroupsRequest(context: .currentUser)
        api.mock(groupsRequest, value: [])

        api.mock(GetCourses(), value: [course])
        let createExpectation = XCTestExpectation(description: "make sure create post request is made when done button is pressed")
        let refreshExpectation = XCTestExpectation(description: "make sure refresh request is made after todo is created")

        let createNoteRequest = PostPlannerNoteRequest(body:
            PostPlannerNoteRequest.Body(
                title: title,
                details: details,
                todo_date: date,
                course_id: course.id.value,
                linked_object_type: .planner_note,
                linked_object_id: nil))

        api.mock(createNoteRequest) { _ in
            createExpectation.fulfill()
            return (nil, nil, nil)
        }

        let vc = CreateTodoViewController.create {
            refreshExpectation.fulfill()
        }

        vc.loadView()
        vc.viewDidLoad()
        vc.viewDidAppear(false)

        XCTAssertEqual(vc.titleLabel.placeholder, "Title...")
        XCTAssertEqual(vc.dateTitleLabel.text, "Date")
        XCTAssertEqual(vc.courseTitleLabel.text, "Course (optional)")
        XCTAssertEqual(vc.courseSelectionLabel.text, "None")
        XCTAssertEqual(vc.dateTextField.text, vc.selectedDate?.dateTimeString ?? "")
        XCTAssertEqual(vc.dateTitleLabel.text, "Date")

        XCTAssertEqual(vc.titleLabel.accessibilityLabel, "Title")
        XCTAssertEqual(vc.selectCourseButton.accessibilityLabel, "Course (optional), None")
        XCTAssertEqual(vc.descTextView.accessibilityLabel, "Description")
        XCTAssertEqual(vc.descTextView.placeholder, "Description")

        vc.titleLabel.text = title
        vc.selectedDate = date
        vc.descTextView.text = details

        vc.selectCourseButton.sendActions(for: .primaryActionTriggered)
        if let coursesVC = router.viewControllerCalls.first?.0 as? SelectCourseViewController {
            let index0 = IndexPath(row: 0, section: 0)
            coursesVC.tableView.selectRow(at: index0, animated: false, scrollPosition: .none)
            coursesVC.tableView.delegate?.tableView?(coursesVC.tableView, didSelectRowAt: index0)
            XCTAssertEqual(vc.courseSelectionLabel.text, "Course One")
        } else {
            XCTFail("select course vc not pushed")
        }

        let doneButton = vc.navigationItem.rightBarButtonItem
        _ = doneButton?.target?.perform(doneButton?.action)

        wait(for: [createExpectation, refreshExpectation], timeout: 0.5)
    }
}
