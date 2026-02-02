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
    public func write(to url: URL? = nil, name: String? = nil) throws -> URL {
        let manager = FileManager.default
        let directory = url ?? URL.Directories
            .temporary
            .appendingPathComponent("PDF_Documents", isDirectory: true)

        let fileName = name ?? Foundation.UUID().uuidString
        try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

        var url = directory.appendingPathComponent(fileName, isDirectory: false)
        url = url.pathExtension != "pdf" ? url.appendingPathExtension("pdf") : url

        guard let data = dataRepresentation() else {
            throw NSError.instructureError(
                String(localized: "Failed to save PDF", bundle: .core)
            )
        }

        if manager.fileExists(atPath: url.path) {
            try manager.removeItem(at: url)
        }

        try data.write(to: url)

        return url
    }
}
