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
import Combine
import SwiftUI

public protocol FileProgressListViewModelDelegate: AnyObject {
    /** Called when the user cancels the upload. The UI is dismissed by the view model. */
    func fileProgressViewModelCancel(_ viewModel: FileProgressListViewModel)
    /** Called when the user taps the retry button after a file upload or the submission API call failed. */
    func fileProgressViewModelRetry(_ viewModel: FileProgressListViewModel)
    /** Called when the user taps the delete button on a file. */
    func fileProgressViewModel(_ viewModel: FileProgressListViewModel, delete fileUploadItemID: NSManagedObjectID)
    /** Called when the user taps the Done button after a successful upload. */
    func fileProgressViewModel(_ viewModel: FileProgressListViewModel, didAcknowledgeSuccess fileSubmissionID: NSManagedObjectID)
}

/**
 This view model observes file uploads but doesn't control the upload's business logic. Callbacks for the business logic updates are delivered via delegate methods.
 */
public class FileProgressListViewModel: FileProgressListViewModelProtocol {
    public private(set) lazy var dismiss: AnyPublisher<() -> Void, Never> = dismissSubject.eraseToAnyPublisher()
    public private(set) lazy var presentDialog: AnyPublisher<UIAlertController, Never> = presentDialogSubject.eraseToAnyPublisher()
    @Published public private(set) var items: [FileProgressItemViewModel] = []
    @Published public private(set) var state: FileProgressListViewState = .waiting
    @Published public private(set) var leftBarButton: BarButtonItemViewModel?
    @Published public private(set) var rightBarButton: BarButtonItemViewModel?
    public let title = String(localized: "Submission", bundle: .core)
    public let submissionID: NSManagedObjectID
    public weak var delegate: FileProgressListViewModelDelegate?

    private let dismissSubject = PassthroughSubject<() -> Void, Never>()
    private let presentDialogSubject = PassthroughSubject<UIAlertController, Never>()
    /** This is to update our state when the FileSubmission object changes. */
    private lazy var fileSubmission: Store<LocalUseCase<FileSubmission>> = {
        let predicate = NSPredicate(format: "SELF = %@", submissionID)
        let scope = Scope(predicate: predicate, order: [])
        let useCase = LocalUseCase<FileSubmission>(scope: scope)
        return Store(env: environment, context: localViewContext, useCase: useCase) { [weak self] in
            self?.update()
        }
    }()
    /** This is to update our state when the FileSubmission's items change. */
    private lazy var fileUploadItems: Store<LocalUseCase<FileUploadItem>> = {
        let predicate = NSPredicate(format: "fileSubmission = %@", submissionID)
        let scope = Scope(predicate: predicate, order: [])
        let useCase = LocalUseCase<FileUploadItem>(scope: scope)
        return Store(env: environment, context: localViewContext, useCase: useCase) { [weak self] in
            self?.update()
        }
    }()
    private let environment: AppEnvironment
    private let flowCompleted: () -> Void
    private var receivedSuccessfulSubmissionNotification = false
    private var subscriptions = Set<AnyCancellable>()
    /**
     This variable ensures that once an error is displayed it stays on the screen until the user retries the submission.
     If the user removes the last failed upload item (so only succeeded items remain) we should still display the error.
     */
    private var isErrorDisplayed = false
    /**
     When an upload happens we force refresh quite often the view context to get changes made by out-of-process activities,
     so we use this local context to avoid refreshing the whole app each time.
     */
    private let localViewContext: NSManagedObjectContext

