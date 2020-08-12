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

import TestsFoundation
import SwiftUI
import Combine
@testable import Core

@available(iOS 13.0, *)
class CourseListViewTests: CoreTestCase {
    lazy var courses: [APICourse] = [
        .make(),
        .make(id: "2"), // duplicate name
        .make(id: "3", name: "Course Two"),
        .make(id: "4", name: "Concluded 1", workflow_state: .completed),
        .make(id: "5", name: "Concluded 2", end_at: Clock.now.addDays(-10)),
        .make(id: "6", name: "Concluded 10", term: .make(end_at: Clock.now.addDays(-2))),
        .make(id: "7", name: "Future Course", term: .make(start_at: Clock.now.addDays(2))),
    ]

    var props = CourseListView.Props()

    lazy var controller: CoreHostingController<CourseListView> = {
        let allCourses = environment.subscribe(GetAllCourses())
        api.mock(allCourses, value: courses)
        return hostSwiftUIController(CourseListView(allCourses: allCourses.exhaust(), props: props, useList: false))
    }()

    lazy var view = controller.rootView.rootView
    var cancellable: [AnyCancellable] = []

    override func setUp() {
        super.setUp()
    }

    func xtestRunInteractivelyAndWatch() {
        cancellable.append(
            Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    for tag in self.controller.tags.values {
                        print(tag)
                    }
            }
        )
        RunLoop.current.run()
    }

    func testFilter() {
        drainMainQueue()
        XCTAssertEqual("\(controller.tags.values)", """
            [CourseListView(filter = '')
              current
                cell-1
                cell-2
                cell-3
              future
                cell-7
              header
                searchBar
              past
                cell-4
                cell-5
                cell-6]
            """
        )

        props.filter = "one"
        drainMainQueue()
        XCTAssertEqual("\(controller.tags.values)", """
            [CourseListView(filter = 'one')
              current
                cell-1
                cell-2
              future
              header
                searchBar
              past]
            """
        )
    }
}
