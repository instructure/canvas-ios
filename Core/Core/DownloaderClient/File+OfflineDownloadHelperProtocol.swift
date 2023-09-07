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

import mobile_offline_downloader_ios

extension File: OfflineDownloadTypeProtocol {
    public static func canDownload(entry: OfflineDownloaderEntry) -> Bool {
        return entry.dataModel.type.lowercased().contains(OfflineContentType.file.rawValue)
    }

    public static func prepareForDownload(entry: OfflineDownloaderEntry) async throws {
        if entry.dataModel.type == OfflineContentType.file.rawValue {
            do {
                let file = try File.fromOfflineModel(entry.dataModel)
                if let url = file.url {
                    DispatchQueue.main.async {
                        entry.parts.removeAll()
                        entry.addURLPart(url.absoluteString)
                    }
                }
            } catch {
                throw FileError.cantGetFile(data: entry.dataModel, error: error)
            }
        }
    }

    public func downloaderEntry() throws -> OfflineDownloaderEntry {
        let model = try self.toOfflineModel()
        return OfflineDownloaderEntry(dataModel: model, parts: [])
    }

    public static func isCritical(error: Error) -> Bool {
        switch error {
        case FileError.cantGetFile,
            OfflineEntryPartDownloaderError.cantDownloadLinkPart:
            return true
        default:
            return false
        }
    }
    
    public static func replaceHTML(tag: String?) -> String? {
        nil
    }
}

extension File {
    enum FileError: Error, LocalizedError {
        case cantGetFile(data: OfflineStorageDataModel, error: Error)

        var errorDescription: String? {
            switch self {
            case let .cantGetFile(data, error):
                return "Can't get file for data: \(data.json). Error: \(error)"
            }
        }
    }
}
