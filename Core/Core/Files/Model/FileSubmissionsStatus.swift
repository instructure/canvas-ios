//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

/**
 This is an in-memory, thread-safe storage to keep track of which files are being uploaded.
 */
class FileSubmissionsStatus {
    private var inProgressSubmissions: [String] = []
    private let accessQueue = DispatchQueue(label: "Synchronized Array Access")

    func addTasks(fileIDs: [String]) {
        accessQueue.sync {
            inProgressSubmissions.append(contentsOf: fileIDs)
        }
    }

    func removeTasks(fileIDs: [String]) {
        accessQueue.sync {
            for fileID in fileIDs {
                if let index = inProgressSubmissions.firstIndex(of: fileID) {
                    inProgressSubmissions.remove(at: index)
                }
            }
        }
    }

    /**
        - Returns: `true` if one ID from the given `fileIDs` array is still in progress.
     */
    func isUploadInProgress(fileIDs: [String]) -> Bool {
        var result = false

        accessQueue.sync {
            result = fileIDs.contains { inProgressSubmissions.contains($0) }
        }

        return result
    }
}
