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
@testable import Horizon
import TestsFoundation
import XCTest

final class ManageOfflineContentInteractorLiveTests: HorizonTestCase {

    private static let userID = "user 1"

    private var testee: ManageOfflineContentInteractorLive!
    private var session: SessionDefaults!

    override func setUp() {
        super.setUp()
        session = SessionDefaults(sessionID: Self.userID)
        testee = ManageOfflineContentInteractorLive(userID: Self.userID, session: session)
    }

    override func tearDown() {
        testee = nil
        session.reset()
        session = nil
        super.tearDown()
    }

    // MARK: - getCourses

    func test_getCourses_shouldMapEnrollmentsToCourseItems() {
        mockAPIResponse(enrollments: [
            makeEnrollment(courseID: "course 1", courseName: "course name 1", files: [])
        ])

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: true)) { items in
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.id, "course 1")
            XCTAssertEqual(items.first?.name, "course name 1")
        }
    }

    func test_getCourses_withMultipleCourses_shouldMapAllCourseItems() {
        mockAPIResponse(enrollments: [
            makeEnrollment(courseID: "course 1", courseName: "course name 1", files: []),
            makeEnrollment(courseID: "course 2", courseName: "course name 2", files: [])
        ])

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: true)) { items in
            XCTAssertEqual(items.count, 2)
        }
    }

    func test_getCourses_withFiles_shouldMapSubItems() {
        let file = makeContent(id: "file 1", displayName: "file name 1", size: "2 MB")
        mockAPIResponse(enrollments: [
            makeEnrollment(courseID: "course 1", courseName: "course name 1", files: [file])
        ])

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: true)) { items in
            XCTAssertEqual(items.first?.files.count, 1)
            XCTAssertEqual(items.first?.files.first?.id, "file 1")
            XCTAssertEqual(items.first?.files.first?.name, "file name 1")
            XCTAssertEqual(items.first?.files.first?.size, "2 MB")
        }
    }

    func test_getCourses_withEmptyEnrollments_shouldReturnEmptyList() {
        mockAPIResponse(enrollments: [])

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: true)) { items in
            XCTAssertEqual(items.count, 0)
        }
    }

    func test_getCourses_whenAPIFails_shouldForwardError() {
        api.mock(
            GetHCourseSelectionRequest(userId: Self.userID),
            error: NSError.instructureError("network error")
        )

        XCTAssertFailure(testee.getCourses(ignoreCache: true))
    }

    // MARK: - Private helpers

    private func mockAPIResponse(enrollments: [GetHCourseSelectionResponse.Enrollment]) {
        let response = GetHCourseSelectionResponse(
            data: GetHCourseSelectionResponse.DataClass(
                legacyNode: GetHCourseSelectionResponse.LegacyNode(
                    enrollments: enrollments
                )
            )
        )
        api.mock(GetHCourseSelectionRequest(userId: Self.userID), value: response)
    }

    private func makeEnrollment(
        courseID: String,
        courseName: String,
        files: [GetHCourseSelectionResponse.Content]
    ) -> GetHCourseSelectionResponse.Enrollment {
        let moduleItems = files.map { GetHCourseSelectionResponse.ModuleItem(content: $0) }
        let node = GetHCourseSelectionResponse.Node(moduleItems: moduleItems)
        let edge = GetHCourseSelectionResponse.Edge(node: node)
        let modulesConnection = GetHCourseSelectionResponse.ModulesConnection(edges: [edge])
        let course = GetHCourseSelectionResponse.Course(
            id: courseID,
            name: courseName,
            modulesConnection: modulesConnection
        )
        return GetHCourseSelectionResponse.Enrollment(id: "enrollment \(courseID)", course: course)
    }

    private func makeContent(
        id: String,
        displayName: String,
        size: String
    ) -> GetHCourseSelectionResponse.Content {
        GetHCourseSelectionResponse.Content(
            id: id,
            displayName: displayName,
            size: size,
            url: nil,
            mimeClass: "pdf",
            updatedAt: nil
        )
    }
}