    /**
     - parameters:
        - dismiss: The block that gets called when the user wants to hide the upload progress UI.
     */
    public init(submissionID: NSManagedObjectID, environment: AppEnvironment = .shared, dismiss: @escaping () -> Void) {
        self.submissionID = submissionID
        self.environment = environment
        self.flowCompleted = dismiss
        self.localViewContext = {
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = environment.database.persistentStoreCoordinator
            context.automaticallyMergesChangesFromParent = true
            return context
        }()

        fileSubmission.refresh()
        fileUploadItems.refresh()

        InterprocessNotificationCenter.shared
            .subscribe(forName: NSPersistentStore.InterProcessNotifications.didModifyExternally)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak fileSubmission, weak fileUploadItems, weak localViewContext] in
                    localViewContext?.forceRefreshAllObjects()
                    try? fileSubmission?.forceFetchObjects()
                    try? fileUploadItems?.forceFetchObjects()
                }
            )
            .store(in: &subscriptions)
    }

    private func showCancelDialog() {
        let title = String(localized: "Cancel Submission?", bundle: .core)
        let message = String(localized: "This will cancel and delete your upload.", bundle: .core)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "Yes", bundle: .core), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismissSubject.send {
                self.delegate?.fileProgressViewModelCancel(self)
            }
        })
        alert.addAction(AlertAction(String(localized: "No", bundle: .core), style: .cancel))
        presentDialogSubject.send(alert)
    }

    private func update() {
        updateFilesList()
        updateState()
        updateNavBarButtons()
    }

    private func updateFilesList() {
        guard let submission = fileSubmission.first else {
            items = []
            return
        }

        items = submission.files.map { uploadItem in
            FileProgressItemViewModel(file: uploadItem) { [weak self] itemID in
                self?.remove(itemID)
            }
        }
    }

    private func remove(_ fileUploadItemID: NSManagedObjectID) {
        if items.count > 1 {
            delegate?.fileProgressViewModel(self, delete: fileUploadItemID)
            return
        }

        let title = String(localized: "Remove From List?", bundle: .core)
        let message = String(localized: "This will cancel and delete your upload.", bundle: .core)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "Yes", bundle: .core), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismissSubject.send {
                self.delegate?.fileProgressViewModel(self, delete: fileUploadItemID)
            }
        })
        alert.addAction(AlertAction(String(localized: "No", bundle: .core), style: .cancel))
        presentDialogSubject.send(alert)
    }

    private func updateState() {
        guard let submission = fileSubmission.first,
              !isErrorDisplayed,
              state != .success // After we reached success state we don't allow the UI to go back, no matter what changes in CoreData.
        else { return }

        switch submission.state {
        case .waiting:
            state = .waiting
        case .uploading:
            let format = String(localized: "Uploading %@ of %@", bundle: .core)

            let progress: Float
            let totalUploadedSize: Int
            if submission.totalSize > 0 {
                totalUploadedSize = submission.totalUploadedSize > submission.totalSize ?
                    submission.totalSize :
                    submission.totalUploadedSize

                progress = min(Float(totalUploadedSize) / Float(submission.totalSize), 1.0)
            } else {
                progress = 0
                totalUploadedSize = 0
            }

            let progressText = String.localizedStringWithFormat(
                format,
                totalUploadedSize.humanReadableFileSize,
                submission.totalSize.humanReadableFileSize
            )
            state = .uploading(progressText: progressText, progress: progress)
        case .failedUpload:
            state = .failed(message: String(localized: "One or more files failed to upload. Check your internet connection and retry to submit.", bundle: .core), error: nil)
            isErrorDisplayed = true
        case .failedSubmission(message: let message):
            let format = String(localized: "submission_failed_for_files", bundle: .core)
            let title = String.localizedStringWithFormat(format, submission.files.count)
            state = .failed(message: title, error: message)
            isErrorDisplayed = true
        case .submitted:
            state = .success
        }
    }

    private func updateNavBarButtons() {
        let cancelButton = BarButtonItemViewModel(title: String(localized: "Cancel", bundle: .core)) { [weak self] in
            self?.showCancelDialog()
        }
        switch state {
        case .waiting:
            leftBarButton = cancelButton
            rightBarButton = nil
        case .uploading:
            leftBarButton = cancelButton
            rightBarButton = BarButtonItemViewModel(title: String(localized: "Dismiss", bundle: .core)) { [weak self] in
                self?.flowCompleted()
            }
        case .failed:
            leftBarButton = cancelButton
            rightBarButton = BarButtonItemViewModel(title: String(localized: "Retry", bundle: .core)) { [weak self] in
                guard let self = self else { return }
                self.delegate?.fileProgressViewModelRetry(self)
                self.isErrorDisplayed = false
            }
        case .success:
            leftBarButton = nil
            rightBarButton = BarButtonItemViewModel(title: String(localized: "Done", bundle: .core)) { [weak self] in
                guard let self = self else { return }
                self.delegate?.fileProgressViewModel(self, didAcknowledgeSuccess: self.submissionID)
                self.flowCompleted()
            }
        }
    }
}
