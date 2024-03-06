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

    let loginSession: LoginSession
    let downloadInteractor: HTMLDownloadInteractorLive
    let htmlParser: HTMLParser

    public init() {
        loginSession = AppEnvironment.shared.currentSession!
        downloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession)
        htmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: downloadInteractor)
    }

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers.Zip(
            ReactiveStore(
                useCase: GetFrontPage(
                    context: .course(courseId)
                )
            )
            .getEntities(ignoreCache: true),
            ReactiveStore(
                useCase: GetPages(
                    context: .course(courseId)
                )
            )
            .getEntities(ignoreCache: true)
            .flatMap { pages in
                Publishers.Sequence(sequence: pages)
                    .setFailureType(to: Error.self)
                    .flatMap { page in
                        print("START PARSE")
                        return self.htmlParser.parse(page.body)
                            .map {
                                print("PARSED")
                                return (page, $0)
                            }
                    }
                    .map { (page, parsedBody) in
                        page.body = parsedBody
                        return page
                    }
                    .map { page in
                        if let context = page.managedObjectContext {
                            try? context.save()
                            print("SAVED")
                        }
                    }
                    .collect()
            }
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
