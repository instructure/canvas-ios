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

public class FilePickerInteractorLive: FilePickerInteractor {
    private let env: AppEnvironment
    private let context: Context = .currentUser

    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.data)
    public var folder = CurrentValueSubject<[Folder], Never>([])
    public var folderItems = CurrentValueSubject<[FolderItem], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private var folderItemsStore: Store<GetFolderItems>?

    public init(env: AppEnvironment, folderId: String?) {
        self.env = env

        if let folderId {
            folderItemsStore = env.subscribe(GetFolderItems(folderID: folderId))

            folderItemsStore?
                .statePublisher
                .subscribe(state)
                .store(in: &subscriptions)

            folderItemsStore?
                .allObjects
                .subscribe(folderItems)
                .store(in: &subscriptions)

            folderItemsStore?.exhaust()
        } else {
            let folderStore = env.subscribe(GetFolderByPath(context: context))

            folderStore
                .allObjects
                .handleEvents(receiveOutput: { [weak self] folders in
                    self?.folderItemsStore = env.subscribe(GetFolderItems(folderID: folders.first?.id ?? ""))
                })
                .map { [weak self] folder in

                    if let self {
                        self.folderItemsStore?
                            .statePublisher
                            .subscribe(state)
                            .store(in: &subscriptions)

                        self.folderItemsStore?
                            .allObjects
                            .subscribe(self.folderItems)
                            .store(in: &self.subscriptions)

                        self.folderItemsStore?.exhaust()
                    }
                    return folder
                }
                .subscribe(folder)
                .store(in: &subscriptions)
            folderStore.exhaust()
        }
    }
}
