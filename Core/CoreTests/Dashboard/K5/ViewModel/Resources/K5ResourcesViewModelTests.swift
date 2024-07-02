//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ResourcesViewModelTests: CoreTestCase {

    override func setUp() {
        super.setUp()

        let courses = [
            APICourse.make(id: "1", name: "Homeroom 1", syllabus_body: "<h1>Infos</h1><p>This is a paragraph</p>", homeroom_course: true),
            APICourse.make(id: "2", name: "Homeroom 2", syllabus_body: "<b>IMPORTANT</b><p>Read the previous note</p>", homeroom_course: true),
            APICourse.make(id: "3", name: "Math", homeroom_course: false)
        ]
        api.mock(GetCourses(enrollmentState: .active), value: courses)
    }

    func testHomeroomInfoFetch() {
        let testee = K5ResourcesViewModel()
        testee.viewDidAppear()

        XCTAssertEqual(testee.homeroomInfos, [
            K5ResourcesHomeroomInfoViewModel(homeroomName: "Homeroom 1", htmlContent: "<h1>Infos</h1><p>This is a paragraph</p>"),
            K5ResourcesHomeroomInfoViewModel(homeroomName: "Homeroom 2", htmlContent: "<b>IMPORTANT</b><p>Read the previous note</p>")
        ])
    }

    func testApplicationsFetch() {
        api.mock(GetCourseNavigationToolsRequest(courseContextsCodes: ["course_3"]), value: [
            CourseNavigationTool(
                id: "1",
                context_name: "Art",
                context_id: "course_art",
                course_navigation: .init(text: "Google Drive Text",
                                         url: URL(string: "https://instructure.com")!,
                                         label: "Google Drive Label",
                                         icon_url: URL(string: "https://instructure.com/icon.png")!),
                name: "Google Apps",
                url: nil),
            CourseNavigationTool(
                id: "1",
                context_name: "Math",
                context_id: "course_math",
                course_navigation: .init(text: "Google Drive Text",
                                         url: URL(string: "https://instructure.com")!,
                                         label: "Google Drive Label",
                                         icon_url: URL(string: "https://instructure.com/icon.png")!),
                name: "Google Apps",
                url: nil),
            CourseNavigationTool(
                id: "2",
                context_name: "Math",
                context_id: "course_math",
                course_navigation: .init(text: nil,
                                         url: URL(string: "https://instructure2.com")!,
                                         label: "Google Drive 2 Label",
                                         icon_url: URL(string: "https://instructure.com/icon2.png")!),
                name: "Google Apps 2",
                url: nil)
        ])

        let testee = K5ResourcesViewModel()
        testee.viewDidAppear()

        XCTAssertEqual(testee.applications, [
            K5ResourcesApplicationViewModel(image: URL(string: "https://instructure.com/icon2.png")!, name: "Google Apps 2", routesBySubjectNames: [
                ("Math", URL(string: "/courses/course_math/external_tools/2")!)
            ]),
            K5ResourcesApplicationViewModel(image: URL(string: "https://instructure.com/icon.png")!, name: "Google Drive Text", routesBySubjectNames: [
                ("Art", URL(string: "/courses/course_math/external_tools/1")!),
                ("Math", URL(string: "/courses/course_art/external_tools/1")!)
            ])
        ])
    }

    func testContactsFetch() {
        let course1TeacherRequest = GetContextUsersRequest(context: Context(.course, id: "1"), enrollment_type: .teacher, search_term: nil)
        let course1TeacherResponse = APIUser.make(name: "K5Teacher",
                                                  avatar_url: URL(string: "https://instucture.com/teacher.png")!,
                                                  enrollments: [.make(enrollment_state: .active, role: "TeacherEnrollment")])
        api.mock(course1TeacherRequest, value: [course1TeacherResponse])

        let course1TARequest = GetContextUsersRequest(context: Context(.course, id: "1"), enrollment_type: .ta, search_term: nil)
        api.mock(course1TARequest, value: [])

        let course2TeacherRequest = GetContextUsersRequest(context: Context(.course, id: "2"), enrollment_type: .teacher, search_term: nil)
        api.mock(course2TeacherRequest, value: [])

        let course2TARequest = GetContextUsersRequest(context: Context(.course, id: "2"), enrollment_type: .ta, search_term: nil)
        let course2TAResponse = APIUser.make(id: "2",
                                             name: "K5TA",
                                             avatar_url: URL(string: "https://instucture.com/TA.png")!,
                                             enrollments: [.make(enrollment_state: .active, role: "TeacherEnrollment")])
        api.mock(course2TARequest, value: [course2TAResponse])

        let testee = K5ResourcesViewModel()
        testee.viewDidAppear()

        XCTAssertEqual(testee.contacts, [
            K5ResourcesContactViewModel(image: URL(string: "https://instucture.com/TA.png")!, name: "K5TA", role: "Teacher's Assistant", userId: "2", courseContextID: "1", courseName: "Homeroom 1"),
            K5ResourcesContactViewModel(image: URL(string: "https://instucture.com/teacher.png")!, name: "K5Teacher", role: "Teacher", userId: "1", courseContextID: "2", courseName: "Homeroom 2")
        ])
    }

    func testRefresh() {
        let refreshExpectation = expectation(description: "Refresh finished")
        let homeroomInfoRefreshExpectation = expectation(description: "Homeroom Info refresh finished")
        homeroomInfoRefreshExpectation.assertForOverFulfill = false

        let testee = K5ResourcesViewModel()
        let homeRoomObservation = testee.$homeroomInfos.sink { _ in
            homeroomInfoRefreshExpectation.fulfill()
        }
        testee.refresh {
            refreshExpectation.fulfill()
        }

        wait(for: [refreshExpectation, homeroomInfoRefreshExpectation], timeout: 2.5)
        homeRoomObservation.cancel()
    }
}
