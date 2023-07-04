//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import CoreData

extension UploadManager {

    /**
     Copies the file at `url` to the background session's shared container (or if not available then to the temp directory).
     - returns: The new url of the file.
     */
    public func copyFileToSharedContainer(_ url: URL) throws -> URL {
        let dir: URL
        if let containerID = backgroundSession.configuration.sharedContainerIdentifier,
           let container = URL.Directories.sharedContainer(appGroup: containerID) {
            dir = container
        } else {
            dir = URL.Directories.temporary
        }
        let newURL = dir
            .appendingPathComponent("uploads", isDirectory: true)
            .appendingPathComponent(UUID.string, isDirectory: true)
            .appendingPathComponent(url.lastPathComponent)
        try url.copy(to: newURL)
        return newURL
    }

    /**
     Creates a CoreData `File` in the database, assigns the given `url` to it and updates its size. If there's an active session then assigns a user object to the file.
     */
    @discardableResult
    @objc
    public func add(url: URL, batchID: String) throws -> File {
        let file: File = viewContext.insert()
        let uploadURL = try self.copyFileToSharedContainer(url)
        file.filename = url.lastPathComponent
        file.localFileURL = uploadURL
        file.batchID = batchID
        file.size = uploadURL.lookupFileSize()
        if let session = environment.currentSession {
            file.user = File.User(id: session.userID, baseURL: session.baseURL, masquerader: session.masquerader)
        }
        try viewContext.save()
        return file
    }

    /**
     Removes the matching `File` from the context and tries to delete the assigned file from the local storage.
     */
    func delete(userID: String, batchID: String, in context: NSManagedObjectContext) {
        context.performAndWait {
            let files: [File] = context.fetch(predicate(userID: userID, batchID: batchID))
            for file in files {
                guard let url = file.localFileURL else { continue }
                try? FileManager.default.removeItem(at: url)
            }
            context.delete(files)
            try? context.save()
        }
    }
}
