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
import SwiftUI

public protocol FileProgressListViewModelDelegate: AnyObject {
    /** Called when the user cancels the upload. The UI is dismissed by the view model. */
    func fileProgressViewModelCancel(_ viewModel: FileProgressListViewModel)
    /** Called when the user taps the retry button after a file upload or the submission API call failed. */
    func fileProgressViewModelRetry(_ viewModel: FileProgressListViewModel)
    /** Called when the user taps the delete button on a file. */
    func fileProgressViewModel(_ viewModel: FileProgressListViewModel, delete file: File)
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
    public let batchID: String
    public weak var delegate: FileProgressListViewModelDelegate?

    private let dismissSubject = PassthroughSubject<() -> Void, Never>()
    private let presentDialogSubject = PassthroughSubject<UIAlertController, Never>()
    private lazy var filesStore = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.update()
    }
    private var failedCount: Int {
        filesStore.reduce(into: 0) { total, file in
            total += (file.uploadError == nil ? 0 : 1)
        }
    }
    private var successCount: Int {
        filesStore.reduce(into: 0) { total, file in
            total += (file.id == nil ? 0 : 1)
        }
    }
    private var allUploadFinished: Bool { failedCount + successCount == filesStore.count }
    private var totalUploadSize: Int { filesStore.reduce(0) { $0 + $1.size } }
    private var uploadedSize: Int { filesStore.reduce(0) { $0 + $1.bytesSent } }
    private let flowCompleted: () -> Void

    /**
     - parameters:
        - dismiss: The block that gets called when the user wants to hide the upload progress UI.
     */
    public init(batchID: String, dismiss: @escaping () -> Void) {
        self.batchID = batchID
        self.flowCompleted = dismiss
        update()
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
        items = filesStore.all.map { file in
            FileProgressItemViewModel(file: file, onRemove: { [weak self] in
                self?.remove(file)
            })
        }
    }

    private func remove(_ file: File) {
        if items.count > 1 {
            delegate?.fileProgressViewModel(self, delete: file)
            return
        }

        let title = NSLocalizedString("Remove From List?", comment: "")
        let message = NSLocalizedString("This will cancel and delete your upload.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Yes", comment: ""), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismissSubject.send {
                self.delegate?.fileProgressViewModel(self, delete: file)
            }
        })
        alert.addAction(AlertAction(NSLocalizedString("No", comment: ""), style: .cancel))
        presentDialogSubject.send(alert)
    }

    private func updateState() {
        if allUploadFinished {
            if failedCount == 0 {
                state = .success
            } else {
                state = .failed
            }
        } else {
            let uploadSize = totalUploadSize
            // This is because sometimes we upload more than the expected
            let uploadedSize = min(uploadSize, uploadedSize)
            let progress = Float(uploadedSize) / Float(uploadSize)
            let format = NSLocalizedString("Uploading %@ of %@", comment: "")
            let progressText = String.localizedStringWithFormat(format, uploadedSize.humanReadableFileSize, uploadSize.humanReadableFileSize)
            state = .uploading(progressText: progressText, progress: progress)
        }
    }

    private func updateNavBarButtons() {
        switch state {
        case .waiting:
            leftBarButton = nil
            rightBarButton = nil
        case .uploading:
            leftBarButton = BarButtonItemViewModel(title: NSLocalizedString("Cancel", comment: "")) { [weak self] in
                self?.showCancelDialog()
            }
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Dismiss", comment: "")) { [weak self] in
                self?.flowCompleted()
            }
        case .failed:
            leftBarButton = BarButtonItemViewModel(title: NSLocalizedString("Cancel", comment: "")) { [weak self] in
                self?.showCancelDialog()
            }
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Retry", comment: "")) { [weak self] in
                self.flatMap { $0.delegate?.fileProgressViewModelRetry($0) }
            }
        case .success:
            leftBarButton = nil
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Done", comment: "")) { [weak self] in
                self?.flowCompleted()
            }
        }
    }
}
