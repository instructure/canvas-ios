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

public protocol CourseSyncPagesInteractor: CourseSyncContentInteractor {}
public extension CourseSyncPagesInteractor {
    var associatedTabType: TabName { .pages }
}

public final class CourseSyncPagesInteractorLive: CourseSyncPagesInteractor, CourseSyncContentInteractor {
    let htmlParser: HTMLParser

    public init(htmlParser: HTMLParser) {
        self.htmlParser = htmlParser
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        Publishers.Zip(
            ReactiveStore(
                useCase: GetFrontPage(
                    context: courseId.asContext
                ),
                environment: courseId.env
            )
            .getEntities(ignoreCache: true)
            .parseHtmlContent(attribute: \.body, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser),

            ReactiveStore(
                useCase: GetPages(
                    context: courseId.asContext
                ),
                environment: courseId.env
            )
            .getEntities(ignoreCache: true)
            .parseHtmlContent(attribute: \.body, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
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
}
