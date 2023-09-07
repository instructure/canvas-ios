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
    public private(set) var composer: FileSubmissionComposer

    let backgroundURLSessionProvider: BackgroundURLSessionProvider
    private let fileSubmissionTargetsRequester: FileSubmissionTargetsRequester
    private let fileSubmissionItemsUploader: FileSubmissionItemsUploadStarter
    private let backgroundSessionCompletion: BackgroundSessionCompletion
    /** A background context so we can work with it from any background thread. */
    private let backgroundContext: NSManagedObjectContext
    private let submissionPreparation: FileSubmissionPreparation
    /** We use this to fetch changes in the persistent store made by out-of-process activities. */
    private let interprocessContextChangeListener: AnyCancellable

    /**
     - parameters:
        - container: The CoreData database.
        - sessionID: The background session identifier. Must be unique for each process (app / share extension).
        - sharedContainerID: The container identifier shared between the app and its extensions. Background URLSession read/write this directory.
     */
    public init(container: NSPersistentContainer, sessionID: String, sharedContainerID: String, api: API) {
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

            let backgroundActivity = BackgroundActivity(processManager: ProcessInfo.processInfo, abortHandler: {
                subscription?.cancel()
                subscription = nil
                BackgroundActivityTerminationHandler(context: backgroundContext, notificationsSender: notificationsSender)
                    .handleTermination(fileUploadItemID: fileUploadItemID)
            })

            subscription = observer
                .uploadCompleted.mapError { $0 as Error }
                .flatMap { AllFileUploadFinishedCheck(context: backgroundContext, fileSubmissionID: fileSubmissionID).isAllUploadFinished().mapError { $0 as Error } }
                .flatMap { backgroundActivity.start().mapError { $0 as Error } }
                .flatMap { fileSubmissionSubmitter.submitFiles(fileSubmissionID: fileSubmissionID).mapError { $0 as Error } }
                .flatMap { apiSubmission in notificationsSender.sendSuccessNofitications(fileSubmissionID: fileSubmissionID, apiSubmission: apiSubmission) }
                .flatMap { cleaner.clean(fileSubmissionID: fileSubmissionID) }
                .flatMap { backgroundSessionCompletion.backgroundOperationsFinished() }
                .mapError { error -> Error in
                    if error.shouldSendFailedNotification {
                        notificationsSender.sendFailedNotification(fileSubmissionID: fileSubmissionID)
                    }
                    return error
                }
                .sink { _ in
                    backgroundActivity.stopAndWait()
                    subscription?.cancel()
                    subscription = nil
                } receiveValue: { _ in }
            return observer
        }
        let backgroundURLSessionProvider = BackgroundURLSessionProvider(sessionID: sessionID, sharedContainerID: sharedContainerID, uploadProgressObserversCache: uploadProgressObserversCache)

        self.submissionPreparation = FileSubmissionPreparation(context: backgroundContext)
        self.backgroundContext = backgroundContext
        self.backgroundSessionCompletion = backgroundSessionCompletion
        self.backgroundURLSessionProvider = backgroundURLSessionProvider
        self.composer = FileSubmissionComposer(context: backgroundContext)
        self.fileSubmissionTargetsRequester = FileSubmissionTargetsRequester(api: api, context: backgroundContext)
        self.fileSubmissionItemsUploader = FileSubmissionItemsUploadStarter(api: api, context: backgroundContext, backgroundSessionProvider: backgroundURLSessionProvider)

        interprocessContextChangeListener = InterprocessNotificationCenter.shared
            .subscribe(forName: NSPersistentStore.InterProcessNotifications.didModifyExternally)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    backgroundContext.forceRefreshAllObjects()
                }
            )
    }

    public func start(fileSubmissionID: NSManagedObjectID) {
        submissionPreparation.prepare(submissionID: fileSubmissionID)

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

    /**
     This method sets the `isHiddenOnDashboard` parameter on the submission to `true` so when
     the user returns to the app it doesn't need to dismiss the dashboard notification again.
     */
    public func markSubmissionAsDone(submissionID: NSManagedObjectID) {
        backgroundContext.performAndWait {
            guard let submission = try? backgroundContext.existingObject(with: submissionID) as? FileSubmission else { return }
            submission.isHiddenOnDashboard = true
            try? backgroundContext.saveAndNotify()
        }
    }
}

extension FileSubmissionAssembly {
    public static let ShareExtensionSessionID = "com.instructure.icanvas.2u.SubmitAssignment.file-uploads"

    public static func makeShareExtensionAssembly() -> FileSubmissionAssembly {
        FileSubmissionAssembly(container: AppEnvironment.shared.database,
                               sessionID: ShareExtensionSessionID,
                               sharedContainerID: "group.instructure.shared.2u",
                               api: AppEnvironment.shared.api)
    }
}
