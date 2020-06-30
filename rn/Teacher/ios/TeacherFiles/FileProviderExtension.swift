//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import FileProvider
import Core

class FileProviderExtension: NSFileProviderExtension {
    let env = AppEnvironment.shared

    override init() {
        super.init()
        env.app = .teacher
        if let session = LoginSession.mostRecent {
            env.userDidLogin(session: session)
        }
    }

    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        if let item: NSFileProviderItem = fileItem(for: identifier) ?? folderItem(for: identifier) {
            return item
        }
        throw NSError.fileProviderErrorForNonExistentItem(withIdentifier: identifier)
    }

    func fileItem(for identifier: NSFileProviderItemIdentifier) -> File? {
        let path = identifier.rawValue.components(separatedBy: "/")
        guard path.count == 2, path[0] == "files" else { return nil }
        return env.database.viewContext.first(where: #keyPath(File.id), equals: path[1])
    }

    func folderItem(for identifier: NSFileProviderItemIdentifier) -> Folder? {
        let path = identifier.rawValue.components(separatedBy: "/")
        guard path.count == 2, path[0] == "folders" else { return nil }
        return env.database.viewContext.first(where: #keyPath(Folder.id), equals: path[1])
    }

    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let identifier = persistentIdentifierForItem(at: url) else {
            return completionHandler(NSFileProviderError(.noSuchItem))
        }
        do {
            try NSFileProviderManager.writePlaceholder(
                at: NSFileProviderManager.placeholderURL(for: url),
                withMetadata: try item(for: identifier)
            )
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let id = persistentIdentifierForItem(at: url), let remoteURL = fileItem(for: id)?.url else {
            return completionHandler(NSFileProviderError(.noSuchItem))
        }
        env.api.makeDownloadRequest(remoteURL) { (tmpURL, _, error) in
            guard let tmpURL = tmpURL, error == nil else {
                return completionHandler(error)
            }
            do {
                try FileManager.default.moveItem(at: tmpURL, to: url)
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }

    override func itemChanged(at url: URL) {}

    override func stopProvidingItem(at url: URL) {
        try? FileManager.default.removeItem(at: url)
        providePlaceholder(at: url) { _ in }
}

    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        return try FileProviderEnumerator(containerItemIdentifier)
    }

    override func fetchThumbnails(
        for itemIdentifiers: [NSFileProviderItemIdentifier],
        requestedSize size: CGSize,
        perThumbnailCompletionHandler: @escaping (NSFileProviderItemIdentifier, Data?, Error?) -> Void,
        completionHandler: @escaping (Error?) -> Void
    ) -> Progress {
        let progress = Progress(totalUnitCount: Int64(itemIdentifiers.count))
        for identifier in itemIdentifiers {
            guard let file = fileItem(for: identifier) else {
                perThumbnailCompletionHandler(identifier, nil, nil)
                progress.completedUnitCount += 1
                continue
            }
            guard let thumbnailURL = file.thumbnailURL else {
                perThumbnailCompletionHandler(identifier, nil, nil)
                progress.completedUnitCount += 1
                continue
            }
            let task = URLSessionAPI.cachingURLSession.dataTask(with: thumbnailURL) { data, _, error in
                guard !progress.isCancelled else { return }
                perThumbnailCompletionHandler(identifier, data, error)
                performUIUpdate {
                    if progress.isFinished { completionHandler(nil) }
                }
            }
            progress.addChild(task.progress, withPendingUnitCount: 1)
            task.resume()
        }
        performUIUpdate {
            if progress.isFinished { completionHandler(nil) }
        }
        return progress
    }
}
