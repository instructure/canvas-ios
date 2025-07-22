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

protocol PageDetailsViewModel {
    var bodyOpacity: Double { get }
    var context: Core.Context { get }
    var pageURL: String? { get }
    var isHeaderVisible: Bool { get }
    var itemID: String? { get }
    var loaderOpacity: Double { get }
    var markAsDoneViewModel: MarkAsDoneViewModel? { get }

    func close(viewController: WeakViewController)
}

@Observable
final class PageDetailsViewModelLive: PageDetailsViewModel {
    // MARK: - Outputs
    var bodyOpacity: Double {
        loaderOpacity == 0.0 ? 1.0 : 0.0
    }
    private(set) var errorMessage: String?
    var isHeaderVisible: Bool {
        router != nil
    }
    var isMarkedAsDoneButtonVisible: Bool {
        markAsDoneViewModel != nil
    }
    var loaderOpacity: Double {
        itemID == nil || pageURL == nil ? 1.0 : 0.0
    }
    private(set) var url: URL?

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    let context: Core.Context
    var itemID: String?
    let markAsDoneViewModel: MarkAsDoneViewModel?
    let moduleItemSequenceInteractor: ModuleItemSequenceInteractor?
    var pageURL: String?
    private var router: Router?

    // MARK: - Init
    init(
        courseID: String,
        assetID: String,
        assetType: GetModuleItemSequenceRequest.AssetType,
        moduleItemSequenceInteractor: ModuleItemSequenceInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.context = .init(.course, id: courseID)
        self.markAsDoneViewModel = nil
        self.moduleItemSequenceInteractor = moduleItemSequenceInteractor
        self.router = router

        moduleItemSequenceInteractor.fetchModuleItems(
            assetType: assetType,
            assetID: assetID,
            moduleID: nil,
            itemID: nil,
            ignoreCache: false
        )
        .sink { [weak self] tuple in
            guard let self = self,
                  let moduleItem = tuple.1 else {
                return
            }
            if case let .page(url) = moduleItem.type {
                self.pageURL = url
            }
            self.itemID = moduleItem.id
        }
        .store(in: &subscriptions)
    }

    init(
        context: Core.Context,
        pageURL: String,
        itemID: String,
        markAsDoneViewModel: MarkAsDoneViewModel
    ) {
        self.context = context
        self.pageURL = pageURL
        self.itemID = itemID
        self.markAsDoneViewModel = markAsDoneViewModel
        self.moduleItemSequenceInteractor = nil
        self.router = nil
    }

    func close(viewController: WeakViewController) {
        router?.dismiss(viewController)
    }
}

/// A view model specific to the ability to toggle a module item as done or not done.
@Observable
final class MarkAsDoneViewModel {
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    var errorMessage: String?
    var isCompleted: Bool
    var isErrorPresented: Bool {
        errorMessage != nil
    }
    var isLoading: Bool = false
    let itemID: String
    let moduleID: String
    let moduleItemInteractor: ModuleItemSequenceInteractor

    init(
        moduleID: String,
        itemID: String,
        isCompleted: Bool,
        moduleItemSequenceInteractor: ModuleItemSequenceInteractor
    ) {
        self.moduleID = moduleID
        self.itemID = itemID
        self.isCompleted = isCompleted
        self.moduleItemInteractor = moduleItemSequenceInteractor
    }

    func markAsDone() {
        isLoading = true
        moduleItemInteractor.markAsDone(
            completed: !isCompleted,
            moduleID: moduleID,
            itemID: itemID
        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.errorMessage = error.localizedDescription
            }
            self?.isLoading = false
        } receiveValue: { [weak self] _ in
            self?.isCompleted.toggle()
        }
        .store(in: &subscriptions)
    }
}
