//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class APICourseRequestableTests: XCTestCase {
    func testGetCoursesRequest() {
        XCTAssertEqual(GetCoursesRequest(includeUnpublished: false).path, "courses")
        XCTAssertEqual(GetCoursesRequest(includeUnpublished: false).queryItems, [
            URLQueryItem(name: "include[]", value: "course_image"),
            URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "observed_users"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "term"),
            URLQueryItem(name: "include[]", value: "total_scores"),
            URLQueryItem(name: "state[]", value: "available"),
            URLQueryItem(name: "state[]", value: "completed"),
        ])
        XCTAssertEqual(GetCoursesRequest(includeUnpublished: true).queryItems, [
            URLQueryItem(name: "include[]", value: "course_image"),
            URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "observed_users"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "term"),
            URLQueryItem(name: "include[]", value: "total_scores"),
            URLQueryItem(name: "state[]", value: "available"),
            URLQueryItem(name: "state[]", value: "completed"),
            URLQueryItem(name: "state[]", value: "unpublished"),
        ])
    }

    func testGetCourseRequest() {
        XCTAssertEqual(GetCourseRequest(courseID: "2").path, "courses/2")
        XCTAssertEqual(GetCourseRequest(courseID: "2").queryItems, [
            URLQueryItem(name: "include[]", value: "course_image"),
            URLQueryItem(name: "include[]", value: "current_grading_period_scores"),
            URLQueryItem(name: "include[]", value: "favorites"),
            URLQueryItem(name: "include[]", value: "permissions"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "term"),
            URLQueryItem(name: "include[]", value: "total_scores"),
        ])
    }

    func testUpdateCourseRequest() {
        let params = APICourseParameters(name: "Cracking Wise", default_view: .wiki)
        let body = PutCourseRequest.Body(course: params)
        XCTAssertEqual(PutCourseRequest(courseID: "2", body: body).method, .put)
        XCTAssertEqual(PutCourseRequest(courseID: "2", body: body).path, "courses/2")
        XCTAssertEqual(PutCourseRequest(courseID: "2", body: body).body, body)
    }

    func testCreateCourseRequest() {
        let params = APICourseParameters(name: "name", default_view: .assignments)
        let body = PostCourseRequest.Body(course: params)
        let request = PostCourseRequest(accountID: "1", body: body)

        XCTAssertEqual(request.path, "accounts/1/courses")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }
}
