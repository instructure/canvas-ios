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
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var folderItems = CurrentValueSubject<[FolderItem], Never>([])

    // MARK: - Private
    private let context: Context = .currentUser
    private var subscriptions = Set<AnyCancellable>()

    public init(folderId: String?) {
        if let folderId {
            ReactiveStore(useCase: GetFolderItems(folderID: folderId))
                .getEntities()
                .sink(receiveCompletion: { [weak self] result in
                    switch result {
                    case .failure:
                        self?.state.send(.error)
                    case .finished:
                        break
                    }

                }, receiveValue: { [weak self] folderItems in
                    if folderItems.isEmpty {
                        self?.state.send(.empty)
                    } else {
                        self?.state.send(.data)
                    }
                    self?.folderItems.send(folderItems)
                })
                .store(in: &subscriptions)

        } else {
            ReactiveStore(useCase: GetFolderByPath(context: context))
                .getEntities()
                .compactMap { folders in
                    folders.first?.id
                }
                .map { [weak self] folderId in
                    guard let self else { return }

                    ReactiveStore(useCase: GetFolderItems(folderID: folderId))
                        .getEntities()
                        .sink(receiveCompletion: { result in
                            switch result {
                            case .failure:
                                self.state.send(.error)
                            case .finished:
                                break
                            }
                        }, receiveValue: { folderItems in
                            if folderItems.isEmpty {
                                self.state.send(.empty)
                            } else {
                                self.state.send(.data)
                            }
                            self.folderItems.send(folderItems)
                        })
                        .store(in: &subscriptions)
                }
                .sink()
                .store(in: &subscriptions)
        }
    }
}
