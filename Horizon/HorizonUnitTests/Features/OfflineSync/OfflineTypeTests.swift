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

@testable import Horizon
import XCTest

final class OfflineTypeTests: XCTestCase {

    private static let testData = (
        courseID: "course 1",
        enrollmentID: "enrollment 1",
        fileID: "file 1",
        programID: "program 1",
        learningLibraryID: "library 1"
    )
    private lazy var testData = Self.testData

    // MARK: - path()

    func test_path_course() {
        let path = OfflineType.course(id: testData.courseID, enrollmentID: testData.enrollmentID).path()

        XCTAssertEqual(path, "offline/course/\(testData.courseID)/\(testData.enrollmentID)")
    }

    func test_path_file() {
        let path = OfflineType.file(courseID: testData.courseID, fileID: testData.fileID).path()

        XCTAssertEqual(path, "offline/course/\(testData.courseID)/file/\(testData.fileID)")
    }

    func test_path_program() {
        let path = OfflineType.program(id: testData.programID).path()

        XCTAssertEqual(path, "offline/program/\(testData.programID)")
    }

    func test_path_learningLibrary() {
        let path = OfflineType.learningLibrary(id: testData.learningLibraryID).path()

        XCTAssertEqual(path, "offline/learningLibrary/\(testData.learningLibraryID)")
    }

    // MARK: - parse(path:)

    func test_parse_courseNewFormat() {
        let path = "offline/course/\(testData.courseID)/\(testData.enrollmentID)"

        guard case .course(let id, let enrollmentID) = OfflineType.parse(path: path) else {
            return XCTFail("Expected .course, got nil")
        }
        XCTAssertEqual(id, testData.courseID)
        XCTAssertEqual(enrollmentID, testData.enrollmentID)
    }

    func test_parse_courseOldFormat_shouldFallbackToEmptyEnrollmentID() {
        let path = "offline/course/\(testData.courseID)"

        guard case .course(let id, let enrollmentID) = OfflineType.parse(path: path) else {
            return XCTFail("Expected .course, got nil")
        }
        XCTAssertEqual(id, testData.courseID)
        XCTAssertEqual(enrollmentID, "")
    }

    func test_parse_file() {
        let path = "offline/course/\(testData.courseID)/file/\(testData.fileID)"

        guard case .file(let courseID, let fileID) = OfflineType.parse(path: path) else {
            return XCTFail("Expected .file, got nil")
        }
        XCTAssertEqual(courseID, testData.courseID)
        XCTAssertEqual(fileID, testData.fileID)
    }

    func test_parse_program() {
        let path = "offline/program/\(testData.programID)"

        guard case .program(let id) = OfflineType.parse(path: path) else {
            return XCTFail("Expected .program, got nil")
        }
        XCTAssertEqual(id, testData.programID)
    }

    func test_parse_learningLibrary() {
        let path = "offline/learningLibrary/\(testData.learningLibraryID)"
        guard case .learningLibrary(let id) = OfflineType.parse(path: path) else {
            return XCTFail("Expected .learningLibrary, got nil")
        }
        XCTAssertEqual(id, testData.learningLibraryID)
    }
}
