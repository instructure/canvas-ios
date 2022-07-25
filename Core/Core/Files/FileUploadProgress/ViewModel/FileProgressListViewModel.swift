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

import SwiftUI

public protocol FileProgressListViewModelDelegate: AnyObject {
    /** Called when the user wants to hide the upload dialog during an upload or when all upload is finished and the user taps the done button. */
    func fileProgressViewModelDidDismiss(_ viewModel: FileProgressListViewModel)
    /** Called when the user cancels the upload. */
    func fileProgressViewModelDidCancel(_ viewModel: FileProgressListViewModel)
    /** Called when the user taps the retry button after a file upload or the submission API call failed. */
    func fileProgressViewModelDidRetry(_ viewModel: FileProgressListViewModel)
}

public class FileProgressListViewModel: FileProgressListViewModelProtocol {
    @Published public private(set) var items: [FileProgressViewModel] = []
    @Published public private(set) var state: FileProgressListViewState = .waiting
    @Published public private(set) var leftBarButton: BarButtonItemViewModel?
    @Published public private(set) var rightBarButton: BarButtonItemViewModel?
    public let title = NSLocalizedString("Submission", comment: "")
    public weak var delegate: FileProgressListViewModelDelegate?

    private lazy var filesStore = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.update()
    }
    private let batchID: String
    private var env: AppEnvironment?
    private var controller = WeakViewController()
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

    public init(batchID: String) {
        self.batchID = batchID
        update()
    }

    public func setupViewEnvironment(env: AppEnvironment, controller: WeakViewController) {
        self.env = env
        self.controller = controller
    }

    private func showCancelDialog() {
        let title = NSLocalizedString("Cancel Submission?", comment: "")
        let message = NSLocalizedString("This will cancel and delete your upload.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Yes", comment: ""), style: .destructive) { [weak self] _ in
            self.flatMap {
                $0.delegate?.fileProgressViewModelDidCancel($0)
                $0.env?.router.dismiss($0.controller)
            }
        })
        alert.addAction(AlertAction(NSLocalizedString("No", comment: ""), style: .cancel))
        env?.router.show(alert, from: controller.value, options: .modal())
    }

    private func update() {
        updateFilesList()
        updateState()
        updateNavBarButtons()
    }

    private func updateFilesList() {
        items = filesStore.all.map { FileProgressViewModel(file: $0) }
    }

    private func updateState() {
        if allUploadFinished {
            if failedCount == 0 {
                state = .success
            } else {
                state = .failed
            }
        } else {
            let progress = Float(uploadedSize) / Float(totalUploadSize)
            let format = NSLocalizedString("Uploading %@ of %@", comment: "")
            let progressText = String.localizedStringWithFormat(format, uploadedSize.humanReadableFileSize, totalUploadSize.humanReadableFileSize)
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
                self.flatMap { $0.delegate?.fileProgressViewModelDidDismiss($0) }
            }
        case .failed:
            leftBarButton = BarButtonItemViewModel(title: NSLocalizedString("Cancel", comment: "")) { [weak self] in
                self?.showCancelDialog()
            }
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Retry", comment: "")) { [weak self] in
                self.flatMap { $0.delegate?.fileProgressViewModelDidRetry($0) }
            }
        case .success:
            leftBarButton = nil
            rightBarButton = BarButtonItemViewModel(title: NSLocalizedString("Done", comment: "")) { [weak self] in
                self.flatMap { $0.delegate?.fileProgressViewModelDidDismiss($0) }
            }
        }
    }
}
