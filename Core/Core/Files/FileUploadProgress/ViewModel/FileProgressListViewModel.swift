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
    public let title = NSLocalizedString("Submission", comment: "")
    public let submissionID: NSManagedObjectID
    public weak var delegate: FileProgressListViewModelDelegate?

    private let dismissSubject = PassthroughSubject<() -> Void, Never>()
    private let presentDialogSubject = PassthroughSubject<UIAlertController, Never>()
    private lazy var fileSubmission: Store<LocalUseCase<FileSubmission>> = {
        let predicate = NSPredicate(format: "SELF = %@", submissionID)
        let scope = Scope(predicate: predicate, order: [])
        let useCase = LocalUseCase<FileSubmission>(scope: scope)
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()
    private let environment: AppEnvironment
    private let flowCompleted: () -> Void
    private var receivedSuccessfulSubmissionNotification = false
    private var subscriptions = Set<AnyCancellable>()
    private var childViewModelUpdateSubscriptions = Set<AnyCancellable>()
    /**
     This variable ensures that once an error is displayed it stays on the screen until the user retries the submission.
     If the user removes the last failed upload item (so only succeeded items remain) we should still display the error.
     */
    private var isErrorDisplayed = false

    /**
     - parameters:
        - dismiss: The block that gets called when the user wants to hide the upload progress UI.
     */
    public init(submissionID: NSManagedObjectID, environment: AppEnvironment = .shared, dismiss: @escaping () -> Void) {
        self.submissionID = submissionID
        self.environment = environment
        self.flowCompleted = dismiss
        fileSubmission.refresh()
    }

    private func showCancelDialog() {
        let title = NSLocalizedString("Cancel Submission?", comment: "")
        let message = NSLocalizedString("This will cancel and delete your upload.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Yes", comment: ""), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismissSubject.send {
                self.delegate?.fileProgressViewModelCancel(self)
            }
        })
        alert.addAction(AlertAction(NSLocalizedString("No", comment: ""), style: .cancel))
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

        childViewModelUpdateSubscriptions.removeAll()
        items = submission.files.map { uploadItem in
            let itemViewModel = FileProgressItemViewModel(file: uploadItem) { [weak self] itemID in
                self?.remove(itemID)
            }

            itemViewModel.objectWillChange.sink { [weak self] _ in
                // TODO: Shouln't we update after the view model has changed?
                self?.updateState()
                self?.updateNavBarButtons()
            }
            .store(in: &childViewModelUpdateSubscriptions)

            return itemViewModel
        }
    }

    private func remove(_ fileUploadItemID: NSManagedObjectID) {
        if items.count > 1 {
            delegate?.fileProgressViewModel(self, delete: fileUploadItemID)
            return
        }

        let title = NSLocalizedString("Remove From List?", comment: "")
        let message = NSLocalizedString("This will cancel and delete your upload.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Yes", comment: ""), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismissSubject.send {
                self.delegate?.fileProgressViewModel(self, delete: fileUploadItemID)
            }
        })
        alert.addAction(AlertAction(NSLocalizedString("No", comment: ""), style: .cancel))
        presentDialogSubject.send(alert)
    }

    private func updateState() {
        guard let submission = fileSubmission.first, !isErrorDisplayed else { return }

        switch submission.state {
        case .waiting:
            state = .waiting
        case .uploading(progress: let progress):
            let format = NSLocalizedString("Uploading %@ of %@", comment: "")
            let uploadedSize = Int(progress * CGFloat(submission.totalSize))
            let progressText = String.localizedStringWithFormat(format, uploadedSize.humanReadableFileSize, submission.totalSize.humanReadableFileSize)
            state = .uploading(progressText: progressText, progress: Float(progress))
        case .failedUpload:
            state = .failed(message: NSLocalizedString("One or more files failed to upload. Check your internet connection and retry to submit.", comment: ""), error: nil)
            isErrorDisplayed = true
        case .failedSubmission(message: let message):
            let format = NSLocalizedString("submission_failed_for_files", comment: "")
            let title = String.localizedStringWithFormat(format, submission.files.count)
            state = .failed(message: title, error: message)
            isErrorDisplayed = true
        case .submitted:
            state = .success
        }
    }

    private func updateNavBarButtons() {
        let cancelButton = BarButtonItemViewModel(title: NSLocalizedString("Cancel", comment: "")) { [weak self] in
            self?.showCancelDialog()
        }
        switch state {
        case .waiting:
            leftBarButton = cancelButton
            rightBarButton = nil
        case .uploading:
            leftBarButton = cancelButton
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Dismiss", comment: "")) { [weak self] in
                self?.flowCompleted()
            }
        case .failed:
            leftBarButton = cancelButton
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Retry", comment: "")) { [weak self] in
                guard let self = self else { return }
                self.isErrorDisplayed = false
                self.delegate?.fileProgressViewModelRetry(self)
            }
        case .success:
            leftBarButton = nil
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Done", comment: "")) { [weak self] in
                self?.flowCompleted()
            }
        }
    }
}
