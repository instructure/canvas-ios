//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
@testable import Core
import XCTest

class AllCoursesInteractorLiveTests: CoreTestCase {
    private var testee: AllCoursesInteractorLive!
    private var courseListInteractorMock: CourseListInteractorMock!
    private var groupListInteractorMock: GroupListInteractorMock!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        courseListInteractorMock = CourseListInteractorMock()
        groupListInteractorMock = GroupListInteractorMock()
        testee = AllCoursesInteractorLive(
            courseListInteractor: courseListInteractorMock,
            groupListInteractor: groupListInteractorMock
        )
    }

    override func tearDown() {
        courseListInteractorMock = nil
        groupListInteractorMock = nil
        testee = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    func testSections() {
        var sections: AllCoursesSections!

        testee.sections
            .sink(receiveCompletion: { _ in }) { sections = $0 }
            .store(in: &subscriptions)

        courseListInteractorMock.coursesSubject.send((active: [], past: [], future: [.make(courseId: "course-future")]))
        groupListInteractorMock.groupsSubject.send([.make(id: "group-1")])

        XCTAssertEqual(sections.courses.current.map { $0.courseId }, [])
        XCTAssertEqual(sections.courses.past.map { $0.courseId }, [])
        XCTAssertEqual(sections.courses.future.map { $0.courseId }, ["course-future"])
        XCTAssertEqual(sections.groups.map { $0.id }, ["group-1"])
    }

    func testLoadAsync() {
        testee.loadAsync()

        XCTAssertEqual(courseListInteractorMock.loadAsyncCalled, true)
        XCTAssertEqual(groupListInteractorMock.loadAsyncCalled, true)
    }

    func testFilter() {
        testee.setFilter("g")
            .sink()
            .store(in: &subscriptions)

        XCTAssertEqual(courseListInteractorMock.filter, "g")
        XCTAssertEqual(groupListInteractorMock.filter, "g")
    }

    func testRefresh() {
        testee.refresh()
            .sink()
            .store(in: &subscriptions)

        XCTAssertEqual(courseListInteractorMock.refreshCalled, true)
        XCTAssertEqual(groupListInteractorMock.refreshCalled, true)
    }
}

class CourseListInteractorMock: CourseListInteractor {
    let coursesSubject = PassthroughSubject<(
        active: [Core.AllCoursesCourseItem],
        past: [Core.AllCoursesCourseItem],
        future: [Core.AllCoursesCourseItem]
    ), Error>()

    private(set) var getCoursesCalled = false
    private(set) var refreshCalled = false
    private(set) var loadAsyncCalled = false
    private(set) var filter = ""

    // MARK: - Outputs

    func getCourses() -> AnyPublisher<(active: [Core.AllCoursesCourseItem], past: [Core.AllCoursesCourseItem], future: [Core.AllCoursesCourseItem]), Error> {
        getCoursesCalled = true
        return coursesSubject.prepend((active: [], past: [], future: [])).eraseToAnyPublisher()
    }

    // MARK: - Inputs

    func loadAsync() {
        loadAsyncCalled = true
    }

    func refresh() -> AnyPublisher<Void, Never> {
        refreshCalled = true
        return Just(()).eraseToAnyPublisher()
    }

    func setFilter(_ filter: String) -> AnyPublisher<Void, Never> {
        self.filter = filter
        return Just(()).eraseToAnyPublisher()
    }
}

class GroupListInteractorMock: GroupListInteractor {
    let groupsSubject = PassthroughSubject<[AllCoursesGroupItem], Error>()

    private(set) var refreshCalled = false
    private(set) var loadAsyncCalled = false
    private(set) var filter = ""

    // MARK: - Outputs

    func getGroups() -> AnyPublisher<[Core.AllCoursesGroupItem], Error> {
        groupsSubject.eraseToAnyPublisher()
    }

    // MARK: - Inputs

    func loadAsync() {
        loadAsyncCalled = true
    }

    func refresh() -> AnyPublisher<Void, Never> {
        refreshCalled = true
        return Just(()).eraseToAnyPublisher()
    }

    func setFilter(_ filter: String) -> AnyPublisher<Void, Never> {
        self.filter = filter
        return Just(()).eraseToAnyPublisher()
    }
}
