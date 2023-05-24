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

protocol LocalFileURLCreator {
    func prepareLocalURL(
        fileName: String,
        mimeClass: String,
        location: URL
    ) -> URL
}

extension LocalFileURLCreator {
    func prepareLocalURL(
        fileName: String,
        mimeClass: String,
        location: URL
    ) -> URL {
        if mimeClass == "pdf" {
            // If the user already downloaded and modified the file locally, we don't want to download it again.
            // Instead, return the url pointing to the locally modified version.
            let docsURL = URL.Directories.documents.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: docsURL.path) { return docsURL }
        }

        return location.appendingPathComponent(fileName)
    }
}
