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
    var bodyOpacity: Double {
        loaderOpacity == 0.0 &&
            lockedOpacity == 0.0 &&
            fileOpacity == 0.0 ?
                1.0 :
                0.0
    }
    var isErrorPresented: Bool = false {
        didSet {
            if !isErrorPresented && errorMessage !=  nil {
                errorMessage = nil
            }
        }
    }
    var fileOpacity: Double {
        fileID == nil ? 0.0 : 1.0
    }
    var isHeaderVisible: Bool {
        router != nil
    }
    var isMarkedAsDoneButtonVisible: Bool {
        markAsDoneViewModel != nil
    }
    var loaderOpacity: Double {
        (itemID == nil || pageURL == nil) &&
            fileID == nil &&
            lockedOpacity == 0.0 ? 1.0 : 0.0
    }
    var lockedOpacity: Double = 0.0
    private(set) var url: URL?

    // MARK: - Properties
    private(set) var errorMessage: String? {
        didSet {
            if errorMessage != nil && isErrorPresented == false {
                isErrorPresented = errorMessage != nil
            }
        }
    }
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    let context: Core.Context
    let courseID: String?
    var fileID: String?
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
        self.courseID = courseID
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
                self?.errorMessage = String(
                    localized: "Sorry, we were not able to display this page right now.",
                    bundle: .horizon
                )
                return
            }
            lockedOpacity = moduleItem.isLocked ? 1.0 : 0.0
            self.itemID = moduleItem.id

            switch moduleItem.type {
            case .page(let url):
                self.pageURL = url
            case .file(let fileID):
                self.fileID = fileID
            default:
                break
            }
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
        self.courseID = nil
        self.fileID = nil

        markAsDoneViewModel.onError = { [weak self] errorMessage in
            self?.errorMessage = errorMessage
        }
    }

    func close(viewController: WeakViewController) {
        router?.dismiss(viewController)
    }
}

/// A view model specific to the ability to toggle a module item as done or not done.
@Observable
final class MarkAsDoneViewModel {
    typealias OnError = ((String) -> Void)?

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    var isLoading: Bool = false
    var onError: OnError = nil

    // MARK: - Dependencies
    var isCompleted: Bool
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
                self?.onError?(error.localizedDescription)
            }
            self?.isLoading = false
        } receiveValue: { [weak self] _ in
            self?.isCompleted.toggle()
        }
        .store(in: &subscriptions)
    }
}
