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

public protocol CourseSyncAnnouncementsInteractor: CourseSyncContentInteractor {}

extension CourseSyncAnnouncementsInteractor {
    public var associatedTabType: TabName { .announcements }
}

public final class CourseSyncAnnouncementsInteractorLive: CourseSyncAnnouncementsInteractor {
    let htmlParser: HTMLParser

    public init(htmlParser: HTMLParser) {
        self.htmlParser = htmlParser
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip4(fetchColors(),
                  fetchCourse(courseId: courseId),
                  fetchAnnouncements(courseId: courseId),
                  fetchFeatureFlags(courseId: courseId))
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func fetchColors() -> AnyPublisher<Void, Error> {
        fetchUseCase(GetCustomColors(), env: .shared)
    }

    private func fetchCourse(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        fetchUseCase(GetCourse(courseID: courseId.id), env: courseId.env)
    }

    private func fetchAnnouncements(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        return ReactiveStore(
            useCase: GetAnnouncements(context: courseId.asContext),
            environment: courseId.env
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.message, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
        .parseAttachment(attribute: \.attachments, id: \.id, courseId: courseId, htmlParser: htmlParser)
        .flatMap { $0.publisher }
        .filter { $0.discussionSubEntryCount > 0 && $0.anonymousState == nil }
        .flatMap { [htmlParser] in Self.getDiscussionView(courseId: courseId, topicId: $0.id, htmlParser: htmlParser) }
        .collect()
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private static func getDiscussionView(
        courseId: CourseSyncID,
        topicId: String,
        htmlParser: HTMLParser
    ) -> AnyPublisher<Void, Error> {
        return ReactiveStore(
            useCase: GetDiscussionView(context: courseId.asContext, topicID: topicId),
            environment: courseId.env
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.message, id: \.id, courseId: courseId, htmlParser: htmlParser)
        .parseAttachment(attribute: \.attachment, topicId: topicId, courseId: courseId, htmlParser: htmlParser)
        .parseRepliesHtmlContent(courseId: courseId, topicId: topicId, htmlParser: htmlParser)
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private func fetchFeatureFlags(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        fetchUseCase(
            GetEnabledFeatureFlags(context: courseId.asContext),
            env: courseId.env
        )
    }

    private func fetchUseCase<U: UseCase>(_ useCase: U, env: AppEnvironment) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        let rootURL = URL.Paths.Offline.courseSectionFolderURL(
            courseId: courseId,
            sectionName: htmlParser.sectionName
        )

        return FileManager.default.removeItemPublisher(at: rootURL)
    }
}
