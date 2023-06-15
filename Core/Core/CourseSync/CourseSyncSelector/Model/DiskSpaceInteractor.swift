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

struct DiskSpace {
    let total: Int64
    let available: Int64
    var used: Int64 {
        app + otherApps
    }

    let app: Int64
    let otherApps: Int64
}

protocol DiskSpaceInteractor {
    func getDiskSpace() -> DiskSpace
}

final class DiskSpaceInteractorLive: DiskSpaceInteractor {
    func getDiskSpace() -> DiskSpace {
        let (total, available) = getTotalAndAvailableSpace()
        let app = getAppSpace()
        return DiskSpace(
            total: total,
            available: available,
            app: app,
            otherApps: total - available - app
        )
    }

    private func getTotalAndAvailableSpace() -> (Int64, Int64) {
        let url = URL(fileURLWithPath: NSHomeDirectory() as String)
        let keys: Set<URLResourceKey> = [
            URLResourceKey.volumeTotalCapacityKey,
            URLResourceKey.volumeAvailableCapacityKey,
        ]

        guard
            let values = try? url.resourceValues(forKeys: keys),
            let total = values.volumeTotalCapacity,
            let free = values.volumeAvailableCapacity
        else {
            return (0, 0)
        }

        return (Int64(total), Int64(free))
    }

    private func getAppSpace() -> Int64 {
        var paths = [Bundle.main.bundlePath]
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dir = documentDirectory.first {
            paths.append(dir)
        }
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        if let dir = libraryDirectory.first {
            paths.append(dir)
        }
        paths.append(NSTemporaryDirectory() as String)

        var totalSize: Int64 = 0
        for path in paths {
            totalSize += byteSize(of: path)
        }

        return totalSize
    }

    private func byteSize(of directory: String) -> Int64 {
        var size: Int64 = 0
        let fm = FileManager.default
        if let subdirectories = try? fm.subpathsOfDirectory(atPath: directory) {
            subdirectories.forEach { fileName in
                let fileDictionary = try? fm.attributesOfItem(atPath: directory.appending("/" + fileName)) as NSDictionary
                size += Int64(fileDictionary?.fileSize() ?? 0)
            }
        }

        return size
    }
}
