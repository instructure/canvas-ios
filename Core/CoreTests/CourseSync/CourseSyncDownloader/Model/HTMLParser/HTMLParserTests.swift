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

@testable import Core
import XCTest
import Foundation
import Combine

class HTMLParserTests: CoreTestCase {
    var testee: HTMLParser!
    let testCourseId: String = "1"
    let testResourceId: String = "2"
    var subscriptions: [AnyCancellable] = []

    func testReplacingLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

        let baseURL = URL(string: "https://instructure.com")
        let urlToDownload = URL(string: "https://instructure.com/logo.png")!
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload.absoluteString)">
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                XCTAssertTrue(interactor.fileNames.contains(urlToDownload.lastPathComponent))

                XCTAssertFalse(result.contains("https://instructure.com/logo.png"))
                XCTAssertTrue(result.contains(URL.Directories.documents.appendingPathComponent(urlToDownload.lastPathComponent).lastPathComponent))
            })
            .store(in: &subscriptions)
    }

    func testReplacingRelativeLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

        let baseURL = URL(string: "https://www.instructure.com")!
        let urlToDownload = "https://www.instructure.com/logo.png"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        some simple text
        <a href="/some_image.png">Relative test</a>
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                XCTAssertFalse(result.contains("<a href=\"/some_image.png\">Relative test</a>"))
                XCTAssertTrue(result.contains("<a href=\"https://www.instructure.com/some_image.png\">Relative test</a>"))
            })
            .store(in: &subscriptions)
    }

    func testSavingBaseContent() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

        let baseURL = URL(string: "https://www.instructure.com")
        let urlToDownload = "https://www.instructure.com/logo.png"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        """

        let rootURL = URL.Directories.documents.appendingPathComponent(
                URL.Paths.Offline.courseSectionFolder(
                    sessionId: environment.currentSession!.uniqueID,
                    courseId: testCourseId,
                    sectionName: interactor.sectionName
                )
            )
            .appendingPathComponent("\(interactor.sectionName)-\(testResourceId)")

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(interactor.savedBaseContents.count, 1)
                XCTAssertEqual(interactor.savedBaseContents.first!, rootURL)
            })
            .store(in: &subscriptions)
    }

    func testFileDownload() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

        let baseURL = URL(string: "https://adamdomonkos.instructure.com")
        let urlToDownload1 = "https://adamdomonkos.instructure.com/files/1"
        let urlToDownload2 = "https://adamdomonkos.instructure.com/files/2"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload1)">
        <a class="instructure_file_link" href="\(urlToDownload2)">
        """
        api.mock(GetFile(context: Context(url: URL(string: urlToDownload1)!), fileID: "1"), value: APIFile.make(url: URL(string: "https://www.instructure.com/logo1.png")!))
        api.mock(GetFile(context: Context(url: URL(string: urlToDownload2)!), fileID: "2"), value: APIFile.make(url: URL(string: "https://www.instructure.com/logo2.png")!))

        let rootURL = URL.Directories.documents.appendingPathComponent(
                URL.Paths.Offline.courseSectionFolder(
                    sessionId: environment.currentSession!.uniqueID,
                    courseId: testCourseId,
                    sectionName: interactor.sectionName
                )
            )
            .appendingPathComponent("\(interactor.sectionName)-\(testResourceId)")

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(interactor.savedBaseContents.count, 1)
                XCTAssertEqual(interactor.savedBaseContents.first!, rootURL)
            })
            .store(in: &subscriptions)
    }

    func testDownloadAttachment() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)
        let downloadURL = URL(string: "https://adamdomonkos.instructure.com/files/1")!

        testee.downloadAttachment(downloadURL, courseId: "1", resourceId: "1")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(interactor.fileNames.count, 1)
                XCTAssertEqual(interactor.fileNames.first, downloadURL.lastPathComponent)
            })
            .store(in: &subscriptions)
    }

    func testParseExtensionFunctionParseHtmlContent() {
        let htmlParser = HTMLParserMock()
        let pages = [Page.make(from: APIPage.make(body: "body1", page_id: "1")), Page.make(from: APIPage.make(body: "body2", page_id: "2"))]
        Just(pages)
            .setFailureType(to: Error.self)
            .parseHtmlContent(attribute: \.body, id: \.id, courseId: "1", htmlParser: htmlParser)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(htmlParser.parsedContents.count, 2)
                XCTAssertTrue(htmlParser.parsedContents.contains("body1"))
                XCTAssertTrue(htmlParser.parsedContents.contains("body2"))
            })
            .store(in: &subscriptions)
    }

    func testParseExtensionFunctionParseAttachment() {
        let htmlParser = HTMLParserMock()
        let discussionEntries = [
            DiscussionEntry.make(from:
                                    APIDiscussionEntry(
                                        id: "1",
                                        user_id: nil,
                                        editor_id: nil,
                                        parent_id: nil,
                                        created_at: nil,
                                        updated_at: nil,
                                        rating_sum: nil,
                                        replies: nil,
                                        attachment: APIFile.make(id: "1", url: URL(string: "https://adamdomonkos.instructure.com/files/1")!), deleted: nil)
                                ),
            DiscussionEntry.make(from:
                                    APIDiscussionEntry(
                                        id: "2",
                                        user_id: nil,
                                        editor_id: nil,
                                        parent_id: nil,
                                        created_at: nil,
                                        updated_at: nil,
                                        rating_sum: nil,
                                        replies: nil,
                                        attachment: APIFile.make(id: "2", url: URL(string: "https://adamdomonkos.instructure.com/files/2")!), deleted: nil)
                                )
        ]
        Just(discussionEntries)
            .setFailureType(to: Error.self)
            .parseAttachment(attribute: \.attachment, topicId: "1", courseId: "1", htmlParser: htmlParser)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(htmlParser.parsedAttachments.count, 2)
                XCTAssertTrue(htmlParser.parsedAttachments.contains(URL(string: "https://adamdomonkos.instructure.com/files/1")!))
                XCTAssertTrue(htmlParser.parsedAttachments.contains(URL(string: "https://adamdomonkos.instructure.com/files/2")!))
            })
            .store(in: &subscriptions)
    }

    func testParseExtensionFunctionParseAttachmentForSet() {
        let htmlParser = HTMLParserMock()
        let discussionTopics = [
            DiscussionTopic.make(from:
                                    APIDiscussionTopic(
                                        allow_rating: false,
                                        anonymous_state: nil,
                                        assignment: nil,
                                        assignment_id: nil,
                                        attachments: [
                                            APIFile.make(id: "1", url: URL(string: "https://adamdomonkos.instructure.com/files/1")!),
                                            APIFile.make(id: "2", url: URL(string: "https://adamdomonkos.instructure.com/files/2")!)
                                        ],
                                        author: nil,
                                        can_unpublish: nil,
                                        created_at: nil,
                                        context_code: nil,
                                        delayed_post_at: nil,
                                        discussion_subentry_count: 0,
                                        discussion_type: nil,
                                        group_category_id: nil,
                                        group_topic_children: nil,
                                        html_url: nil,
                                        id: "1",
                                        is_section_specific: false,
                                        last_reply_at: nil,
                                        locked_for_user: false,
                                        lock_at: nil,
                                        only_graders_can_rate: nil,
                                        permissions: nil,
                                        pinned: nil,
                                        position: nil,
                                        posted_at: nil,
                                        published: true,
                                        require_initial_post: nil,
                                        sections: nil,
                                        sort_by_rating: false,
                                        subscribed: nil,
                                        subscription_hold: nil,
                                        unread_count: nil
                                    )
                                )
        ]
        Just(discussionTopics)
            .setFailureType(to: Error.self)
            .parseAttachment(attribute: \.attachments, id: \.id, courseId: "1", htmlParser: htmlParser)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(htmlParser.parsedAttachments.count, 2)
                XCTAssertTrue(htmlParser.parsedAttachments.contains(URL(string: "https://adamdomonkos.instructure.com/files/1")!))
                XCTAssertTrue(htmlParser.parsedAttachments.contains(URL(string: "https://adamdomonkos.instructure.com/files/2")!))
            })
            .store(in: &subscriptions)
    }

    func testParseExtensionFunctionParseRepliesHtmlContent() {
        let htmlParser = HTMLParserMock()
        let discussionEntries = [
            DiscussionEntry.make(from:
                                    APIDiscussionEntry(
                                        id: "1",
                                        user_id: nil,
                                        editor_id: nil,
                                        parent_id: nil,
                                        created_at: nil,
                                        updated_at: nil,
                                        message: "message1",
                                        rating_sum: nil,
                                        replies: [
                                            APIDiscussionEntry(
                                                id: "2",
                                                user_id: nil,
                                                editor_id: nil,
                                                parent_id: nil,
                                                created_at: nil,
                                                updated_at: nil,
                                                message: "message2",
                                                rating_sum: nil,
                                                replies: nil,
                                                attachment: APIFile.make(id: "2", url: URL(string: "https://adamdomonkos.instructure.com/files/2")!), deleted: nil
                                            )
                                        ],
                                        attachment: APIFile.make(id: "1", url: URL(string: "https://adamdomonkos.instructure.com/files/1")!), deleted: nil)
                                )
        ]
        Just(discussionEntries)
            .setFailureType(to: Error.self)
            .parseRepliesHtmlContent(courseId: "1", topicId: "1", htmlParser: htmlParser)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(htmlParser.parsedContents.count, 1)
                XCTAssertTrue(htmlParser.parsedContents.contains("message2"))
            })
            .store(in: &subscriptions)
    }

    class HTMLParserMock: HTMLParser {
        var sessionId: String = "mockSessionId"

        var sectionName: String = "mockSectionName"

        var parsedContents: [String] = []
        var parsedAttachments: [URL] = []

        func parse(_ content: String, resourceId: String, courseId: String, baseURL: URL?) -> AnyPublisher<String, any Error> {
            parsedContents.append(content)

            return Just(content).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        func downloadAttachment(_ url: URL, courseId: String, resourceId: String) -> AnyPublisher<String, any Error> {
            parsedAttachments.append(url)

            return Just(url.path).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}
