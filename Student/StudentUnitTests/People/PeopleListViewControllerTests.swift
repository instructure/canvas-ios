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
@testable import Student
@testable import Core
@testable import TestsFoundation

class PeopleListViewControllerTests: StudentTestCase {
    lazy var vc = PeopleListViewController.create(context: ContextModel(.course, id: courseID))
    let courseID = "1"
    
    override func setUp() {
        super.setUp()
        vc = PeopleListViewController.create(context: ContextModel(.course, id: courseID))
    }
    
    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testRender() {
        //  given
        env.mockStore = false
        api.mock(vc.presenter!.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(vc.presenter!.course, value: .make())
        api.mock(vc.presenter!.users, value: [.make(),
                                              .make(id: "2", name: "Jane", sortable_name: "jane doe", short_name: "jane", email: "jane@doe.com")])
        
        //  when
        loadView()

        //  then
        let titleView = vc.navigationItem.titleView as? TitleSubtitleView
        XCTAssertEqual(titleView?.title, "People")

        XCTAssertEqual(vc.tableView?.numberOfRows(inSection: 0), 2)

        var cell = vc.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.name?.text, "Bob")
        
        cell = vc.tableView?.cellForRow(at: IndexPath(row: 1, section: 0)) as? PeopleListCell
        XCTAssertEqual(cell?.name?.text, "Jane")
        
        
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/users/1")))
    }
}
