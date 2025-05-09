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
    func getModuleItems(courseId: CourseSyncID) -> AnyPublisher<[ModuleItem], Error>
    func getAssociatedModuleItems(courseId: CourseSyncID, moduleItemTypes: Set<TabName>, moduleItems: [ModuleItem]) -> AnyPublisher<Void, Error>
}

public final class CourseSyncModulesInteractorLive: CourseSyncModulesInteractor {
    private let filesInteractor: CourseSyncFilesInteractor
    private let pageHtmlParser: HTMLParser
    private let quizHtmlParser: HTMLParser
    private let envResolver: CourseSyncEnvironmentResolver

    public init(
        filesInteractor: CourseSyncFilesInteractor = CourseSyncFilesInteractorLive(),
        pageHtmlParser: HTMLParser,
        quizHtmlParser: HTMLParser,
        envResolver: CourseSyncEnvironmentResolver
    ) {
        self.filesInteractor = filesInteractor
        self.pageHtmlParser = pageHtmlParser
        self.quizHtmlParser = quizHtmlParser
        self.envResolver = envResolver
    }

    public func getModuleItems(courseId: CourseSyncID) -> AnyPublisher<[ModuleItem], Error> {
        ReactiveStore(
            useCase: GetModules(courseID: courseId.localID),
            environment: envResolver.targetEnvironment(for: courseId)
        )
        .getEntities(ignoreCache: true)
        .flatMap { $0.publisher }
        .flatMap { [envResolver] in
            Self.getModuleItemSequence(courseID: courseId, moduleItems: $0.items, envResolver: envResolver)
        }
        .collect()
        .map { $0.flatMap { $0 } }
        .eraseToAnyPublisher()
    }

    private static func getModuleItemSequence(
        courseID: CourseSyncID,
        moduleItems: [ModuleItem],
        envResolver: CourseSyncEnvironmentResolver
    ) -> AnyPublisher<[ModuleItem], Error> {
        moduleItems.publisher
            .flatMap {
                ReactiveStore(
                    useCase: GetModuleItemSequence(
                        courseID: courseID.localID,
                        assetType: .moduleItem,
                        assetID: $0.id
                    ),
                    environment: envResolver.targetEnvironment(for: courseID)
                )
                .getEntities(ignoreCache: true)
            }
            .collect()
            .map { _ in moduleItems }
            .eraseToAnyPublisher()
    }

    public func getAssociatedModuleItems(
        courseId: CourseSyncID,
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
        courseId: CourseSyncID,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        let urls = moduleItems.compactMap { $0.type?.pageUrl }

        return urls.publisher
            .flatMap { [pageHtmlParser, envResolver] in
                ReactiveStore(
                    useCase: GetPage(context: courseId.asContext, url: $0),
                    environment: envResolver.targetEnvironment(for: courseId)
                )
                .getEntities(ignoreCache: true)
                .parseHtmlContent(attribute: \.body, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: pageHtmlParser)
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func getModuleQuizzes(
        courseId: CourseSyncID,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        let ids = moduleItems.compactMap { $0.type?.quizzId }

        return ids.publisher
            .flatMap { [quizHtmlParser, envResolver] in
                ReactiveStore(
                    useCase: GetQuiz(courseID: courseId.localID, quizID: $0),
                    environment: envResolver.targetEnvironment(for: courseId)
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
        courseId: CourseSyncID,
        moduleItems: [ModuleItem]
    ) -> AnyPublisher<Void, Error> {
        let ids = moduleItems.compactMap { $0.type?.fileId }

        return ids.publisher
            .flatMap { [envResolver] in
                ReactiveStore(
                    useCase: GetFile(context: courseId.asContext, fileID: $0),
                    environment: envResolver.targetEnvironment(for: courseId)
                )
                .getEntities(ignoreCache: true)
                .flatMap { [filesInteractor, envResolver] files -> AnyPublisher<Void, Error> in
                    guard let file = files.first, let url = file.url, let fileID = file.id, let mimeClass = file.mimeClass else {
                        return Empty(completeImmediately: true)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return filesInteractor.downloadFile(
                        courseId: courseId.value,
                        url: url,
                        fileID: fileID,
                        fileName: file.filename,
                        mimeClass: mimeClass,
                        updatedAt: file.updatedAt,
                        environment: envResolver.targetEnvironment(for: courseId)
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
