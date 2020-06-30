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

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    let env = AppEnvironment.shared
    var identifier: NSFileProviderItemIdentifier

    init(_ identifier: NSFileProviderItemIdentifier) throws {
        if (identifier == .workingSet) {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError)
        }
        self.identifier = identifier
        super.init()
    }

    func invalidate() {
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        if (identifier == .rootContainer) {
            let getFolders = GetRootFolders()
            getFolders.fetch(force: true) { (_, _, error) in performUIUpdate {
                if let error = error {
                    return observer.finishEnumeratingWithError(error)
                }
                let folders: [Folder] = self.env.database.viewContext.fetch(scope: getFolders.scope)
                observer.didEnumerate(folders)
                observer.finishEnumerating(upTo: nil)
            } }
            return
        }
        let path = identifier.rawValue.components(separatedBy: "/")
        if path.count == 2, path[0] == "folders" {
            let group = DispatchGroup()
            var err: Error?
            group.enter()
            let getFolders = GetFolders(context: Context(.folder, id: path[1]))
            getFolders.fetch(force: true) { (_, _, error) in performUIUpdate {
                err = err ?? error
                let folders: [Folder] = self.env.database.viewContext.fetch(scope: getFolders.scope)
                if !folders.isEmpty {
                    observer.didEnumerate(folders)
                }
                group.leave()
            } }
            group.enter()
            let getFiles = GetFolderFiles(folderID: path[1])
            getFiles.fetch(force: true) { (_, _, error) in performUIUpdate {
                err = err ?? error
                let files: [File] = self.env.database.viewContext.fetch(scope: getFiles.scope)
                if !files.isEmpty {
                    observer.didEnumerate(files)
                }
                group.leave()
            } }
            group.notify(queue: .main) { observer.finishEnumerating(upTo: nil) }
            return
        }
        observer.finishEnumerating(upTo: nil)
    }

    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
         observer.finishEnumeratingWithError(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
    }
}
