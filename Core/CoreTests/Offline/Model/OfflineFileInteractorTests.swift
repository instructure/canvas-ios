//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class OfflineFileInteractorTests: CoreTestCase {

    let testee = OfflineFileInteractorLive(offlineModeInteractor: OfflineModeInteractorMock())

    func testGetFilePathSwitchWithPrivateSource() {
        let sessionId = "sessionId"
        let courseId = "courseId"
        let sectionName = "sectionName"
        let resourceId = "resourceId"
        let fileId = "fileId"
        let fileName = "test.txt"
        let source = OfflineFileSource.privateFile(sessionID: sessionId, courseID: courseId, sectionName: sectionName, resourceID: resourceId, fileID: fileId)
        let expected = "\(sessionId)/Offline/course-\(courseId)/\(sectionName)/\(sectionName)-\(resourceId)/file-\(fileId)"

        try? FileManager.default.createDirectory(atPath: URL.Directories.documents.appendingPathComponent(expected).path, withIntermediateDirectories: true)
        FileManager.default.createFile(
            atPath: URL.Directories.documents.appendingPathComponent(expected).appendingPathComponent(fileName).path,
            contents: "test".data(using: .utf8)
        )
        var filePath = testee.filePath(source: source)
        XCTAssertEqual(filePath, "/\(expected)/\(fileName)")

        try? FileManager.default.removeItem(atPath: URL.Directories.documents.appendingPathComponent(expected).path)
        filePath = testee.filePath(source: source)
        XCTAssertEqual(filePath, nil)
    }

    func testGetFilePathSwitchWithPublicSource() {
        let fileName = "test.txt"
        let (source, expected) = getPrivatePath()

        try? FileManager.default.createDirectory(atPath: URL.Directories.documents.appendingPathComponent(expected).path, withIntermediateDirectories: true)
        FileManager.default.createFile(
            atPath: URL.Directories.documents.appendingPathComponent(expected).appendingPathComponent(fileName).path,
            contents: "test".data(using: .utf8)
        )
        var filePath = testee.filePath(source: source)
        XCTAssertEqual(filePath, "/\(expected)/\(fileName)")

        try? FileManager.default.removeItem(atPath: expected)
        filePath = testee.filePath(source: source)
        XCTAssertEqual(filePath, "/\(expected)/\(fileName)")
    }

    func testFileAvailablePathSwitchWithPrivateSourceOnline() {
        let fileName = "test.txt"
        let (source, expected) = getPrivatePath()
        let offlineInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: false)
        let testee = OfflineFileInteractorLive(offlineModeInteractor: offlineInteractor)

        try? FileManager.default.createDirectory(atPath: URL.Directories.documents.appendingPathComponent(expected).path, withIntermediateDirectories: true)
        FileManager.default.createFile(
            atPath: URL.Directories.documents.appendingPathComponent(expected).appendingPathComponent(fileName).path,
            contents: "test".data(using: .utf8)
        )
        XCTAssertFalse(testee.isItemAvailableOffline(source: source))

        try? FileManager.default.removeItem(atPath: URL.Directories.documents.appendingPathComponent(expected).path)
        XCTAssertFalse(testee.isItemAvailableOffline(source: source))
    }

    func testFileAvailablePathSwitchWithPrivateSourceOffline() {
        let fileName = "test.txt"
        let (source, expected) = getPrivatePath()
        let offlineInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        let testee = OfflineFileInteractorLive(offlineModeInteractor: offlineInteractor)

        try? FileManager.default.createDirectory(atPath: URL.Directories.documents.appendingPathComponent(expected).path, withIntermediateDirectories: true)
        FileManager.default.createFile(
            atPath: URL.Directories.documents.appendingPathComponent(expected).appendingPathComponent(fileName).path,
            contents: "test".data(using: .utf8)
        )
        XCTAssertTrue(testee.isItemAvailableOffline(source: source))

        try? FileManager.default.removeItem(atPath: URL.Directories.documents.appendingPathComponent(expected).path)
        XCTAssertFalse(testee.isItemAvailableOffline(source: source))
    }

    private func getPrivatePath() -> (OfflineFileSource, String) {
        let sessionId = "sessionId"
        let courseId = "courseId"
        let sectionName = "sectionName"
        let resourceId = "resourceId"
        let fileId = "fileId"
        let source = OfflineFileSource.privateFile(sessionID: sessionId, courseID: courseId, sectionName: sectionName, resourceID: resourceId, fileID: fileId)
        let expected = "\(sessionId)/Offline/course-\(courseId)/\(sectionName)/\(sectionName)-\(resourceId)/file-\(fileId)"
        return (source, expected)
    }
}
