//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
import XCTest

final class GetHCourseSelectionUseCaseTests: CoreTestCase {

    private static let userID = "user 1"

    // MARK: - Cache key

    func test_cacheKey() {
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        XCTAssertEqual(useCase.cacheKey, "Get-Course-Selection")
    }

    // MARK: - Request

    func test_request_shouldContainUserID() {
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        XCTAssertEqual(useCase.request.variables.id, Self.userID)
    }

    func test_request_withDefaultHorizonCourses_shouldBeTrue() {
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        XCTAssertEqual(useCase.request.variables.horizonCourses, true)
    }

    func test_request_withCustomHorizonCourses_shouldMatchProvidedValue() {
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID, horizonCourses: false)

        XCTAssertEqual(useCase.request.variables.horizonCourses, false)
    }

    // MARK: - Write

    func test_write_shouldSaveEnrollmentsToCoreData() {
        let enrollment = makeEnrollment(
            enrollmentID: "enrollment 1",
            courseID: "course 1",
            courseName: "course name 1",
            files: []
        )
        let response = makeResponse(enrollments: [enrollment])
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let results: [CDHCourseSelection] = databaseClient.fetch()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, "course 1")
        XCTAssertEqual(results.first?.name, "course name 1")
    }

    func test_write_withMultipleEnrollments_shouldSaveAll() {
        let enrollments = [
            makeEnrollment(enrollmentID: "enrollment 1", courseID: "course 1", courseName: "course name 1", files: []),
            makeEnrollment(enrollmentID: "enrollment 2", courseID: "course 2", courseName: "course name 2", files: [])
        ]
        let response = makeResponse(enrollments: enrollments)
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let results: [CDHCourseSelection] = databaseClient.fetch()
        XCTAssertEqual(results.count, 2)
    }

    func test_write_withNilResponse_shouldSaveNothing() {
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let results: [CDHCourseSelection] = databaseClient.fetch()
        XCTAssertEqual(results.count, 0)
    }

    func test_write_withEmptyEnrollments_shouldSaveNothing() {
        let response = makeResponse(enrollments: [])
        let useCase = GetHCourseSelectionUseCase(userId: Self.userID)

        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let results: [CDHCourseSelection] = databaseClient.fetch()
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Private helpers

    private func makeResponse(
        enrollments: [GetHCourseSelectionResponse.Enrollment]
    ) -> GetHCourseSelectionResponse {
        GetHCourseSelectionResponse(
            data: GetHCourseSelectionResponse.DataClass(
                legacyNode: GetHCourseSelectionResponse.LegacyNode(
                    enrollments: enrollments
                )
            )
        )
    }

    private func makeEnrollment(
        enrollmentID: String,
        courseID: String,
        courseName: String,
        files: [GetHCourseSelectionResponse.Content]
    ) -> GetHCourseSelectionResponse.Enrollment {
        let moduleItems = files.map {
            GetHCourseSelectionResponse.ModuleItem(content: $0)
        }
        let node = GetHCourseSelectionResponse.Node(moduleItems: moduleItems)
        let edge = GetHCourseSelectionResponse.Edge(node: node)
        let modulesConnection = GetHCourseSelectionResponse.ModulesConnection(edges: [edge])
        let course = GetHCourseSelectionResponse.Course(
            id: courseID,
            name: courseName,
            modulesConnection: modulesConnection
        )
        return GetHCourseSelectionResponse.Enrollment(id: enrollmentID, course: course)
    }
}
