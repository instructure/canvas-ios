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
    private(set) var isMarkAsDoneLoaderVisible = false
    private(set) var errorMessage = ""

    // MARK: - Input / Output

    var isShowErrorAlert = false

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let moduleItemInteractor: ModuleItemSequenceInteractor
    private let moduleID: String
    let context: Core.Context
    let itemID: String
    let pageURL: String
    let isMarkedAsDoneButtonVisible: Bool

    // MARK: - Init

    init(
        moduleItemInteractor: ModuleItemSequenceInteractor,
        context: Core.Context,
        pageURL: String,
        isCompletedItem: Bool,
        moduleID: String,
        itemID: String,
        isMarkedAsDoneButtonVisible: Bool
    ) {
        self.moduleItemInteractor = moduleItemInteractor
        self.context = context
        self.isCompletedItem = isCompletedItem
        self.pageURL = pageURL
        self.moduleID = moduleID
        self.itemID = itemID
        self.isMarkedAsDoneButtonVisible = isMarkedAsDoneButtonVisible
    }

    func markAsDone() {
        isMarkAsDoneLoaderVisible = true
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
            self?.isMarkAsDoneLoaderVisible = false
        } receiveValue: { [weak self] _ in
            self?.isCompletedItem.toggle()
        }
        .store(in: &subscriptions)
    }
}
