//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class PeopleListViewControllerTests: CoreTestCase {
    let course1 = Context(.course, id: "1")
    let course2 = Context(.course, id: "2")
    lazy var controller = PeopleListViewController.create(context: course1)

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(controller.course, value: .make())
        api.mock(controller.users, value: [
            .make(),
            .make(
                id: "2",
                name: "Jane",
                sortable_name: "jane doe",
                short_name: "jane",
                enrollments: [ .make(id: "2", course_id: "1", user_id: "2", role: "StudentEnrollment"),
                               .make(id: "2", course_id: "2", user_id: "2", role: "TeacherEnrollment"),
                               .make(id: "3", course_id: "1", user_id: "2", role: "Custom"),
                               .make(id: "4", course_id: "1", user_id: "2", role: "StudentEnrollment"), ],
                pronouns: "She/Her"
            ),
        ])
        api.mock(GetSearchRecipientsRequest(context: course1, includeContexts: true), value: [
            .make(id: "course_1_teachers"),
            .make(id: "course_1_students"),
            .make(id: "course_1_tas"),
        ])
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.titleSubtitleView.title, "People")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.nameLabel.text, "Bob")
        XCTAssertEqual(cell?.rolesLabel.text, "")

        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.nameLabel.text, "Jane (She/Her)")
        XCTAssertEqual(cell?.rolesLabel.text, "Custom and Student")

        api.mock(controller.users, value: [ .make(name: "George") ])
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false) // stops refreshing
        controller.tableView.delegate?.scrollViewDidScroll?(controller.tableView)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.nameLabel.text, "George")
    }

    func testFilter() {
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)

        api.mock(GetContextUsers(context: course1, type: .teacher), value: [ .make() ])
        var header = controller.tableView.headerView(forSection: 0) as? FilterHeaderView
        XCTAssertEqual(header?.filterButton.title(for: .normal), "Filter")
        header?.filterButton.sendActions(for: .primaryActionTriggered)
        let actions = (router.presented as! UIAlertController).actions
        XCTAssertEqual(actions.count, 4)
        XCTAssertEqual(actions[0].title, "Students")
        XCTAssertEqual(actions[1].title, "Teachers")
        XCTAssertEqual(actions[2].title, "Teaching Assistants")
        XCTAssertEqual(actions[3].title, "Cancel")
        (actions[1] as? AlertAction)?.handler?(actions[1])
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(controller.enrollmentType, .teacher)

        header = controller.tableView.delegate?.tableView?(controller.tableView, viewForHeaderInSection: 0) as? FilterHeaderView
        XCTAssertEqual(header?.filterButton.title(for: .normal), "Clear filter")
        header?.filterButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)
    }

    func testSearch() {
        controller.view.layoutIfNeeded()

        api.mock(GetContextUsers(context: course1, search: "fred"), value: [])
        controller.searchBar.delegate?.searchBarTextDidBeginEditing?(controller.searchBar)
        controller.searchBar.text = "fred"
        controller.searchBar.delegate?.searchBar?(controller.searchBar, textDidChange: "fred")
        controller.searchBar.delegate?.searchBarSearchButtonClicked?(controller.searchBar)
        controller.searchBar.delegate?.searchBarTextDidEndEditing?(controller.searchBar)
        XCTAssertEqual(controller.emptyView.isHidden, false)

        controller.searchBar.delegate?.searchBarCancelButtonClicked?(controller.searchBar)
        XCTAssertEqual(controller.emptyView.isHidden, true)
        XCTAssertEqual(controller.searchBar.text, "")
        XCTAssertEqual(controller.tableView.contentOffset.y, controller.searchBar.frame.height)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/users/1")))

        controller.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func testPaginatedRefresh() {
        controller.view.layoutIfNeeded()
        api.mock(controller.users, value: [.make()], response: HTTPURLResponse(next: "/courses/1/users?page=2"))
        api.mock(GetNextRequest(path: "/courses/1/users?page=2"), value: [APIUser.make(id: "2")])
        let tableView = controller.tableView!
        tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let loading = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? LoadingCell
        XCTAssertNotNil(loading)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        // simulate cell appearance
        tableView.delegate?.tableView?(tableView, willDisplay: loading!, forRowAt: IndexPath(row: 1, section: 0))
        // wait until loading indicator appears and refresh finishes
        RunLoop.main.run(until: Date() + 1)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! PeopleListCell
        XCTAssertEqual(cell.nameLabel.text, "Bob")
    }
}
