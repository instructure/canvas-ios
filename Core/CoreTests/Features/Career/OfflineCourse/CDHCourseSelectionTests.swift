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

final class CDHCourseSelectionTests: CoreTestCase {

    private static let testData = (
        courseID: "course 1",
        courseName: "course name 1",
        enrollmentID: "enrollment 1",
        fileID: "file 1",
        fileName: "file name 1",
        fileSize: "2 MB"
    )
    private lazy var testData = Self.testData

    // MARK: - Save

    func test_save_shouldPersistCourseProperties() {
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: testData.courseName,
            files: []
        )

        let result = CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        XCTAssertEqual(result.id, testData.courseID)
        XCTAssertEqual(result.name, testData.courseName)
    }

    func test_save_whenCalledTwiceWithSameCourseID_shouldUpdateExistingRecord() {
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: "old name",
            files: []
        )
        CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        let updated = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: "new name",
            files: []
        )
        CDHCourseSelection.save(apiEntity: updated, in: databaseClient)

        let results: [CDHCourseSelection] = databaseClient.fetch()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "new name")
    }

    func test_save_withFiles_shouldSaveAssociatedFiles() {
        let file = makeContent(id: testData.fileID, displayName: testData.fileName, size: testData.fileSize)
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: testData.courseName,
            files: [file]
        )

        let result = CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        XCTAssertEqual(result.files.count, 1)
        XCTAssertEqual(result.files.first?.id, testData.fileID)
        XCTAssertEqual(result.files.first?.name, testData.fileName)
    }

    func test_save_withNoFiles_shouldHaveEmptyFilesSet() {
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: testData.courseName,
            files: []
        )

        let result = CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        XCTAssertEqual(result.files.count, 0)
    }

    // MARK: - Size calculation

    func test_save_withFilesHavingKnownSizes_shouldCalculateTotalFormattedSize() {
        let file1 = makeContent(id: "file 1", displayName: "name 1", size: "1 MB")
        let file2 = makeContent(id: "file 2", displayName: "name 2", size: "2 MB")
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: testData.courseName,
            files: [file1, file2]
        )

        let result = CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        XCTAssertFalse(result.size.isEmpty)
    }

    func test_save_withNoFiles_shouldUseFallbackSize() {
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: testData.courseName,
            files: []
        )

        let result = CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        XCTAssertFalse(result.size.isEmpty)
    }

    func test_save_withFilesHavingNilIDs_shouldFilterThemOut() {
        let validFile = makeContent(id: testData.fileID, displayName: "name 1", size: "1 MB")
        let invalidFile = makeContent(id: nil, displayName: "name 2", size: "2 MB")
        let enrollment = makeEnrollment(
            enrollmentID: testData.enrollmentID,
            courseID: testData.courseID,
            courseName: testData.courseName,
            files: [validFile, invalidFile]
        )

        let result = CDHCourseSelection.save(apiEntity: enrollment, in: databaseClient)

        XCTAssertEqual(result.files.count, 1)
        XCTAssertEqual(result.files.first?.id, testData.fileID)
    }

    // MARK: - Private helpers

    private func makeContent(
        id: String?,
        displayName: String?,
        size: String?
    ) -> GetHCourseSelectionResponse.Content {
        GetHCourseSelectionResponse.Content(id: id, displayName: displayName, size: size, url: nil)
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
