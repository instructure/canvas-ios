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

public protocol CourseSyncModulesInteractor {
    func getModuleItems(courseId: String) -> AnyPublisher<[ModuleItem], Error>
    func getAssociatedModuleItems(courseId: String, moduleItemTypes: Set<TabName>, moduleItems: [ModuleItem]) -> AnyPublisher<Void, Error>
}

public final class CourseSyncModulesInteractorLive: CourseSyncModulesInteractor {
    private let filesInteractor: CourseSyncFilesInteractor
    private let pageHtmlParser: HTMLParser
    private let quizHtmlParser: HTMLParser

    public init(
        filesInteractor: CourseSyncFilesInteractor = CourseSyncFilesInteractorLive(),
        pageHtmlParser: HTMLParser,
        quizHtmlParser: HTMLParser
    ) {
        self.filesInteractor = filesInteractor
        self.pageHtmlParser = pageHtmlParser
        self.quizHtmlParser = quizHtmlParser
    }

    public func getModuleItems(courseId: String) -> AnyPublisher<[ModuleItem], Error> {
        ReactiveStore(
            useCase: GetModules(courseID: courseId)
        )
        .getEntities(ignoreCache: true)
        .flatMap { $0.publisher }
        .flatMap { Self.getModuleItemSequence(courseID: $0.courseID, moduleItems: $0.items) }
        .collect()
        .map { $0.flatMap { $0 } }
        .eraseToAnyPublisher()
    }

    private static func getModuleItemSequence(
        courseID: String,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<[ModuleItem], Error> {
        moduleItems.publisher
            .flatMap {
                ReactiveStore(
                    useCase: GetModuleItemSequence(
                        courseID: courseID,
                        assetType: .moduleItem,
                        assetID: $0.id
                    )
                )
                .getEntities(ignoreCache: true)
            }
            .collect()
            .map { _ in moduleItems }
            .eraseToAnyPublisher()
    }

    public func getAssociatedModuleItems(
        courseId: String,
        moduleItemTypes: Set<TabName>,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        var downloaders: [AnyPublisher<Void, Error>] = []

        for type in moduleItemTypes {
            if type == .pages {
                downloaders.append(getModulePages(courseId: courseId, moduleItems: moduleItems))
            }

            if type == .quizzes {
                downloaders.append(getModuleQuizzes(courseId: courseId, moduleItems: moduleItems))
            }

            if type == .files {
                downloaders.append(getModuleFiles(filesInteractor: filesInteractor, courseId: courseId, moduleItems: moduleItems))
            }
        }

        return downloaders.zip()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func getModulePages(
        courseId: String,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        let urls = moduleItems.compactMap { $0.type?.pageUrl }

        return urls.publisher
            .flatMap { [pageHtmlParser] in
                ReactiveStore(
                    useCase: GetPage(context: .course(courseId), url: $0)
                )
                .getEntities(ignoreCache: true)
                .parseHtmlContent(attribute: \.body, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: pageHtmlParser)
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func getModuleQuizzes(
        courseId: String,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        let ids = moduleItems.compactMap { $0.type?.quizzId }

        return ids.publisher
            .flatMap { [quizHtmlParser] in
                ReactiveStore(
                    useCase: GetQuiz(courseID: courseId, quizID: $0)
                )
                .getEntities(ignoreCache: true)
                .parseHtmlContent(attribute: \.details, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: quizHtmlParser)
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func getModuleFiles(
        filesInteractor: CourseSyncFilesInteractor,
        courseId: String,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        let ids = moduleItems.compactMap { $0.type?.fileId }

        return ids.publisher
            .flatMap {
                ReactiveStore(
                    useCase: GetFile(context: .course(courseId), fileID: $0)
                )
                .getEntities(ignoreCache: true)
                .flatMap { [filesInteractor] files -> AnyPublisher<Void, Error> in
                    guard let file = files.first, let url = file.url, let fileID = file.id, let mimeClass = file.mimeClass else {
                        return Empty(completeImmediately: true)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return filesInteractor.downloadFile(
                        courseId: courseId,
                        url: url,
                        fileID: fileID,
                        fileName: file.filename,
                        mimeClass: mimeClass,
                        updatedAt: file.updatedAt
                    )
                    .collect()
                    .mapToVoid()
                    .eraseToAnyPublisher()
                }
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

private extension ModuleItemType {
    var pageUrl: String? {
        if case let .page(url) = self {
            return url
        } else {
            return nil
        }
    }

    var quizzId: String? {
        if case let .quiz(id) = self {
            return id
        } else {
            return nil
        }
    }

    var fileId: String? {
        if case let .file(id) = self {
            return id
        } else {
            return nil
        }
    }
}
