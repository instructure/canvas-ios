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

import Foundation
import Observation
import Combine
import Core

@Observable
final class PageDetailsViewModel {
    // MARK: - Outputs

    private(set) var url: URL?
    private(set) var content: String?
    private(set) var isCompletedItem: Bool
    private(set) var isLoaderVisible = true
    private(set) var errorMessage = ""

    // MARK: - Input / Output

    var isShowErrorAlert = false

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let moduleItemInteractor: ModuleItemSequenceInteractor
    private let moduleID: String
    private let itemID: String

    // MARK: - Init

    init(
        moduleItemInteractor: ModuleItemSequenceInteractor,
        context: Core.Context,
        pageURL: String,
        isCompletedItem: Bool,
        moduleID: String,
        itemID: String
    ) {
        self.moduleItemInteractor = moduleItemInteractor
        self.isCompletedItem = isCompletedItem
        self.moduleID = moduleID
        self.itemID = itemID

        ReactiveStore(
            useCase: GetPage(context: context, url: pageURL)
        )
        .getEntities()
        .replaceError(with: [])
        .sink { [weak self] values in
            let page = values.first
            self?.content = page?.body
            self?.url = page?.htmlURL
            self?.isLoaderVisible = false
        }
        .store(in: &subscriptions)
    }

    func markAsDone() {
        isLoaderVisible = true
        moduleItemInteractor.markAsDone(
            completed: !isCompletedItem,
            moduleID: moduleID,
            itemID: itemID
        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.errorMessage = error.localizedDescription
                self?.isShowErrorAlert = true
            }
            self?.isLoaderVisible = false
        } receiveValue: { [weak self] _ in
            self?.isCompletedItem.toggle()
        }
        .store(in: &subscriptions)
    }
}
