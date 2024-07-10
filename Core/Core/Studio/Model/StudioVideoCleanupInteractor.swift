//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class StudioVideoCleanupInteractor {
    private let offlineStudioDirectory: URL

    public init(offlineStudioDirectory: URL) {
        self.offlineStudioDirectory = offlineStudioDirectory
    }

    public func removeNoLongerNeededVideos(
        allMediaItemsOnAPI: [APIStudioMediaItem],
        mediaLTIIDsUsedInOfflineMode: [String]
    ) -> AnyPublisher<Void, Error> {
        Just(())
            .tryMap { [offlineStudioDirectory] _ in
                let allItemsInStudioDirectory = try FileManager.default.contentsOfDirectory(
                    at: offlineStudioDirectory,
                    includingPropertiesForKeys: [.isDirectoryKey]
                )
                let subdirectoriesInStudioDirectory = try allItemsInStudioDirectory.filterToDirectories()
                return subdirectoriesInStudioDirectory
            }
            .map { (subdirectoriesInStudioDirectory: [URL]) in
                let mediaIDsToKeep = mediaLTIIDsUsedInOfflineMode.compactMap { mediaLTIID -> String? in
                    guard let apiMediaItem = allMediaItemsOnAPI.first(where: { $0.lti_launch_id == mediaLTIID }) else {
                        return nil
                    }
                    return apiMediaItem.id.value
                }
                return (subdirectoriesInStudioDirectory, mediaIDsToKeep)
            }
            .tryMap { [offlineStudioDirectory] (subdirectoriesInStudioDirectory: [URL], mediaIDsToKeep: [String]) in
                let foldersToRemove = subdirectoriesInStudioDirectory.filter { folder in
                    let relativeFolder = folder.absoluteString.replacingOccurrences(
                        of: offlineStudioDirectory.absoluteString,
                        with: ""
                    )
                    guard let relativeFolderURL = URL(string: relativeFolder) else {
                        return false
                    }
                    guard let mediaIDFromURL = relativeFolderURL.pathComponents.first else {
                        return false
                    }

                    return !mediaIDsToKeep.contains(mediaIDFromURL)
                }
                return foldersToRemove
            }
            .tryMap { (foldersToRemove: [URL]) in
                for videoFolder in foldersToRemove {
                    try FileManager.default.removeItem(at: videoFolder)
                }
                return ()
            }
            .eraseToAnyPublisher()
    }
}
