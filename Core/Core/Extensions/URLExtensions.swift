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
    public static func directory(forUser user: KeychainEntry, appGroup: AppGroup? = nil) -> URL {
        let root = appGroup?.url ?? documentsDirectory
        let host = user.baseURL.host ?? "default"
        return root
            .appendingPathComponent(host, isDirectory: true)
            .appendingPathComponent("users", isDirectory: true)
            .appendingPathComponent(user.userID, isDirectory: true)
    }

    public static var documentsDirectory: URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: path)
    }

    public static var temporaryDirectory: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }

    public func lookupFileSize() -> Int {
        guard self.isFileURL else { return 0 }
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        return attributes?[FileAttributeKey.size] as? Int ?? 0
    }

    public func appendingQueryItems(_ items: URLQueryItem...) -> URL {
        var components = URLComponents.parse(self)
        components.queryItems = (components.queryItems ?? []) + items
        return components.url ?? self
    }
}
