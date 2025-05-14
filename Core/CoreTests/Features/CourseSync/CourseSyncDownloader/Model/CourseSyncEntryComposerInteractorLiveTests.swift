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

import Combine
@testable import Core
import Foundation
import TestsFoundation
import XCTest

class CourseSyncEntryComposerInteractorLiveTests: CoreTestCase {
    func testFileTabAndFilesAreMapped() {
        let mock = CourseSyncFilesInteractorMock()
        let testee = CourseSyncEntryComposerInteractorLive(filesInteractor: mock)
        let course = CourseSyncSelectorCourse.save(
            .make(
                id: "course-id-1",
                name: "course-name-1",
                tabs: [
                    .make(id: "files", label: "tab-files")
                ]
            ),
            in: databaseClient
        )

        XCTAssertSingleOutputEquals(
            testee.composeEntry(from: course, useCache: false),
            CourseSyncEntry(
                name: "course-name-1",
                id: "courses/course-id-1",
                hasFrontPage: false,
                tabs: [
                    .init(
                        id: "courses/course-id-1/tabs/files",
                        name: "tab-files",
                        type: .files
                    ),
                    .init(
                        id: "courses/course-id-1/tabs/additional-content",
                        name: "Additional Content",
                        type: .additionalContent
                    )
                ],
                files: [
                    .init(
                        id: "courses/course-id-1/files/file-1",
                        displayName: "file-displayname-1",
                        fileName: "file-name-1",
                        url: URL(string: "https://canvas.instructure.com/files/1/download")!,
                        mimeClass: "image",
                        updatedAt: Date(timeIntervalSince1970: 1000),
                        bytesToDownload: 1000
                    )
                ]
            )
        )
    }

    func testFilesMappedEvenWithoutFilesTab() {
        let mock = CourseSyncFilesInteractorMock()
        let testee = CourseSyncEntryComposerInteractorLive(filesInteractor: mock)
        let course = CourseSyncSelectorCourse.save(
            .make(
                id: "course-id-1",
                name: "course-name-1",
                tabs: []
            ),
            in: databaseClient
        )

        XCTAssertSingleOutputEquals(
            testee.composeEntry(from: course, useCache: false),
            CourseSyncEntry(
                name: "course-name-1",
                id: "courses/course-id-1",
                hasFrontPage: false,
                tabs: [
                    .init(
                        id: "courses/course-id-1/tabs/additional-content",
                        name: "Additional Content",
                        type: .additionalContent
                    )
                ],
                files: [
                    .init(
                        id: "courses/course-id-1/files/file-1",
                        displayName: "file-displayname-1",
                        fileName: "file-name-1",
                        url: URL(string: "https://canvas.instructure.com/files/1/download")!,
                        mimeClass: "image",
                        updatedAt: Date(timeIntervalSince1970: 1000),
                        bytesToDownload: 1000
                    )
                ]
            )
        )
    }
}

private class CourseSyncFilesInteractorMock: CourseSyncFilesInteractor {
    let filePublisher = PassthroughSubject<[Core.File], Error>()

    func downloadFile(courseId _: String, url _: URL, fileID _: String, fileName _: String, mimeClass _: String, updatedAt _: Date?, environment: AppEnvironment) -> AnyPublisher<Float, Error> {
        Empty(completeImmediately: false).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func getFiles(courseId _: String, useCache _: Bool, environment: AppEnvironment) -> AnyPublisher<[Core.File], Error> {
        Just([
            .make(from: APIFile.make(
                id: "file-1",
                folder_id: 0,
                display_name: "file-displayname-1",
                filename: "file-name-1",
                size: 1000,
                updated_at: Date(timeIntervalSince1970: 1000)
            ))
        ]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func removeUnavailableFiles(courseId _: String, newFileIDs _: [String], environment: AppEnvironment) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
