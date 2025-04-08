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
import Combine
import CombineExt
import XCTest

class PublisherExtensionsTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testBindProgressReportsLoadingStateOnSubscription() {
        // MARK: - GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        let loadingStateReceiver = PassthroughRelay<Bool>()
        let valueExpectation = expectation(description: "Progress status received")
        var receivedProgress: Bool?
        loadingStateReceiver
            .sink { isLoading in
                valueExpectation.fulfill()
                receivedProgress = isLoading
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        publisher
            .bindProgress(loadingStateReceiver)
            .sink()
            .store(in: &subscriptions)

        // MARK: - GIVEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedProgress, true)
    }

    func testBindProgressReportsLoadingFinishOnStreamCompletion() {
        // MARK: - GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        let loadingStateReceiver = PassthroughRelay<Bool>()
        let valueExpectation = expectation(description: "Progress status received")
        var receivedProgress: Bool?
        loadingStateReceiver
            .dropFirst() // ignore loading state
            .sink { isLoading in
                valueExpectation.fulfill()
                receivedProgress = isLoading
            }
            .store(in: &subscriptions)
        publisher
            .bindProgress(loadingStateReceiver)
            .sink()
            .store(in: &subscriptions)

        // MARK: - WHEN
        publisher.send(completion: .finished)

        // MARK: - GIVEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedProgress, false)
    }

    func testStringParsing() {
        let pages = [
            Page.make()
        ]
        let testCourseId: CourseSyncID = "1"
        let parser = HTMLParserMock()

        var testee: AnyPublisher<[Page], Error> {
            Just(pages)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        testee
            .parseHtmlContent(attribute: \.body, id: \.id, courseId: testCourseId, htmlParser: parser)
            .sink(receiveCompletion: { _ in}, receiveValue: { _ in
                XCTAssertTrue(parser.parseCalled)
            })
            .store(in: &subscriptions)
    }

    func testOptionalStringParsing() {
        let discussionTopics = [
            DiscussionTopic.make()
        ]
        let testCourseId: CourseSyncID = "1"
        let parser = HTMLParserMock()

        var testee: AnyPublisher<[DiscussionTopic], Error> {
            Just(discussionTopics)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        testee
            .parseHtmlContent(attribute: \.message, id: \.id, courseId: testCourseId, htmlParser: parser)
            .sink(receiveCompletion: { _ in}, receiveValue: { _ in
                XCTAssertTrue(parser.parseCalled)
            })
            .store(in: &subscriptions)
    }

    class HTMLParserMock: HTMLParser {
        var sessionId: String = "testSession"
        var prefix: String = "testPrefix"
        var sectionName: String = "testSection"
        var parseCalled = false
        var attachmentParseCalled = false
        var envResolver: CourseSyncEnvironmentResolver = .default()

        func parse(_ content: String, resourceId: String, courseId: CourseSyncID, baseURL: URL?) -> AnyPublisher<String, Error> {
            parseCalled = true
            return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        func downloadAttachment(_ url: URL, courseId: CourseSyncID, resourceId: String) -> AnyPublisher<String, any Error> {
            attachmentParseCalled = true
            return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        func sectionFolder(for courseId: CourseSyncID) -> URL {
            envResolver.folderURL(forSection: sectionName, ofCourse: courseId)
        }
    }
}
