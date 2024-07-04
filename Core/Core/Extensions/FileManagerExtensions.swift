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
import Combine

extension FileManager {
    func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try self.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }

    func removeItemPublisher(at path: URL) -> AnyPublisher<Void, Never> {
        return Future { promise in
            try? FileManager.default.removeItem(at: path)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    /// This method returns urls for files ending with the specified extension inside a folder (recursively). Directories are not listed.
    func allFiles(
        withExtension: String,
        inDirectory: URL
    ) -> Set<URL> {
        let fileExtension = withExtension.hasPrefix(".") ? withExtension : "." + withExtension
        var filePaths: FileManager.DirectoryEnumerator?

        if #available(iOSApplicationExtension 16.0, *) {
            filePaths = enumerator(atPath: inDirectory.path())
        }

        var files = Set<URL>()

        while let file = filePaths?.nextObject() as? String {
            let fileURL = inDirectory.appendingPathComponent(file)
            let isDirectory = (try? fileURL.resourceValues(forKeys: Set([.isDirectoryKey])).isDirectory) == true

            if !isDirectory, file.hasSuffix(fileExtension) {
                files.insert(fileURL)
            }
        }

        return files
    }
}
