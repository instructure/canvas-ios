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

protocol CourseSyncFilesInteractor {
    func getFile(
        url: URL,
        fileID: String,
        fileName: String,
        mimeClass: String
    ) -> AnyPublisher<Float, Error>
}

final class CourseSyncFilesInteractorLive: CourseSyncFilesInteractor, LocalFileURLCreator {
    private let env: AppEnvironment
    private let fileManager: FileManager

    public init(
        env: AppEnvironment = .shared,
        fileManager: FileManager = .default
    ) {
        self.env = env
        self.fileManager = fileManager
    }

    func getFile(
        url: URL,
        fileID: String,
        fileName: String,
        mimeClass: String
    ) -> AnyPublisher<Float, Error> {
        guard let sessionID = env.currentSession?.uniqueID else {
            return Empty()
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let localURL = prepareLocaleURL(
            fileName: "\(sessionID)/\(fileID)/\(fileName)",
            mimeClass: mimeClass
        )

        if fileManager.fileExists(atPath: localURL.path) {
            return Just(1)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return DownloadTaskPublisher(parameters:
            DownloadTaskParameters(
                remoteURL: url,
                localURL: localURL,
                fileID: fileID
            )
        )
        .eraseToAnyPublisher()
    }
}
