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
import CoreData
import Foundation

public protocol CourseSyncFilesInteractor {
    func getFile(
        url: URL,
        fileID: String,
        fileName: String,
        mimeClass: String,
        updatedAt: Date?
    ) -> AnyPublisher<Float, Error>
}

public final class CourseSyncFilesInteractorLive: CourseSyncFilesInteractor, LocalFileURLCreator {
    private let env: AppEnvironment
    private let fileManager: FileManager
    private let offlineFileInteractor: OfflineFileInteractor

    public init(
        env: AppEnvironment = .shared,
        fileManager: FileManager = .default,
        offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive()
    ) {
        self.env = env
        self.fileManager = fileManager
        self.offlineFileInteractor = offlineFileInteractor
    }

    public func getFile(
        url: URL,
        fileID: String,
        fileName: String,
        mimeClass: String,
        updatedAt: Date?
    ) -> AnyPublisher<Float, Error> {
        guard let sessionID = env.currentSession?.uniqueID else {
            return Fail(error:
                NSError.instructureError(
                    NSLocalizedString(
                        "There was an unexpected error. Please try again.",
                        bundle: .core,
                        comment: ""
                    )
                )
            )
            .eraseToAnyPublisher()
        }

        let localURL = prepareLocalURL(
            fileName: offlineFileInteractor.filePath(sessionID: sessionID, fileID: fileID, fileName: fileName),
            mimeClass: mimeClass,
            location: URL.Directories.documents
        )

        if fileManager.fileExists(atPath: localURL.path),                               // File exists on the disk
           let fileModificationDate = fileManager.fileModificationDate(url: localURL),
           let updatedAt = updatedAt,                                                   // and
           fileModificationDate >= updatedAt {                                          // is up to date
            return Just(1)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
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
}
