//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class CacheManager {
    public static let shared = CacheManager()

    public private(set) var lastDeletedAt: Date? {
        get { return UserDefaults.standard.object(forKey: "lastDeletedAt") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastDeletedAt") }
    }

    public func deleteAll() throws {
        try deleteCaches()
        try deleteDocuments()
        lastDeletedAt = Clock.now
    }

    public func deleteCaches() throws {
        try deleteFilesInDirectory(.cachesDirectory)
    }

    public func deleteDocuments() throws {
        try deleteFilesInDirectory(.documentsDirectory)
    }

    private func deleteFilesInDirectory(_ directory: URL) throws {
        let fs = FileManager.default
        let urls = try fs.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        for url in urls {
            try fs.removeItem(at: url)
        }
    }
}
