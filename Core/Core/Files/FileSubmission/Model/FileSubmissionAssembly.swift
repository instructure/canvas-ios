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

    let backgroundURLSessionProvider: BackgroundURLSessionProvider
    private let fileSubmissionTargetsRequester: FileSubmissionTargetsRequester
    private let fileSubmissionItemsUploader: FileSubmissionItemsUploadStarter
    private let backgroundSessionCompletion: BackgroundSessionCompletion

    /**
     - parameters:
        - container: The CoreData database.
        - sessionID: The background session identifier. Must be unique for each process (app / share extension).
        - sharedContainerID: The container identifier shared between the app and its extensions. Background URLSession read/write this directory.
        - shareCompleted: This block gets called when the app takes over the management of the upload and the share extension can be closed.
     */
    public init(container: NSPersistentContainer, sessionID: String, sharedContainerID: String, api: API, shareCompleted: (() -> Void)? = nil) {
        /** A background context so we can work with it from any background thread. */
        let backgroundContext = container.newBackgroundContext()
        // If the app takes control of the upload respect what it does in CoreData and discard our context's changes
        backgroundContext.mergePolicy = NSMergePolicy.rollback
        let backgroundSessionCompletion = BackgroundSessionCompletion()
        let fileSubmissionSubmitter = FileSubmissionSubmitter(api: api, context: backgroundContext)
        let cleaner = FileSubmissionCleanup(context: backgroundContext)
        let notificationsSender = SubmissionCompletedNotificationsSender(
            context: backgroundContext,
            notificationManager: NotificationManager.shared
        )
        let uploadProgressObserversCache = FileUploadProgressObserversCache(context: backgroundContext) { fileSubmissionID, fileUploadItemID in
            let observer = FileUploadProgressObserver(context: backgroundContext, fileUploadItemID: fileUploadItemID)
            var subscription: AnyCancellable?
            subscription = observer
                .uploadCompleted.mapError { $0 as Error }
                .flatMap { AllFileUploadFinishedCheck(context: backgroundContext, fileSubmissionID: fileSubmissionID).isAllUploadFinished().mapError { $0 as Error } }
                .flatMap { fileSubmissionSubmitter.submitFiles(fileSubmissionID: fileSubmissionID).mapError { $0 as Error } }
                .flatMap { apiSubmission in notificationsSender.sendSuccessNofitications(fileSubmissionID: fileSubmissionID, apiSubmission: apiSubmission) }
                .flatMap { cleaner.clean(fileSubmissionID: fileSubmissionID) }
                .flatMap { backgroundSessionCompletion.backgroundOperationsFinished() }
                .sink { completion in
                    if case .failure(let error) = completion {
                        if ((error as? FileSubmissionErrors.UploadFinishedCheck) == .uploadFailed ||
                            (error as? FileSubmissionErrors.Submission) == .submissionFailed) {
                        notificationsSender.sendFailedNotification(fileSubmissionID: fileSubmissionID)
                        } else if (error as? FileSubmissionErrors.UploadProgress) == .uploadContinuedInApp {
                            shareCompleted?()
                        }
                    }
                    subscription?.cancel()
                    subscription = nil
                } receiveValue: { _ in }
            return observer
        }
        let backgroundURLSessionProvider = BackgroundURLSessionProvider(sessionID: sessionID, sharedContainerID: sharedContainerID, uploadProgressObserversCache: uploadProgressObserversCache)

        self.backgroundSessionCompletion = backgroundSessionCompletion
        self.backgroundURLSessionProvider = backgroundURLSessionProvider
        self.composer = FileSubmissionComposer(context: backgroundContext)
        self.fileSubmissionTargetsRequester = FileSubmissionTargetsRequester(api: api, context: backgroundContext)
        self.fileSubmissionItemsUploader = FileSubmissionItemsUploadStarter(api: api, context: backgroundContext, backgroundSessionProvider: backgroundURLSessionProvider)
    }

    public func start(fileSubmissionID: NSManagedObjectID) {
        var keepAliveSubscription = Set<AnyCancellable>()
        fileSubmissionTargetsRequester
            .request(fileSubmissionID: fileSubmissionID)
            .flatMap { [fileSubmissionItemsUploader] in fileSubmissionItemsUploader.startUploads(fileSubmissionID: fileSubmissionID) }
            .sink(receiveCompletion: { _ in
                keepAliveSubscription.removeAll()
            }, receiveValue: {})
            .store(in: &keepAliveSubscription)
    }

    /**
     Use this method to pass he completion block received in handleEventsForBackgroundURLSession appdelegate method when the share extension
     is doing background uploading. This method also creates the necessary `URLSession` object that receives delegate method updates.
     */
    public func handleBackgroundUpload(_ completion: @escaping () -> Void) {
        backgroundSessionCompletion.callback = completion
        // This will create the background URLSession
        _ = backgroundURLSessionProvider.session
    }

    /**
     This method deletes the given submisson from CoreData and cancels background file uploads.
     Submission files on the file system remain intact.
     */
    public func cancel(submissionID: NSManagedObjectID) {
        composer.deleteSubmission(submissionID: submissionID)
        backgroundURLSessionProvider.session.invalidateAndCancel()
    }
}

extension FileSubmissionAssembly {
    public static let ShareExtensionSessionID = "com.instructure.icanvas.SubmitAssignment.file-uploads"

    public static func makeShareExtensionAssembly(shareCompleted: (() -> Void)? = nil) -> FileSubmissionAssembly {
        FileSubmissionAssembly(container: AppEnvironment.shared.database,
                               sessionID: ShareExtensionSessionID,
                               sharedContainerID: "group.instructure.shared",
                               api: AppEnvironment.shared.api,
                               shareCompleted: shareCompleted)
    }
}
