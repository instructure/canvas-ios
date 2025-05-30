//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation
import Core
import Combine

protocol DownloadFileInteractor {
    func download(fileID: String) -> AnyPublisher<URL, Error>
    func download(file: File) -> AnyPublisher<URL, Error>
    func download(remoteURL: URL, fileName: String) -> AnyPublisher<URL, Error>
}

final class DownloadFileInteractorLive: DownloadFileInteractor {
    // MARK: - Dependencies

    private let courseID: String
    private let fileManager: FileManager

    // MARK: - Init

    init(
        courseID: String,
        fileManager: FileManager = .default
    ) {
        self.courseID = courseID
        self.fileManager = fileManager
    }

    func download(fileID: String) -> AnyPublisher<URL, Error> {
        ReactiveStore(
            useCase: GetFile(context: .course(courseID), fileID: fileID)
        )
        .getEntities(ignoreCache: true)
        .flatMap { [weak self] files -> AnyPublisher<URL, Error> in
            guard let self,
                  let file = files.first,
                  let url = file.url
            else {
                return Empty(completeImmediately: true)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let localURL = URL.Directories.documents.appendingPathComponent(file.filename)

            if self.fileManager.fileExists(atPath: localURL.path) {
                return Just(localURL)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            } else {
                return DownloadTaskPublisher(parameters:
                    DownloadTaskParameters(
                        remoteURL: url,
                        localURL: localURL
                    )
                )
                .collect() // Wait until the download is finished.
                .mapToValue(localURL)
                .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    func download(file: File) -> AnyPublisher<URL, Error> {
        let localURL = URL.Directories.documents.appendingPathComponent(file.filename)
        if self.fileManager.fileExists(atPath: localURL.path) {
            return Just(localURL)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        } else {
            return DownloadTaskPublisher(parameters:
                DownloadTaskParameters(
                    remoteURL: file.url!,
                    localURL: localURL
                )
            )
            .collect() // Wait until the download is finished.
            .mapToValue(localURL)
            .eraseToAnyPublisher()
        }
    }

    func download(remoteURL: URL, fileName: String) -> AnyPublisher<URL, Error> {
        let localURL = URL.Directories.documents.appendingPathComponent(fileName)
        if self.fileManager.fileExists(atPath: localURL.path) {
            return Just(localURL)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        } else {
            return DownloadTaskPublisher(parameters:
                DownloadTaskParameters(
                    remoteURL: remoteURL,
                    localURL: localURL
                )
            )
            .collect() // Wait until the download is finished.
            .mapToValue(localURL)
            .eraseToAnyPublisher()
        }
    }
}
