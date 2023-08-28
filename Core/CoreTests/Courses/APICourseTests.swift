//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

class APICourseTests: XCTestCase {
    func testGetCoursesRequest() {
        XCTAssertEqual(GetCoursesRequest().path, "courses")
        XCTAssertEqual(GetCoursesRequest().queryItems, [
            URLQueryItem(name: "include[]", value: "banner_image"),
            URLQueryItem(name: "include[]", value: "course_image"),
            URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "grading_periods"),
            URLQueryItem(name: "include[]", value: "needs_grading_count"),
            URLQueryItem(name: "include[]", value: "observed_users"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "syllabus_body"),
            URLQueryItem(name: "include[]", value: "tabs"),
            URLQueryItem(name: "include[]", value: "term"),
            URLQueryItem(name: "include[]", value: "total_scores"),
            URLQueryItem(name: "include[]", value: "settings"),
            URLQueryItem(name: "include[]", value: "grading_scheme"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "enrollment_state", value: "active"),
        ])
        XCTAssertEqual(GetCoursesRequest(enrollmentState: .completed, state: [.available, .completed, .unpublished], perPage: 20).queryItems, [
            URLQueryItem(name: "include[]", value: "banner_image"),
            URLQueryItem(name: "include[]", value: "course_image"),
            URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "grading_periods"),
            URLQueryItem(name: "include[]", value: "needs_grading_count"),
            URLQueryItem(name: "include[]", value: "observed_users"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "syllabus_body"),
            URLQueryItem(name: "include[]", value: "tabs"),
            URLQueryItem(name: "include[]", value: "term"),
            URLQueryItem(name: "include[]", value: "total_scores"),
            URLQueryItem(name: "include[]", value: "settings"),
            URLQueryItem(name: "include[]", value: "grading_scheme"),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "enrollment_state", value: "completed"),
            URLQueryItem(name: "state[]", value: "available"),
            URLQueryItem(name: "state[]", value: "completed"),
            URLQueryItem(name: "state[]", value: "unpublished"),
        ])
        let req = GetCoursesRequest(enrollmentState: nil, state: nil, perPage: 10, studentID: "1")
        XCTAssertEqual(req.path, "users/1/courses")
        let noStudent = GetCoursesRequest(enrollmentState: nil, state: nil, perPage: 10, studentID: nil)
        XCTAssertEqual(noStudent.path, "courses")
    }

    func testGetCourseRequest() {
        XCTAssertEqual(GetCourseRequest(courseID: "2").path, "courses/2")
        XCTAssertEqual(GetCourseRequest(courseID: "2").queryItems, [
            URLQueryItem(name: "include[]", value: "banner_image"),
            URLQueryItem(name: "include[]", value: "course_image"),
            URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "permissions"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "syllabus_body"),
            URLQueryItem(name: "include[]", value: "term"),
            URLQueryItem(name: "include[]", value: "total_scores"),
            URLQueryItem(name: "include[]", value: "observed_users"),
            URLQueryItem(name: "include[]", value: "settings"),
            URLQueryItem(name: "include[]", value: "grading_scheme"),
        ])
    }

    func testUpdateCourseRequest() {
        let params = APICourseParameters(name: "Cracking Wise", default_view: .wiki, syllabus_body: "Syllabus", syllabus_course_summary: true)
        let body = PutCourseRequest.Body(course: params)
        XCTAssertEqual(PutCourseRequest(courseID: "2", body: body).method, .put)
        XCTAssertEqual(PutCourseRequest(courseID: "2", body: body).path, "courses/2")
        XCTAssertEqual(PutCourseRequest(courseID: "2", body: body).body, body)
    }

    func testCreateCourseRequest() {
        let params = APICourseParameters(name: "name", default_view: .assignments, syllabus_body: nil, syllabus_course_summary: nil)
        let body = PostCourseRequest.Body(course: params)
        let request = PostCourseRequest(accountID: "1", body: body)

        XCTAssertEqual(request.path, "accounts/1/courses")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }

    func testGetCourseSettingsRequest() {
        XCTAssertEqual(GetCourseSettingsRequest(courseID: "2").path, "courses/2/settings")
    }
}
