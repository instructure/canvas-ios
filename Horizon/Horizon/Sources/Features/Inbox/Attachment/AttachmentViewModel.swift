//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import AVKit
import Combine
import Core

@Observable
class AttachmentViewModel {
    var isAudioRecordVisible = false
    var isFilePickerVisible = false
    var isImagePickerVisible = false
    var isTakePhotoVisible = false
    var isUploading: Bool {
        let files: [File] = composeMessageInteractor.attachments.value
        return files.contains { $0.isUploading }
    }
    var items: [AttachmentItemViewModel] = []

    private var subscriptions = Set<AnyCancellable>()

    private let audioSession: AudioSessionProtocol
    private let cameraPermissionService: CameraPermissionService.Type
    private let composeMessageInteractor: ComposeMessageInteractor
    private let downloadFileInteractor: DownloadFileInteractor
    let router: Router

    init(
        router: Router = AppEnvironment.shared.router,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor = DownloadFileInteractorLive(),
        audioSession: AudioSessionProtocol = AVAudioApplication.shared,
        cameraPermissionService: CameraPermissionService.Type = AVCaptureDevice.self
    ) {
        self.router = router
        self.composeMessageInteractor = composeMessageInteractor
        self.downloadFileInteractor = downloadFileInteractor
        self.audioSession = audioSession
        self.cameraPermissionService = cameraPermissionService

        self.listenForAttachments()
    }

    func addFile(file: File) {
        composeMessageInteractor.addFile(file: file)
    }

    func addFile(url: URL) {
        isImagePickerVisible = false
        isTakePhotoVisible = false
        isFilePickerVisible = false
        isAudioRecordVisible = false

        composeMessageInteractor.addFile(url: url)
    }

    func addFiles(urls: [URL]) {
        urls.forEach { url in
            if url.startAccessingSecurityScopedResource() {
                addFile(url: url)
            }
        }
    }

    func show(from viewController: WeakViewController) {
        if isUploading {
            return
        }
        let sheet = BottomSheetPickerViewController.create()
        sheet.title = String(localized: "Select Attachment Type", bundle: .core)

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
            guard let self else {
                return
            }
            VideoRecorder.requestPermission(cameraService: cameraPermissionService) { isEnabled in
                if isEnabled {
                    self.isTakePhotoVisible = true
                } else {
                    viewController.value.showPermissionError(.camera)
                }
            }
        }
        sheet.addAction(
            image: .audioLine,
            title: String(localized: "Record audio", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            guard let self else {
                return
            }
            AudioRecorderViewController.requestPermission(audioSession: self.audioSession) { isEnabled in
                if isEnabled {
                    self.isAudioRecordVisible = true
                } else {
                    viewController.value.showPermissionError(.microphone)
                }
             }
        }
        sheet.addAction(
            image: .folderLine,
            title: String(localized: "Attach from Canvas files", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            guard let self, let top = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return }

            let viewController = AttachmentPickerAssembly.makeFilePickerViewController(env: .shared, onSelect: self.addFile)
            self.router.show(viewController, from: top, options: .modal(isDismissable: true, embedInNav: true))

        }

        router.show(sheet, from: viewController, options: .modal())
    }

    private func listenForAttachments() {
        composeMessageInteractor
            .attachments
            .sink { [weak self] files in
                guard let self else { return }
                self.items = files.map {
                    AttachmentItemViewModel(
                        $0,
                        router: self.router,
                        composeMessageInteractor: self.composeMessageInteractor,
                        downloadFileInteractor: self.downloadFileInteractor
                    )
                }
            }
            .store(in: &subscriptions)
    }
}
