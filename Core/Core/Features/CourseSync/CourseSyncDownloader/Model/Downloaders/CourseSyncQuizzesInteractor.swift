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
import CombineExt
import Foundation

public protocol CourseSyncQuizzesInteractor: CourseSyncContentInteractor {}
public extension CourseSyncQuizzesInteractor {
    var associatedTabType: TabName { .quizzes }
}

public final class CourseSyncQuizzesInteractorLive: CourseSyncQuizzesInteractor, CourseSyncContentInteractor {
    let htmlParser: HTMLParser

    public init(htmlParser: HTMLParser) {
        self.htmlParser = htmlParser
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        Publishers.Zip(
            getCustomColors(courseId: courseId),
            getQuizzes(courseId: courseId)
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        let rootURL = URL.Paths.Offline.courseSectionFolderURL(
            courseId: courseId,
            sectionName: htmlParser.sectionName
        )

        return FileManager.default.removeItemPublisher(at: rootURL)
    }

    private func getCustomColors(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetCustomColors(),
            environment: courseId.targetEnvironment
        )
        .getEntities(ignoreCache: true)
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private func getQuizzes(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetQuizzes(courseID: courseId.localID),
            environment: courseId.targetEnvironment
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.details, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
        .flatMap { [htmlParser] in
            $0.publisher
                .filter { $0.quizType != .quizzes_next }
                .flatMap { Self.getQuiz(courseId: courseId, quizId: $0.id, htmlParser: htmlParser) }
                .collect()
        }
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private static func getQuiz(courseId: CourseSyncID, quizId: String, htmlParser: HTMLParser) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetQuiz(courseID: courseId.localID, quizID: quizId),
            environment: courseId.targetEnvironment
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.details, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
        .mapToVoid()
        .eraseToAnyPublisher()
    }
}
