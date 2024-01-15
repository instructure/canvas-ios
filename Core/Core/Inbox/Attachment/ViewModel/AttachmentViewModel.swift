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

class AttachmentViewModel: ObservableObject {
    @Published public var isAttachmentSelectorVisible: Bool = false
    @Published public var isFilePickerVisible: Bool = false
    @Published public var isImagePickerVisible: Bool = false
    @Published public var isTakePhotoVisible: Bool = false
    @Published public var isAudioRecordVisible: Bool = false
    @Published public var fileList: [File] = []

    public var isError: Bool {
        fileList.contains(where: { file in file.uploadError != nil })
    }

    public var isUploading: Bool {
        fileList.contains(where: { file in file.isUploading })
    }

    public var isAllUploaded: Bool {
        !fileList.contains(where: { file in !file.isUploaded })
    }

    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let uploadButtonDidTap = PassthroughRelay<WeakViewController>()
    public let addAttachmentButtonDidTap = PassthroughRelay<WeakViewController>()

    private let uploadManager = UploadManager(identifier: UUID.string)
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router
    private let batchId = UUID.string
    private lazy var files = uploadManager.subscribe(batchID: batchId) { [weak self] in
        self?.update()
    }

    public init (router: Router) {
        self.router = router

        setupInputBindings(router: router)
    }

    func update() {
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

    func add(image: UIImage) {
        do {
            let url = try image.write()
            fileSelected(url: url)
        } catch {

        }
    }

    func fileSelected(url: URL) {
        do {
            try uploadManager.add(url: url, batchID: batchId)
            files.refresh()
        } catch { }
    }

    func fileRemoved(file: File) {
        uploadManager.viewContext.delete(file)
        files.refresh()
    }

    private func uploadAttachments() {
        uploadManager.upload(batch: batchId, to: .myFiles)
    }

    func retryUpload() {
        uploadManager.retry(batchID: batchId)
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        uploadButtonDidTap
            .sink { [weak self] viewController in
                self?.uploadAttachments()
            }
            .store(in: &subscriptions)

        addAttachmentButtonDidTap
            .sink { [weak self] viewController in
                self?.showDialog(viewController: viewController)
            }
            .store(in: &subscriptions)
    }
}
