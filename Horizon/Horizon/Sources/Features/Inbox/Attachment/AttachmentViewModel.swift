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

import Combine
import Core
import Foundation

@Observable
final class AttachmentViewModel {
    // MARK: - Inputs / Outputs
    var isErrorMessagePresented = false
    private(set) var errorMessage: String = ""
    var isVisible: Bool = false
    var isFilePickerVisible = false
    var isImagePickerVisible = false
    var isTakePhotoVisible = false

    // MARK: - Outputs

    private(set) var items: [AttachmentFileModel] = []
    var isPickerVisible: Bool {
        (isFilePickerVisible || isImagePickerVisible || isTakePhotoVisible || isVisible)
    }

    var isUploading: Bool {
        let files: [File] = composeMessageInteractor.attachments.value
        return files.contains { $0.isUploading }
    }

    // MARK: - Private

    private var downloadCancellable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private var observations = [String: NSKeyValueObservation]()

    // MARK: - Dependencies

    private let acknowledgeFileUploadInteractor: AcknowledgeFileUploadInteractor
    private let composeMessageInteractor: ComposeMessageInteractor

    // MARK: - Init
    init(
        composeMessageInteractor: ComposeMessageInteractor,
        acknowledgeFileUploadInteractor: AcknowledgeFileUploadInteractor = AcknowledgeFileUploadInteractorLive()
    ) {
        self.composeMessageInteractor = composeMessageInteractor
        self.acknowledgeFileUploadInteractor = acknowledgeFileUploadInteractor
        self.listenForAttachments()
        listenForFileUploadFailures()
    }

    // MARK: - Inputs
    func addFile(url: URL) {
        dismiss()
        if let file = composeMessageInteractor.addFile(url: url) {
            confirmFileUpload(for: file)
        }
    }

    func deleteAll() {
        items.forEach { composeMessageInteractor.removeFile(file: $0.file) }
    }

    func chooseFile() {
        isVisible = false
        isFilePickerVisible = true
    }

    func chooseImage() {
        isVisible = false
        isImagePickerVisible = true
    }

    func choosePhoto() {
        isVisible = false
        isTakePhotoVisible = true
    }

    func fileSelectionComplete(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if url.startAccessingSecurityScopedResource() {
                addFile(url: url)
            }
            url.stopAccessingSecurityScopedResource()
        case .failure(let failure):
            debugPrint(failure)
        }
    }

    private func confirmFileUpload(for file: File) {
        acknowledgeFileUploadInteractor.acknowledgeUpload(of: file)
    }

    private func dismiss() {
        isVisible = false
        isFilePickerVisible = false
        isImagePickerVisible = false
        isTakePhotoVisible = false
    }

    private func listenForAttachments() {
        composeMessageInteractor
            .attachments
            .sink { [weak self] files in
                guard let self else { return }
                self.items = files.map { .init(file: $0) }
            }
            .store(in: &subscriptions)
    }

    private func listenForFileUploadFailures() {
        composeMessageInteractor.didUploadFiles
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorMessage = error.localizedDescription
                    self?.isErrorMessagePresented = true
                    if let file = self?.composeMessageInteractor.attachments.value.last {
                        self?.composeMessageInteractor.removeFile(file: file)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    func removeFile(attachment: AttachmentFileModel) {
        composeMessageInteractor.removeFile(file: attachment.file)
    }
}
