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
import Core
import Combine
import SwiftUI

@Observable
class CreateMessageViewModel {
    // MARK: - Outputs
    var body: String = ""
    var cancelButtonOpacity: Double {
        sendButtonOpacity
    }
    var attachmentButtonOpacity: Double {
        isAttachmentLoading ? 0.5 : 1.0
    }
    var attachmentViewModels: [AttachmentViewModel] = []
    var isAudioRecordVisible = false
    var isBodyDisabled: Bool {
        isSending
    }
    var isCheckboxDisbled: Bool {
        isSending
    }
    var isCloseDisabled: Bool {
        isSending
    }
    var isFilePickerVisible = false
    var isImagePickerVisible = false
    var isPeopleSelectionDisabled: Bool {
        isSending
    }
    var isSubjectDisabled: Bool {
        isSending
    }
    var sendButtonOpacity: Double {
        isSending ? 0.0 : 1.0
    }
    var spinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }
    var isIndividualMessage: Bool = false
    var isSendDisabled: Bool {
        subject.isEmpty ||
            body.isEmpty ||
            peopleSelectionViewModel.searchByPersonSelections.isEmpty ||
            isSending ||
            isAttachmentLoading
    }
    var isTakePhotoVisible = false
    var subject: String = ""

    // MARK: - Private
    private var isAttachmentLoading: Bool {
        attachmentViewModels.contains { $0.isLoading }
    }
    private var isSending = false
    let peopleSelectionViewModel: PeopleSelectionViewModel = .init()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Dependencies
    private let audioSession: AudioSessionProtocol
    private let cameraPermissionService: CameraPermissionService.Type
    private let composeMessageInteractor: ComposeMessageInteractor
    private let inboxMessageInteractor: InboxMessageInteractor
    let router: Router
    private let userID: String

    init(
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        composeMessageInteractor: ComposeMessageInteractor,
        inboxMessageInteractor: InboxMessageInteractor = InboxMessageInteractorLive(
            env: AppEnvironment.shared,
            tabBarCountUpdater: .init(),
            messageListStateUpdater: .init()
        ),
        router: Router = AppEnvironment.shared.router,
        audioSession: AudioSessionProtocol = AVAudioApplication.shared,
        cameraPermissionService: CameraPermissionService.Type = AVCaptureDevice.self
    ) {
        self.userID = userID
        self.composeMessageInteractor = composeMessageInteractor
        self.inboxMessageInteractor = inboxMessageInteractor
        self.router = router
        self.audioSession = audioSession
        self.cameraPermissionService = cameraPermissionService

        listenForAttachments()
    }

    // MARK: - Inputs

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

    func attachFile(viewController: WeakViewController) {
        showDialog(viewController: viewController)
    }

    func close(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func listenForAttachments() {
        composeMessageInteractor
            .attachments
            .sink { [weak self] files in
                self?.attachmentViewModels = files.map {
                    AttachmentViewModel(
                        $0,
                        onCancel: { [weak self] in
                            self?.composeMessageInteractor.cancel()
                        },
                        onDelete: { [weak self] file in
                            self?.composeMessageInteractor.removeFile(file: file)
                        }
                    )
                }
            }
            .store(in: &subscriptions)
    }

    func sendMessage(viewController: WeakViewController) {
        isSending = true
        Task { [weak self] in
            await self?.sendMessage()
            await self?.refreshSentMessages()
            performUIUpdate {
                self?.close(viewController: viewController)
            }
        }
    }

    // MARK: - Private Methods
    private func sendMessage() async {
        await withCheckedContinuation { continuation in
            self.composeMessageInteractor.createConversation(
                parameters: MessageParameters(
                    subject: self.subject,
                    body: self.body,
                    recipientIDs: self.peopleSelectionViewModel.recipientIDs,
                    bulkMessage: !self.isIndividualMessage
                )
            )
            .sink(
                receiveCompletion: { _ in
                    continuation.resume()
                },
                receiveValue: { _ in }
            )
            .store(in: &self.subscriptions)
        }
    }

    private func showDialog(viewController: WeakViewController) {
        if isAttachmentLoading {
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

    private func refreshSentMessages() async {
        await withCheckedContinuation { continuation in
            _ = inboxMessageInteractor.setContext(.user(userID))
            _ = self.inboxMessageInteractor.setScope(.sent)
            self.inboxMessageInteractor
                .refresh()
                .sink { _ in
                    continuation.resume()
                }
                .store(in: &self.subscriptions)
        }
    }
}

struct AttachmentViewModel: Identifiable {
    typealias OnCancel = () -> Void
    typealias OnDelete = (File) -> Void

    var cancelOpacity: Double {
        isLoading ? 1.0 : 0.0
    }
    var checkmarkOpacity: Double {
        isLoading ? 0.0 : 1.0
    }
    var deleteOpacity: Double {
        isLoading ? 0.0 : 1.0
    }
    var spinnerOpacity: Double {
        isLoading ? 1.0 : 0.0
    }
    var isLoading: Bool {
        !file.isUploaded
    }
    var filename: String {
        file.filename
    }
    let id: String = UUID().uuidString
    private let onCancel: OnCancel
    private let onDelete: OnDelete

    private let file: File

    init(_ file: File, onCancel: @escaping OnCancel, onDelete: @escaping OnDelete) {
        self.file = file
        self.onCancel = onCancel
        self.onDelete = onDelete
    }

    func cancel() {
        onCancel()
    }
    func delete() {
        onDelete(file)
    }
}
