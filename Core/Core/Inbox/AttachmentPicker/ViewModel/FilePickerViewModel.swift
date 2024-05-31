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

public class FilePickerViewModel: ObservableObject {
    @Published public var folderItems: [FolderItem] = []
    @Published public var state: StoreState = .loading
    public let title = String(localized: "Select file", bundle: .core)

    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let fileDidTap = PassthroughRelay<(WeakViewController, File)>()
    public let folderDidTap = PassthroughRelay<(WeakViewController, Folder)>()

    private let interactor: FilePickerInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router
    private let onSelect: (File) -> Void

    public init(router: Router, interactor: FilePickerInteractor, onSelect: @escaping (File) -> Void = { _ in }) {
        self.interactor = interactor
        self.router = router
        self.onSelect = onSelect

        setupOutputbindings()
        setupInputbindings()
    }

    private func setupOutputbindings() {
        interactor.folderItems
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] items in
                self?.folderItems = items
            })
            .store(in: &subscriptions)

        interactor.state
            .sink(receiveCompletion: {_ in }, receiveValue: { [weak self] state in
                self?.state = state
            })
            .store(in: &subscriptions)
    }

    private func setupInputbindings() {
        cancelButtonDidTap
            .sink { [weak self] controller in
                self?.router.dismiss(controller)
            }
            .store(in: &subscriptions)

        fileDidTap
            .sink { [weak self] (controller, file) in
                self?.onSelect(file)
                self?.router.dismiss(controller)
            }
            .store(in: &subscriptions)

        folderDidTap
            .sink { [weak self] (controller, folder) in
                let view = AttachmentPickerAssembly.makeFilePickerViewController(folderId: folder.id)
                self?.router.show(view, from: controller, options: .push)
            }
            .store(in: &subscriptions)
    }

}
