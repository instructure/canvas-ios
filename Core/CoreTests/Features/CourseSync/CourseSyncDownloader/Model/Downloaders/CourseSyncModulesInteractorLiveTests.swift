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

@testable import Core
import Foundation
import XCTest

class CourseSyncModulesInteractorLiveTests: CoreTestCase {
    private var testee: CourseSyncModulesInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CourseSyncModulesInteractorLive(pageHtmlParser: getHTMLParser(), quizHtmlParser: getHTMLParser())
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testSuccess() {
        mockModules()
        mockModuleItemSequence()
        mockModuleItems()
        XCTAssertFinish(testee.getModuleItems(courseId: "course-1"))

        let modules: [Module] = databaseClient.fetch()
        XCTAssertEqual(modules.count, 1)
        XCTAssertEqual(modules[0].id, "module-1")
    }

    func testModulesFailure() {
        mockModulesError()
        mockModuleItemSequence()
        mockModuleItems()
        XCTAssertFailure(testee.getModuleItems(courseId: "course-1"))
    }

    func testModuleItemSequenceFailure() {
        mockModules()
        mockModuleItemSequenceError()
        mockModuleItems()
        XCTAssertFailure(testee.getModuleItems(courseId: "course-1"))
    }

    func testModuleItemsFailure() {
        mockModules()
        mockModuleItemSequence()
        mockModuleItemsError()
        XCTAssertFailure(testee.getModuleItems(courseId: "course-1"))
    }

    func testAssociatedModuleItems() {
        api.mock(
            GetPageRequest(context: .course("course-1"), url: "page-1"),
            value: .make(page_id: "page-1", url: "page-1")
        )

        api.mock(
            GetQuizRequest(courseID: "course-1", quizID: "quiz-1"),
            value: .make(id: "quiz-1")
        )

        api.mock(
            GetFileRequest(context: .course("course-1"), fileID: "file-1", include: []),
            value: .make(id: "file-1")
        )

        let folderName = "canvas.instructure.com-1/Offline/Files/course-1/file-1"

        try? FileManager.default.createDirectory(
            at: URL.Directories.documents.appendingPathComponent(folderName),
            withIntermediateDirectories: true
        )
        FileManager.default.createFile(
            atPath: URL.Directories.documents.appendingPathComponent(folderName + "/fileName").path,
            contents: "test".data(using: .utf8)
        )

        let subscription = testee.getAssociatedModuleItems(
            courseId: "course-1",
            moduleItemTypes: [.pages, .quizzes, .files],
            moduleItems: [
                .make(from: .make(id: "file-1", content: .file("file-1"))),
                .make(from: .make(id: "quiz-1", content: .quiz("quiz-1"))),
                .make(from: .make(id: "pages-1", content: .page("page-1")))
            ]
        ).sink()

        let pages: [Page] = databaseClient.fetch()
        let quizzes: [Quiz] = databaseClient.fetch()
        let files: [File] = databaseClient.fetch()

        XCTAssertEqual(pages[0].id, "page-1")
        XCTAssertEqual(quizzes[0].id, "quiz-1")
        XCTAssertEqual(files[0].id, "file-1")

        subscription.cancel()
    }

    private func mockModules() {
        api.mock(
            GetModulesRequest(courseID: "course-1"),
            value: [
                .make(
                    id: "module-1",
                    name: "module-1",
                    items: [
                        .make(id: "module-item-1", module_id: "module-1"),
                        .make(id: "module-item-2", module_id: "module-1")
                    ]
                )
            ]
        )
    }

    private func mockModuleItems() {
        api.mock(
            GetModuleItemsRequest(
                courseID: "course-1",
                moduleID: "module-1", include: [.content_details, .mastery_paths],
                perPage: nil
            ),
            value: [
                .make(id: "module-item-1"),
                .make(id: "module-item-1")
            ]
        )
    }

    private func mockModuleItemSequence() {
        api.mock(
            GetModuleItemSequence(
                courseID: "course-1",
                assetType: .moduleItem,
                assetID: "module-item-1"
            ),
            value: .make(modules: [.make(id: "module-1")])
        )
        api.mock(
            GetModuleItemSequence(
                courseID: "course-1",
                assetType: .moduleItem,
                assetID: "module-item-2"
            ),
            value: .make(modules: [.make(id: "module-1")])
        )
    }

    private func mockModulesError() {
        api.mock(
            GetModulesRequest(courseID: "course-1"),
            error: NSError.instructureError("")
        )
    }

    private func mockModuleItemSequenceError() {
        api.mock(
            GetModuleItemSequence(
                courseID: "course-1",
                assetType: .moduleItem,
                assetID: "module-item-1"
            ),
            error: NSError.instructureError("")
        )
        api.mock(
            GetModuleItemSequence(
                courseID: "course-1",
                assetType: .moduleItem,
                assetID: "module-item-2"
            ),
            error: NSError.instructureError("")
        )
    }

    private func mockModuleItemsError() {
        api.mock(
            GetModuleItemsRequest(
                courseID: "course-1",
                moduleID: "module-1", include: [.content_details, .mastery_paths],
                perPage: nil
            ),
            error: NSError.instructureError("")
        )
    }

    private func getHTMLParser() -> HTMLParser {
        let interactor = HTMLDownloadInteractorMock()
        return HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)
    }
}
