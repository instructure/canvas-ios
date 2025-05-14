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
import Foundation

public protocol CourseSyncDiscussionsInteractor: CourseSyncContentInteractor {}
public extension CourseSyncDiscussionsInteractor {
    var associatedTabType: TabName { .discussions }
}

public class CourseSyncDiscussionsInteractorLive: CourseSyncDiscussionsInteractor, CourseSyncHtmlContentInteractor {
    public let htmlParser: HTMLParser

    public init(htmlParser: HTMLParser) {
        self.htmlParser = htmlParser
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        Self.fetchTopics(courseId: courseId, htmlParser: htmlParser)
            .flatMap { $0.publisher }
            .filter { $0.discussionSubEntryCount > 0 && $0.anonymousState == nil }
            .flatMap { [htmlParser] in Self.getDiscussionView(courseId: courseId, topicId: $0.id, htmlParser: htmlParser) }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        let rootURLTopic = htmlParser.sectionFolder(for: courseId)
        let rootURLView = htmlParser.sectionFolder(for: courseId)
        return Publishers.Zip(
            FileManager.default.removeItemPublisher(at: rootURLTopic),
            FileManager.default.removeItemPublisher(at: rootURLView)
        ).mapToVoid().eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private static func fetchTopics(
        courseId: CourseSyncID,
        htmlParser: HTMLParser
    ) -> AnyPublisher<[DiscussionTopic], Error> {

        return ReactiveStore(
            useCase: GetDiscussionTopics(context: courseId.asContext),
            environment: htmlParser.envResolver.targetEnvironment(for: courseId)
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.message, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
        .parseAttachment(attribute: \.attachments, id: \.id, courseId: courseId, htmlParser: htmlParser)
        .eraseToAnyPublisher()
    }

    private static func getDiscussionView(
        courseId: CourseSyncID,
        topicId: String,
        htmlParser: HTMLParser
    ) -> AnyPublisher<Void, Error> {

        return ReactiveStore(
            useCase: GetDiscussionView(context: courseId.asContext, topicID: topicId),
            environment: htmlParser.envResolver.targetEnvironment(for: courseId)
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.message, id: \.id, courseId: courseId, htmlParser: htmlParser)
        .parseAttachment(attribute: \.attachment, topicId: topicId, courseId: courseId, htmlParser: htmlParser)
        .parseRepliesHtmlContent(courseId: courseId, topicId: topicId, htmlParser: htmlParser)
        .mapToVoid()
        .eraseToAnyPublisher()
    }
}
