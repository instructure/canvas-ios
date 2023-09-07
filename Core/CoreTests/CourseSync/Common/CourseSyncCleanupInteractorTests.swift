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

import Core
import XCTest

class CourseSyncCleanupInteractorTests: XCTestCase {

    func testSharedOfflineDirectoryForUserDeleted() throws {
        // MARK: - GIVEN
        // MARK: This should be deleted
        let mockSession = LoginSession.make(baseURL: URL(string: "https://test.instructure.com")!, userID: "testUserID")
        let dbURL = URL.Directories.databaseURL(appGroup: "group.com.instructure.icanvas.2u", session: mockSession)
        try write("test", to: dbURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbURL.path))

        // MARK: This user's files should be left intact
        let anotherMockSession = LoginSession.make(baseURL: URL(string: "https://test.instructure.com")!, userID: "testUserID2")
        let anotherDbURL = URL.Directories.databaseURL(appGroup: "group.com.instructure.icanvas.2u", session: anotherMockSession)
        try write("test", to: anotherDbURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: anotherDbURL.path))

        // MARK: - WHEN
        let testee = CourseSyncCleanupInteractor(appGroup: "group.com.instructure.icanvas.2u", session: mockSession)
        XCTAssertFinish(testee.clean())

        // MARK: - THEN
        XCTAssertFalse(FileManager.default.fileExists(atPath: dbURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: anotherDbURL.path))
    }

    func testApplicationOfflineDirectoryForUserDeleted() throws {
        // MARK: - GIVEN
        // MARK: This should be deleted
        let mockSession = LoginSession.make(baseURL: URL(string: "https://test.instructure.com")!, userID: "testUserID")
        let dbURL = URL.Directories.documents.appendingPathComponent("\(mockSession.uniqueID)/Offline/Files/fileFolder/image.jpg")
        try write("test", to: dbURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbURL.path))

        // MARK: This user's files should be left intact
        let anotherMockSession = LoginSession.make(baseURL: URL(string: "https://test.instructure.com")!, userID: "testUserID2")
        let anotherDbURL = URL.Directories.documents.appendingPathComponent("\(anotherMockSession.uniqueID)/Offline/Files/fileFolder/image.jpg")
        try write("test", to: anotherDbURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: anotherDbURL.path))

        // MARK: - WHEN
        let testee = CourseSyncCleanupInteractor(appGroup: nil, session: mockSession)
        XCTAssertFinish(testee.clean())

        // MARK: - THEN
        XCTAssertFalse(FileManager.default.fileExists(atPath: dbURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: anotherDbURL.path))
    }

    private func write(_ string: String, to file: URL) throws {
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try string.data(using: .utf8)!.write(to: file)
    }
}
