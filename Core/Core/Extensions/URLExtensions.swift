//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

extension URL {
    public static var temporaryDirectory: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }

    public static var cachesDirectory: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    public static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public static var libraryDirectory: URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }

    public static func sharedContainer(_ identifier: String) -> URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
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

    public func appendingOrigin(_ origin: String) -> URL {
        return appendingQueryItems(.init(name: "origin", value: origin))
    }

    public func move(to destination: URL, override: Bool = true, copy: Bool = false) throws {
        let manager = FileManager.default
        if destination.hasDirectoryPath {
            try manager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        } else {
            try manager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        if override && manager.fileExists(atPath: destination.path) {
            try manager.removeItem(at: destination)
        }
        if copy {
            try manager.copyItem(at: self, to: destination)
        } else {
            try manager.moveItem(at: self, to: destination)
        }
    }

    public func copy(to destination: URL, override: Bool = true) throws {
        try move(to: destination, override: override, copy: true)
    }

    public var withCanonicalQueryParams: URL? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.withCanonicalQueryParams.url
    }
}
