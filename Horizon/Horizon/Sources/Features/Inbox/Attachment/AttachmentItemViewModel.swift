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

class AttachmentItemViewModel: Identifiable, Equatable, Hashable {
    // MARK: - Outputs
    var cancelOpacity: Double { isLoading && !isOnlyForDownload && !isDisabled ? 1.0 : 0.0 }
    var checkmarkOpacity: Double { isLoading ? 0.0 : 1.0 }
    var deleteOpacity: Double { isLoading || isOnlyForDownload || isDisabled ? 0.0 : 1.0 }
    var spinnerOpacity: Double { isLoading ? 1.0 : 0.0 }
    var isCheckmarkVisible: Bool { !isOnlyForDownload }
    var isSpinnerVisible: Bool { !isOnlyForDownload && isLoading }
    var isLoading: Bool { !file.isUploaded }
    var filename: String { file.filename }

    // MARK: - Properties
    var id: String? { file.id }

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let composeMessageInteractor: ComposeMessageInteractor
    private let downloadFileInteractor: DownloadFileInteractor
    private let file: File
    let isDisabled: Bool
    let isOnlyForDownload: Bool
    private let router: Router

    // MARK: - Init
    init(
        _ file: File,
        isOnlyForDownload: Bool,
        disabled: Bool,
        router: Router,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor
    ) {
        self.file = file
        self.isOnlyForDownload = isOnlyForDownload
        self.isDisabled = disabled
        self.router = router
        self.composeMessageInteractor = composeMessageInteractor
        self.downloadFileInteractor = downloadFileInteractor
    }

    // MARK: - Inputs
    func cancel() { composeMessageInteractor.cancel() }
    func delete() { composeMessageInteractor.removeFile(file: file) }
    func download(_ viewController: WeakViewController) {
        downloadFileInteractor
            .download(file: file)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] url in
                    self?.router.showShareSheet(fileURL: url, viewController: viewController)
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Equatable
    static func == (lhs: AttachmentItemViewModel, rhs: AttachmentItemViewModel) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
