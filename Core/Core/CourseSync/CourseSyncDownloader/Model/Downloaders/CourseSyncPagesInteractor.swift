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

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers.Zip(
            ReactiveStore(
                useCase: GetFrontPage(
                    context: .course(courseId)
                )
            )
            .getEntities(ignoreCache: true)
            .parseHtmlContent(attribute: \.body, htmlParser: htmlParser)
            .map { (pages: [Page]) in
                pages.map { (page: Page) in
                    let saveURL = URL.Directories.documents.appendingPathComponent("pages-\(page.id)-body.html")
                    do {
                        try page.body.write(to: saveURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            },

            ReactiveStore(
                useCase: GetPages(
                    context: .course(courseId)
                )
            )
            .getEntities(ignoreCache: true)
            .parseHtmlContent(attribute: \.body, htmlParser: htmlParser)
            // TODO: remove if we use original replacing
            .map { (pages: [Page]) in
                pages.map { (page: Page) in
                    let saveURL = URL.Directories.documents.appendingPathComponent("pages-\(page.id)-body.html")
                    do {
                        try page.body.write(to: saveURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
