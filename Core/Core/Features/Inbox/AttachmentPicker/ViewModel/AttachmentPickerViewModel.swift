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
    @Published public var isFileSelectVisible: Bool = false
    @Published public private(set) var fileList: [File] = []
    @Published public private(set) var alreadyUploadedFileList: [File] = []
    @Published public var isFileErrorOccured: Bool = false
    public let title = String(localized: "Attachments", bundle: .core)
    public let subTitle: String?
    public let fileErrorTitle = String(localized: "Error", bundle: .core)
    public let fileErrorMessage = String(localized: "Failed to add attachment. Please try again!", bundle: .core)
    @Published public var isShowingCancelDialog = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Cancel Uploading", bundle: .core),
        message: String(localized: "Are sure you want to leave your process? Your changes will not be saved.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Discard", bundle: .core),
        isDestructive: true
    )

    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let doneButtonDidTap = PassthroughRelay<WeakViewController>()
    public let uploadButtonDidTap = PassthroughRelay<WeakViewController>()
    public let retryButtonDidTap = PassthroughRelay<WeakViewController>()
    public let addAttachmentButtonDidTap = PassthroughRelay<WeakViewController>()
    public let removeButtonDidTap = PassthroughRelay<File>()
    public let deleteFileButtonDidTap = PassthroughRelay<File>()
    public var fileSelected = PassthroughRelay<(WeakViewController, File)>()
    public let router: Router

    // MARK: Private

    private let interactor: AttachmentPickerInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var linkedFiles: [File] = []

    public init (subTitle: String? = nil, router: Router, interactor: AttachmentPickerInteractor) {
        self.subTitle = subTitle
        self.router = router
        self.interactor = interactor

        setupInputBindings(router: router)
        setupOutputBindings()
    }

    private func showDialog(viewController: WeakViewController) {
        let sheet = BottomSheetPickerViewController.create()

        sheet.addAction(
            image: .documentLine,
            title: String(localized: "Upload file", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isFilePickerVisible = true
        }
        sheet.addAction(
            image: .imageLine,
            title: String(localized: "Upload photo", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isImagePickerVisible = true
        }
        sheet.addAction(
            image: .cameraLine,
            title: String(localized: "Take photo", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isTakePhotoVisible = true
        }
        sheet.addAction(
            image: .audioLine,
            title: String(localized: "Record audio", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isAudioRecordVisible = true
        }
        sheet.addAction(
            image: .folderLine,
            title: String(localized: "Attach from Canvas files", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            guard let self, let top = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return }

            let viewController = AttachmentPickerAssembly.makeFilePickerViewController(env: .shared, onSelect: self.didSelectFile)
            self.router.show(viewController, from: top, options: .modal(isDismissable: true, embedInNav: true))

        }
        router.show(sheet, from: viewController, options: .modal())
    }

    func showDialog(title: String?, message: String?) {
        let actionTitle = String(localized: "OK", bundle: .core)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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

    func didSelectFile(url: URL) {
        isImagePickerVisible = false
        isTakePhotoVisible = false
        isFilePickerVisible = false
        isAudioRecordVisible = false

        interactor.addFile(url: url)
    }

    func didSelectFile(file: File) {
        interactor.addFile(file: file)
    }

    private func setupOutputBindings() {
        interactor.files.sink(receiveCompletion: { [weak self] result in
            switch result {
            case.failure:
                self?.showDialog(title: self?.fileErrorTitle, message: self?.fileErrorMessage)
            case .finished: break
            }
        }, receiveValue: { [weak self] files in
            self?.fileList = files
        })
        .store(in: &subscriptions)

        interactor.alreadyUploadedFiles.sink { [weak self] files in
            self?.alreadyUploadedFileList = files
        }
        .store(in: &subscriptions)
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .handleEvents(receiveOutput: { [weak self] _ in
                if self?.interactor.isCancelConfirmationNeeded == true {
                    self?.isShowingCancelDialog = true
                }
            })
            .flatMap { [weak self, confirmAlert] value in
                if self?.interactor.isCancelConfirmationNeeded == true {
                    return confirmAlert.userConfirmation().map { value }.eraseToAnyPublisher()
                }
                return Just(value).eraseToAnyPublisher()
            }
            .sink { [weak self, router] viewController in
                self?.interactor.cancel()
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
                self?.interactor.uploadFiles()
            }
            .store(in: &subscriptions)

        retryButtonDidTap
            .sink { [weak self] _ in
                self?.interactor.retry()
            }
            .store(in: &subscriptions)

        addAttachmentButtonDidTap
            .sink { [weak self] viewController in
                self?.showDialog(viewController: viewController)
            }
            .store(in: &subscriptions)

        removeButtonDidTap
            .sink { [weak self] file in
                self?.interactor.removeFile(file: file)
            }
            .store(in: &subscriptions)

        deleteFileButtonDidTap
            .flatMap { [weak self] file in
                if let self {
                    return self.interactor.deleteFile(file: file)
                } else {
                    return Just(()).eraseToAnyPublisher()
                }
            }
            .sink()
            .store(in: &subscriptions)

        fileSelected.sink { [weak self] (controller, file) in
            if let url = file.url, let fileController = router.match(url.appendingQueryItems(.init(name: "canEdit", value: "false"))) {
                router.show(fileController, from: controller, options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true))
            } else {
                let shouldUploadTitle = String(localized: "Upload Files", bundle: .core)
                let shouldUploadMessage = String(localized: "You have to upload the attachments to get access to previews!", bundle: .core)
                self?.showDialog(title: shouldUploadTitle, message: shouldUploadMessage)
            }
        }
        .store(in: &subscriptions)
    }
}
