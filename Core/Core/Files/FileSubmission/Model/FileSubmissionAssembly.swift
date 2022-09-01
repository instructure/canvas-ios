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

public class FileSubmissionAssembly {
    public let composer: FileSubmissionComposer
    public let backgroundURLSessionProvider: BackgroundURLSessionProvider

    /** This is a background context so we can work with it from any background thread. */
    private let backgroundContext: NSManagedObjectContext
    private let uploadProgressObserversCache: FileUploadProgressObserversCache

    /**
     - parameters:
        - container: The CoreData database.
        - sessionID: The background session identifier. Must be unique for each process (app / share extension).
        - sharedContainerID: The container identifier shared between the app and its extensions. Background URLSession read/write this directory.
     */
    public init(container: NSPersistentContainer, sessionID: String, sharedContainerID: String) {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy.overwrite
        let uploadProgressObserversCache = FileUploadProgressObserversCache(context: backgroundContext)
        self.backgroundContext = backgroundContext
        composer = FileSubmissionComposer(context: backgroundContext)
        backgroundURLSessionProvider = BackgroundURLSessionProvider(sessionID: sessionID, sharedContainerID: sharedContainerID, uploadProgressObserversCache: uploadProgressObserversCache)
        self.uploadProgressObserversCache = uploadProgressObserversCache
    }
}
