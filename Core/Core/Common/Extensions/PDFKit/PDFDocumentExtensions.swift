//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import PDFKit

extension PDFDocument {

    @discardableResult
    public func write(to url: URL? = nil, nameIt name: String? = nil) throws -> URL {
        let directory = url ?? URL.Directories.temporary.appendingPathComponent("documents", isDirectory: true)
        let name = name ?? String(Clock.now.timeIntervalSince1970)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let url = directory.appendingPathComponent(name, isDirectory: false).appendingPathExtension("pdf")
        guard let data = dataRepresentation() else {
            throw NSError.instructureError(String(localized: "Failed to save pdf", bundle: .core))
        }
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try data.write(to: url)
        return url
    }
}
