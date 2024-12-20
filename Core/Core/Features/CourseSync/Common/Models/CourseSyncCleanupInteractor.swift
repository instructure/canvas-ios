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

public struct CourseSyncCleanupInteractor {
    private let applicationOfflineFolder: URL
    private let sharedOfflineFolder: URL?

    public init(appGroup: String? = Bundle.main.appGroupID(), session: LoginSession) {
        let sessionId = session.uniqueID

        applicationOfflineFolder = URL
            .Directories
            .documents
            .appendingPathComponent(sessionId, isDirectory: true)
            .appendingPathComponent("Offline", isDirectory: true)

        if let appGroup,
           let sharedContainer = URL.Directories.sharedContainer(appGroup: appGroup) {
            sharedOfflineFolder = sharedContainer
                .appendingPathComponent("Documents", isDirectory: true)
                .appendingPathComponent(sessionId, isDirectory: true)
                .appendingPathComponent("Offline", isDirectory: true)
        } else {
            sharedOfflineFolder = nil
        }
    }

    /// Deletes offline folders with all files inside them on a background thread.
    public func clean() -> AnyPublisher<Void, Never> {
        Just(())
            .receive(on: DispatchQueue.global())
            .handleEvents(receiveOutput: {
                try? FileManager.default.removeItem(at: applicationOfflineFolder)

                if let sharedOfflineFolder {
                    try? FileManager.default.removeItem(at: sharedOfflineFolder)
                }
            })
            .eraseToAnyPublisher()
    }
}
