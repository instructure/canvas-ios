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

class CourseListInteractorLiveTests: CoreTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var testee: CourseListInteractorLive!

    override func setUp() {
        super.setUp()

        let activeCourseRequest = GetAllCoursesCourseListUseCase(enrollmentState: .active)
        api.mock(activeCourseRequest, value: [.make(id: "1", name: "A")])
        let pastCourseRequest = GetAllCoursesCourseListUseCase(enrollmentState: .completed)
        api.mock(pastCourseRequest, value: [.make(id: "2", name: "AB")])
        let futureCourseRequest = GetAllCoursesCourseListUseCase(enrollmentState: .invited_or_pending)
        api.mock(futureCourseRequest, value: [.make(id: "3", name: "ABC", workflow_state: .available)])

        testee = CourseListInteractorLive(env: environment)
    }

    override func tearDown() {
        testee = nil
        subscriptions.removeAll()
        testee = nil
        super.tearDown()
    }

    func testPopulatesListItems() {
        testee.getCourses()
            .sink(receiveCompletion: { _ in }) { current, past, future in
                XCTAssertEqual(current.map { $0.courseId }, ["1"])
                XCTAssertEqual(past.map { $0.courseId }, ["2"])
                XCTAssertEqual(future.map { $0.courseId }, ["3"])
            }
            .store(in: &subscriptions)
    }

    func testFilter() {
        testee
            .setFilter("b")
            .sink()
            .store(in: &subscriptions)

        testee.getCourses()
            .sink(receiveCompletion: { _ in }) { current, past, future in
                XCTAssertEqual(current.map { $0.courseId }, [])
                XCTAssertEqual(past.map { $0.courseId }, ["2"])
                XCTAssertEqual(future.map { $0.courseId }, ["3"])
            }
            .store(in: &subscriptions)
    }

    func testRefresh() {
        var list: (active: [AllCoursesCourseItem], past: [AllCoursesCourseItem], future: [AllCoursesCourseItem]) = ([], [], [])
        testee.getCourses()
            .sink { _ in } receiveValue: { val in
                list = val
            }
            .store(in: &subscriptions)

        drainMainQueue()
        XCTAssertEqual(list.active.map { $0.courseId }, ["1"])
        XCTAssertEqual(list.past.map { $0.courseId }, ["2"])
        XCTAssertEqual(list.future.map { $0.courseId }, ["3"])

        let activeCourseRequest = GetAllCoursesCourseListUseCase(enrollmentState: .active)
        api.mock(activeCourseRequest, value: [.make(id: "4", name: "ABCD")])
        testee.refresh()
            .sink()
            .store(in: &subscriptions)

        drainMainQueue()
        XCTAssertEqual(list.active.map { $0.courseId }, ["4"])
        XCTAssertEqual(list.past.map { $0.courseId }, ["2"])
        XCTAssertEqual(list.future.map { $0.courseId }, ["3"])
    }

    func testFutureUnpublishedCoursesAreHiddenForStudents() {
        let futureCourseRequest = GetAllCoursesCourseListUseCase(enrollmentState: .invited_or_pending)
        api.mock(futureCourseRequest, value: [
            .make(id: "3", name: "ABC", workflow_state: .available),
            .make(id: "4", name: "unpublished", workflow_state: .unpublished)
        ])

        testee.getCourses()
            .sink(receiveCompletion: { _ in }) { _, _, future in
                XCTAssertEqual(future.map { $0.courseId }, ["3"])
            }
            .store(in: &subscriptions)
    }

    func testFutureUnpublishedCoursesAreShownForTeachers() {
        environment.app = .teacher

        let futureCourseRequest = GetAllCoursesCourseListUseCase(enrollmentState: .invited_or_pending)
        api.mock(futureCourseRequest, value: [
            .make(id: "3", name: "ABC", workflow_state: .available),
            .make(id: "4", name: "unpublished", workflow_state: .unpublished)
        ])

        testee.getCourses()
            .sink(receiveCompletion: { _ in }) { _, _, future in
                XCTAssertEqual(future.map { $0.courseId }, ["3", "4"])
            }
            .store(in: &subscriptions)
    }
}
