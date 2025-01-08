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

import Foundation

public protocol StudioVideoCacheInteractor {

    /// If the downloaded video's size matches the size we received from the API then we consider the video downloaded.
    func isVideoDownloaded(
        videoLocation: URL,
        expectedSize: Int
    ) -> Bool
}

public class StudioVideoCacheInteractorLive: StudioVideoCacheInteractor {

    /// If the downloaded video's size matches the size we received from the API then we consider the video downloaded.
    public func isVideoDownloaded(
        videoLocation: URL,
        expectedSize: Int
    ) -> Bool {
        guard FileManager.default.fileExists(atPath: videoLocation.path()) else {
            return false
        }

        guard let downloadedVideoSize = try? videoLocation.fileSize() else {
            return false
        }

        return downloadedVideoSize == expectedSize
    }
}
