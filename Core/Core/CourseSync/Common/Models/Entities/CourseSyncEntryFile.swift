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

public extension CourseSyncEntry {
    struct File: Equatable {
        /**
         The unique identifier of the sync entry in a form of "courses/:courseId/files/:fileId". Doesn't correspond to the file ID on API. Use the `fileId` property if you need the API id.
         */
        let id: String
        var fileId: String { String(id.split(separator: "/").last ?? "") }
        let displayName: String
        let fileName: String
        let url: URL
        let mimeClass: String
        let updatedAt: Date?
        var state: State = .loading(nil)
        var selectionState: ListCellView.SelectionState = .deselected

        /// Filesize in bytes, received from the API.
        let bytesToDownload: Int

        /// Downloaded bytes, progress is persisted to Core Data.
        var bytesDownloaded: Int {
            switch state {
            case .downloaded: return bytesToDownload
            case let .loading(progress):
                if let progress {
                    return Int(Float(bytesToDownload) * progress)
                } else {
                    return 0
                }
            case .error: return 0
            }
        }
    }
}
