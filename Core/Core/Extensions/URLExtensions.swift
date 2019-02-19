//
// Copyright (C) 2018-present Instructure, Inc.
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

extension URL {
    public static func temporarySubmissionDirectoryPath() throws -> URL {
        var path = URL(fileURLWithPath: NSTemporaryDirectory())
        path.appendPathComponent("submissions")
        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        return path
    }

    public func lookupFileSize() -> Int64 {
        guard self.isFileURL else { return 0 }
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        let fileSize = attributes?[FileAttributeKey.size] as? Int64
        return fileSize ?? 0
    }

    public func appendingQueryItems(_ items: URLQueryItem...) -> URL {
        var components = URLComponents.parse(self)
        components.queryItems = (components.queryItems ?? []) + items
        return components.url ?? self
    }
}
