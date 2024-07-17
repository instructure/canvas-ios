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

    public let didTapCancel = PassthroughRelay<WeakViewController>()
    public let didTapFile = PassthroughRelay<(WeakViewController, File)>()
    public let didTapFolder = PassthroughRelay<(WeakViewController, Folder)>()

    private let interactor: FilePickerInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment
    private let onSelect: (File) -> Void

    public init(env: AppEnvironment, interactor: FilePickerInteractor, onSelect: @escaping (File) -> Void = { _ in }) {
        self.interactor = interactor
        self.env = env
        self.onSelect = onSelect

        setupOutputBindings()
        setupInputBindings()
    }

    private func setupOutputBindings() {
        interactor.folderItems
            .sink { [weak self] items in
                self?.folderItems = items
            }
            .store(in: &subscriptions)

        interactor.state
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &subscriptions)
    }

    private func setupInputBindings() {
        didTapCancel
            .sink { [weak self] controller in
                self?.env.router.dismiss(controller)
            }
            .store(in: &subscriptions)

        didTapFile
            .sink { [weak self] (controller, file) in
                self?.onSelect(file)
                self?.env.router.dismiss(controller)
            }
            .store(in: &subscriptions)

        didTapFolder
            .sink { [weak self] (controller, folder) in
                guard let self else { return }

                let view = AttachmentPickerAssembly.makeFilePickerViewController(env: env, folderId: folder.id, onSelect: onSelect)
                env.router.show(view, from: controller, options: .push)
            }
            .store(in: &subscriptions)
    }

}
