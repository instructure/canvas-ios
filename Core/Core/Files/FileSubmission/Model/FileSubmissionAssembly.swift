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

import Combine
import CoreData

public class FileSubmissionAssembly {
    public let composer: FileSubmissionComposer

    /** This is a background context so we can work with it from any background thread. */
    private let backgroundContext: NSManagedObjectContext
    private let backgroundURLSessionProvider: BackgroundURLSessionProvider
    private let uploadProgressObserversCache: FileUploadProgressObserversCache
    private let fileSubmissionTargetsRequester: FileSubmissionTargetsRequester
    private let fileSubmissionItemsUploader: FileSubmissionItemsUploader

    /**
     - parameters:
        - container: The CoreData database.
        - sessionID: The background session identifier. Must be unique for each process (app / share extension).
        - sharedContainerID: The container identifier shared between the app and its extensions. Background URLSession read/write this directory.
     */
    public init(container: NSPersistentContainer, sessionID: String, sharedContainerID: String, api: API) {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy.overwrite
        let uploadProgressObserversCache = FileUploadProgressObserversCache(context: backgroundContext) { fileSubmissionID, fileUploadItemID in
            let observer = FileUploadProgressObserver(context: backgroundContext, fileUploadItemID: fileUploadItemID)
            var subscription: AnyCancellable?
            subscription = observer.completion.flatMap { _ in
                AllFileUploadFinishedCheck(context: backgroundContext, fileSubmissionID: fileSubmissionID)
                    .checkFileUploadFinished()
                    .flatMap { _ in
                        FileSubmissionSubmitter(api: api, context: backgroundContext, fileSubmissionID: fileSubmissionID)
                            .submitFiles()
                    }
            }.sink { _ in
                subscription?.cancel()
                subscription = nil
            } receiveValue: { _ in }

            return observer
        }
        let backgroundURLSessionProvider = BackgroundURLSessionProvider(sessionID: sessionID, sharedContainerID: sharedContainerID, uploadProgressObserversCache: uploadProgressObserversCache)

        self.composer = FileSubmissionComposer(context: backgroundContext)
        self.backgroundContext = backgroundContext
        self.backgroundURLSessionProvider = backgroundURLSessionProvider
        self.uploadProgressObserversCache = uploadProgressObserversCache
        self.fileSubmissionTargetsRequester = FileSubmissionTargetsRequester(api: api, context: backgroundContext)
        self.fileSubmissionItemsUploader = FileSubmissionItemsUploader(api: api, context: backgroundContext, backgroundSessionProvider: backgroundURLSessionProvider)
    }

    public func start(fileSubmissionID: NSManagedObjectID) {
        var keepAliveSubscription = Set<AnyCancellable>()
        fileSubmissionTargetsRequester
            .request(fileSubmissionID: fileSubmissionID)
            .flatMap { [fileSubmissionItemsUploader] _ in
                fileSubmissionItemsUploader
                    .startUploads(fileSubmissionID: fileSubmissionID)
            }
            .sink(receiveCompletion: { _ in
                keepAliveSubscription.removeAll()
            }, receiveValue: {})
            .store(in: &keepAliveSubscription)
    }
}
