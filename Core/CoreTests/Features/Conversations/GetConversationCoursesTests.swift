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

import XCTest
@testable import Core

class GetConversationCoursesTests: CoreTestCase {
    func testMakesTheRequests() {
        let enrollment = APIEnrollment.make(course_id: "1", type: "ObserverEnrollment")
        let enrollmentsRequest = GetEnrollmentsRequest(context: .currentUser, userID: nil, gradingPeriodID: nil, types: ["ObserverEnrollment"], includes: [.observed_users])
        api.mock(enrollmentsRequest, value: [enrollment])

        let course = APICourse.make(id: ID("1"))
        let coursesRequest = GetCoursesRequest(enrollmentState: .active, state: nil, perPage: 100)
        api.mock(coursesRequest, value: [course])

        let useCase = GetConversationCourses()
        let expectation = XCTestExpectation(description: "GetConversationCourses")
        var fetchedEnrollments: [APIEnrollment]?
        useCase.makeRequest(environment: environment) { (enrollments, _, _) in
            fetchedEnrollments = enrollments
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(useCase.fetchedCourses?.first, course)
        XCTAssertEqual(fetchedEnrollments?.first, enrollment)
    }

    func testSavesTheCourseOnTheEnrollment() {
        let useCase = GetConversationCourses()
        useCase.fetchedCourses = [.make(id: "1", name: "A"), .make(id: "2", name: "B"), .make(id: "3", name: "C")]

        let userA = APIUser.make(id: "1", name: "A")
        let userB = APIUser.make(id: "2", name: "B")
        let enrollments: [APIEnrollment] = [
            .make(id: "1", course_id: "1", type: "ObserverEnrollment", observed_user: userB),
            .make(id: "2", course_id: "2", type: "ObserverEnrollment", observed_user: userA),
            .make(id: "3", course_id: "3", type: "ObserverEnrollment", observed_user: userA)
        ]
        useCase.write(response: enrollments, urlResponse: nil, to: databaseClient)

        let enrollmentModels: [Enrollment] = databaseClient.fetch(scope: useCase.scope)

        XCTAssertEqual([enrollmentModels[0].id, enrollmentModels[1].id, enrollmentModels[2].id], ["2", "3", "1"])
    }
}
