//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import Combine
import CombineExt

class AttachmentPickerViewModel: ObservableObject {

    // MARK: Inputs / Outputs

    @Published public var isAttachmentSelectorVisible: Bool = false
    @Published public var isFilePickerVisible: Bool = false
    @Published public var isImagePickerVisible: Bool = false
    @Published public var isTakePhotoVisible: Bool = false
    @Published public var isAudioRecordVisible: Bool = false
    @Published public private(set) var fileList: [File] = []
    @Published public var isFileErrorOccured: Bool = false
    public let title = NSLocalizedString("Attachments", comment: "")
    public let fileErrorTitle = NSLocalizedString("Error", comment: "")
    public let fileErrorMessage = NSLocalizedString("Failed to add attachment. Please try again!", comment: "")
    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let doneButtonDidTap = PassthroughRelay<WeakViewController>()
    public let uploadButtonDidTap = PassthroughRelay<WeakViewController>()
    public let retryButtonDidTap = PassthroughRelay<WeakViewController>()
    public let addAttachmentButtonDidTap = PassthroughRelay<WeakViewController>()
    public let router: Router

    // MARK: Private

    private let uploadManager: UploadManager
    private var subscriptions = Set<AnyCancellable>()
    private let batchId: String
    private lazy var files = uploadManager.subscribe(batchID: batchId) { [weak self] in
        self?.update()
    }

    public init (router: Router, batchId: String, uploadManager: UploadManager = UploadManager(identifier: UUID.string)) {
        self.router = router
        self.batchId = batchId
        self.uploadManager = uploadManager

        update()
        setupInputBindings(router: router)
    }

    private func update() {
        fileList = files.all
    }

    private func showDialog(viewController: WeakViewController) {
        let sheet = BottomSheetPickerViewController.create()

        sheet.addAction(
            image: .documentLine,
            title: NSLocalizedString("Upload file", bundle: .core, comment: ""),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isFilePickerVisible = true
        }
        sheet.addAction(
            image: .imageLine,
            title: NSLocalizedString("Upload photo", bundle: .core, comment: ""),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isImagePickerVisible = true
        }
        sheet.addAction(
            image: .cameraLine,
            title: NSLocalizedString("Take photo", bundle: .core, comment: ""),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isTakePhotoVisible = true
        }
        sheet.addAction(
            image: .audioLine,
            title: NSLocalizedString("Record audio", bundle: .core, comment: ""),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isAudioRecordVisible = true
        }
        router.show(sheet, from: viewController, options: .modal())
    }

    func showFileErrorDialog() {
        let actionTitle = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title: fileErrorTitle, message: fileErrorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
            self?.isImagePickerVisible = false
            self?.isTakePhotoVisible = false
            self?.isFilePickerVisible = false
            self?.isAudioRecordVisible = false
        }
        alert.addAction(action)

        if let top = AppEnvironment.shared.window?.rootViewController?.topMostViewController() {
            router.show(alert, from: top, options: .modal())
        }
    }

    func fileSelected(url: URL) {
        do {
            isImagePickerVisible = false
            isTakePhotoVisible = false
            isFilePickerVisible = false
            isAudioRecordVisible = false

            try uploadManager.add(url: url, batchID: batchId)
            files.refresh()
        } catch {
            showFileErrorDialog()
        }
    }

    func fileRemoved(file: File) {
        uploadManager.viewContext.delete(file)
        files.refresh()
    }

    private func uploadAttachments() {
        files.all.forEach { file in
            if !file.isUploaded {
                uploadManager.upload(file: file, to: .myFiles, folderPath: "conversation attachments")
            }
        }
    }

    private func retryUpload() {
        uploadAttachments()
    }

    private func cancelUnPublishedFiles() {
        files.all.forEach {file in
            if !file.isUploaded {
                fileRemoved(file: file)
                uploadManager.cancel(file: file)
            }
        }
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [weak self, router] viewController in
                self?.cancelUnPublishedFiles()
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        doneButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        uploadButtonDidTap
            .sink { [weak self] _ in
                self?.uploadAttachments()
            }
            .store(in: &subscriptions)

        retryButtonDidTap
            .sink { [weak self] _ in
                self?.retryUpload()
            }
            .store(in: &subscriptions)

        addAttachmentButtonDidTap
            .sink { [weak self] viewController in
                self?.showDialog(viewController: viewController)
            }
            .store(in: &subscriptions)
    }
}
