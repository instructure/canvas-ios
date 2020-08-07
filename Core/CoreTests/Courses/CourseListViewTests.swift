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
import ViewInspector
import Combine
@testable import Core

@available(iOS 13.0, *)
extension CourseListView: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, body: body)
    }
}

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

    lazy var props = CourseListView.Props()

    lazy var view: CourseListView = {
        let allCourses = environment.subscribe(GetAllCourses())
        api.mock(allCourses, value: courses)
        return hostSwiftUI(CourseListView(allCourses: allCourses.exhaust(), props: props))
    }()

    var searchBar: SearchBarView? { view.erased.first() }
    var sections: [ErasedView] { view.erased.findAll(ViewType.Section.self) }
    var cells: [[CourseListView.Cell]] { sections.map { $0.findAll() } }
    var headers: [String?] {
        sections.map { erased -> String? in
            try? erased.first(Text.self).inspect().text().string()
        }
    }

    override func setUp() {
        super.setUp()
        Clock.mockNow(Date(fromISOString: "2000-01-01T06:00:00Z")!)
    }

    func testEmpty() throws {
        courses = []
        let empty = view.erased.first(EmptyViewRepresentable.self)
        XCTAssertEqual(empty?.title, "No Courses")
        XCTAssertEqual(empty?.imageName, "PandaTeacher")
        XCTAssertNil(searchBar)
    }

    func testCoursesListed() throws {
        XCTAssertEqual(headers, [nil, "Current Enrollments", "Past Enrollments", "Future Enrollments"])
        print(view.erased.unknownTypes)
        dump(sections)
        dump(headers)
        dump(cells)

        XCTAssertEqual(cells[1].map { $0.course.id }, ["1", "2", "3"])
        XCTAssertEqual(cells[2].map { $0.course.id }, ["4", "5", "6"])
        XCTAssertEqual(cells[3].map { $0.course.id }, ["7"])
    }

    // this crashes, possibly a bug in SwiftUI
    func xtestFilter() throws {
        props.filter = "hello"
        XCTAssertEqual(searchBar?.text, "hello")
        XCTAssert(sections.isEmpty)
        view.props.filter = "course"
        XCTAssertEqual(headers, [nil, "Current Enrollments", nil, "Future Enrollments"])
        XCTAssertEqual(cells[1].map { $0.course.id }, ["1", "2", "3"])
        XCTAssertEqual(cells[2].map { $0.course.id }, [])
        XCTAssertEqual(cells[3].map { $0.course.id }, ["7"])
    }
}

@available(iOS 13.0, *)
extension CourseListView.Cell: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, body: body)
    }
}

@available(iOS 13.0, *)
class CourseListViewCellTests: CoreTestCase {
    var course = Course.make()
    @State var pending = false
    let selectExpectation = XCTestExpectation(description: "selected")

    lazy var cell = hostSwiftUI(CourseListView.Cell(course: course, pending: $pending) { [weak self] in
        self?.selectExpectation.fulfill()
    })

    func testText() throws {
        XCTAssertEqual(cell.erased.allTexts, ["Course One", "Student"])
        course.enrollments?.first?.role = Role.teacher.rawValue
        XCTAssertEqual(cell.erased.allTexts, ["Course One", "Teacher"])
        course.termName = "Winter"
        XCTAssertEqual(cell.erased.allTexts, ["Course One", "Winter", "|", "Teacher"])
    }
}
