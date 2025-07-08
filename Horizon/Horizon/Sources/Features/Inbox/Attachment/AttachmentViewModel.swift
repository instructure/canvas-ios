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

    enum FileType {
        case file
        case image
        case photo
    }

    // MARK: - Outputs
    var fileTypes: [FileType] = [.image, .photo, .file]
    var allowedContentTypes: [UTType] = [
        .image,
        .audio,
        .video,
        .pdf,
        .text,
        .spreadsheet,
        .presentation
    ]
    var isVisible: Bool = false
    var isFilePickerVisible = false
    var isImagePickerVisible = false
    var isTakePhotoVisible = false

    var isUploading: Bool {
        let files: [File] = composeMessageInteractor.attachments.value
        return files.contains { $0.isUploading }
    }
    var items: [AttachmentItemViewModel] = []

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let composeMessageInteractor: ComposeMessageInteractor
    private let downloadFileInteractor: DownloadFileInteractor
    let router: Router

    // MARK: - Init
    init(
        router: Router = AppEnvironment.shared.router,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor = DownloadFileInteractorLive()
    ) {
        self.router = router
        self.composeMessageInteractor = composeMessageInteractor
        self.downloadFileInteractor = downloadFileInteractor

        self.listenForAttachments()
    }

    // MARK: - Inputs
    func addFile(file: File) {
        composeMessageInteractor.addFile(file: file)
    }

    func addFile(url: URL) {
        dismiss()
        composeMessageInteractor.addFile(url: url)
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
                self.items = files.map {
                    AttachmentItemViewModel(
                        $0,
                        isOnlyForDownload: false,
                        router: self.router,
                        composeMessageInteractor: self.composeMessageInteractor,
                        downloadFileInteractor: self.downloadFileInteractor
                    )
                }
            }
            .store(in: &subscriptions)
    }
}
