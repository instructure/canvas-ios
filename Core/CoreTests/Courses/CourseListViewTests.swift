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

class CourseListViewTests: CoreTestCase {
    lazy var courses: [APICourse] = [
        .make(),
        .make(id: "2"), // duplicate name
        .make(id: "3", name: "Course Two"),
        .make(id: "4", name: "Concluded 1", workflow_state: .completed),
        .make(id: "5", name: "Concluded 2", end_at: Clock.now.addDays(-10)),
        .make(id: "6", name: "Concluded 10", term: .make(end_at: Clock.now.addDays(-2))),
        .make(id: "7", name: "Future Course", term: .make(name: "Fall 3020", start_at: Clock.now.addDays(2))),
    ]

    var props = CourseListView.Props()

    lazy var allCourses = environment.subscribe(GetAllCourses())
    lazy var controller: CoreHostingController<CourseListView> = {
        api.mock(allCourses, value: courses)
        return hostSwiftUIController(CourseListView(allCourses: allCourses.exhaust(), props: props, useList: false))
    }()
    lazy var view = controller.rootView.rootView

    var tree: TestTree? {
        _ = controller
        drainMainQueue()
        return controller.testTree
    }

    var sections: [TestTree] {
        tree?.children(kind: .section) ?? []
    }
    var shownCells: [String?: [String?]] {
        Dictionary(uniqueKeysWithValues: sections.map { section in
            (key: section.id, value: section.children(kind: .cell).map(\.id))
        })
    }
    var searchBar: TestTree? {
        tree?.find(SearchBarView.self)
    }
    func cell(_ id: String) -> TestTree? {
        tree?.find(.cell, id: id)
    }
    var noMatch: TestTree? {
        tree?.find(id: "no-match")
    }

    func testFilter() throws {
        XCTAssertEqual(shownCells["current"], ["1", "2", "3"])
        XCTAssertEqual(shownCells["past"], ["4", "5", "6"])
        XCTAssertEqual(shownCells["future"], ["7"])
        XCTAssertNotEqual(noMatch?.info("shown"), true)

        props.filter = "one"
        XCTAssertEqual(searchBar?.info("filter"), "one")
        XCTAssertEqual(shownCells["current"], ["1", "2"])
        XCTAssertEqual(shownCells["past"], nil)
        XCTAssertEqual(shownCells["future"], nil)
        XCTAssertNotEqual(noMatch?.info("shown"), true)

        props.filter = "garbage"
        XCTAssertEqual(shownCells, [:])
        XCTAssertEqual(noMatch?.info("shown"), true)
    }

    func testEmpty() throws {
        courses = []
        let empty = tree?.children(EmptyView.AsView.self)
        XCTAssertNotNil(empty)
        // Can we test the contained UIView somehow?
    }

    func testLoading() throws {
        let store = TestStore(env: environment, useCase: GetAllCourses()) { }
        store.overridePending = true
        allCourses = store
        XCTAssertNotNil(tree?.children(id: "loading"))
    }

    func testText() throws {
        XCTAssertEqual(cell("7")?.child(.text, id: "courseName")?.info("value"), "Future Course")
        XCTAssertEqual(cell("7")?.child(.text, id: "term")?.info("value"), "Fall 3020")
        XCTAssertEqual(cell("7")?.child(.text, id: "role")?.info("value"), "Student")
    }

    func testFavorite() throws {
        XCTAssertNotNil(cell("2")?.child(id: "not favorite"))
        allCourses.first { $0.id == "2" }?.isFavorite = true
        XCTAssertNotNil(cell("2")?.child(id: "favorite"))
    }

    func testPublishedIcon() throws {
        environment.app = .teacher
        XCTAssertNotNil(cell("2")?.child(id: "unpublished"))
        allCourses.first { $0.id == "2" }?.isPublished = true
        XCTAssertNotNil(cell("2")?.child(id: "published"))
    }

    func testStudentNoPublishedIcon() throws {
        XCTAssertNotNil(cell("2")?.child(id: "not favorite"))
        XCTAssertNil(cell("2")?.child(id: "unpublished"))
        XCTAssertNil(cell("2")?.child(id: "published"))
    }
}
