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
import HorizonUI
import SwiftUI

@Observable
class AttachmentItemViewModel {
    // MARK: - Outputs

    var filename: String { file.filename }

    var actionType: HorizonUI.UploadedFile.ActionType {
        let isLoading = file.isUploading || isDownloading
        if file.isUploading || isDownloading {
            return .loading
        }
        if isOnlyForDownload && !isLoading {
            return .download
        }
        return .delete
    }

    // MARK: - Properties
    var id: String? { file.id }

    // MARK: - Private
    private var file: File
    private var isDownloading = false
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let composeMessageInteractor: ComposeMessageInteractor
    private let downloadFileInteractor: DownloadFileInteractor
    private let isOnlyForDownload: Bool
    private let router: Router

    // MARK: - Init
    init(
        _ file: File,
        isOnlyForDownload: Bool,
        router: Router,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor
    ) {
        self.file = file
        self.isOnlyForDownload = isOnlyForDownload
        self.router = router
        self.composeMessageInteractor = composeMessageInteractor
        self.downloadFileInteractor = downloadFileInteractor

        file.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.file = file
            }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs
    func delete() { composeMessageInteractor.removeFile(file: file) }

    func download(_ viewController: WeakViewController) {
        isDownloading = true
        downloadFileInteractor
            .download(file: file)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] url in
                    self?.isDownloading = false
                    self?.router.showShareSheet(fileURL: url, viewController: viewController)
                }
            )
            .store(in: &subscriptions)
    }
}

extension AttachmentItemViewModel: Identifiable, Equatable, Hashable {
    // MARK: - Equatable
    static func == (lhs: AttachmentItemViewModel, rhs: AttachmentItemViewModel) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
