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

import Foundation

public struct CourseSyncDownloadProgress {
    let bytesToDownload: Int
    let bytesDownloaded: Int
    let isFinished: Bool
    let error: String?

    var progress: Float {
        Float(bytesDownloaded) / Float(bytesToDownload)
    }

    init(
        bytesToDownload: Int,
        bytesDownloaded: Int,
        isFinished: Bool,
        error: String?
    ) {
        self.bytesToDownload = bytesToDownload
        self.bytesDownloaded = bytesDownloaded
        self.isFinished = isFinished
        self.error = error
    }

    init(from entity: CourseSyncDownloadProgressEntity) {
        bytesToDownload = entity.bytesToDownload
        bytesDownloaded = entity.bytesDownloaded
        isFinished = entity.isFinished
        error = entity.error
    }
}

extension CourseSyncDownloadProgress {
    static func make(
        bytesToDownload: Int = 1000,
        bytesDownloaded: Int = 100,
        isFinished: Bool = false,
        error: String? = nil
    ) -> CourseSyncDownloadProgress {
        .init(
            bytesToDownload: bytesToDownload,
            bytesDownloaded: bytesDownloaded,
            isFinished: isFinished,
            error: error
        )
    }
}
