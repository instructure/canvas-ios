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

import Combine
import SwiftUI

final class ModulePublishProgressViewModel: ObservableObject {

    enum ViewState {
        case inProgress
        case completed
        case error
    }

    enum Title {
        case allModulesAndItems
        case allModules
        case selectedModuleAndItems
        case selectedModule
    }

    enum TrailingBarButton {
        case cancel
        case done
    }

    // MARK: - Output

    @Published private(set) var state: ViewState = .inProgress
    @Published private(set) var progress: Double = 0
    @Published private(set) var progressViewColor: Color = .clear
    @Published private(set) var trailingBarButton: TrailingBarButton = .cancel

    var title: Title {
        guard let subject = action.subject else {
            assertionFailure("Subject should never be nil for this view")
            return .selectedModuleAndItems
        }

        switch subject {
        case .modulesAndItems:
            return allModules ? .allModulesAndItems : .selectedModuleAndItems
        case .onlyModules:
            return allModules ? .allModules : .selectedModule
        }
    }

    var isPublish: Bool {
        action.isPublish
    }

    // MARK: - Input

    let didTapDismiss = PassthroughSubject<WeakViewController, Never>()
    let didTapCancel = PassthroughSubject<(WeakViewController, String), Never>()
    let didTapDone = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let action: ModulePublishAction
    private let allModules: Bool
    private let moduleIds: [String]
    private let interactor: ModulePublishInteractor
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        action: ModulePublishAction,
        allModules: Bool,
        moduleIds: [String],
        interactor: ModulePublishInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.action = action
        self.allModules = allModules
        self.moduleIds = moduleIds
        self.interactor = interactor

        didTapDismiss
            .sink { router.dismiss($0) }
            .store(in: &subscriptions)

        didTapCancel
            .sink { weakVC, snackBarTitle in
                interactor.cancelBulkPublish(moduleIds: moduleIds, action: action)
                let snackBarViewModel = weakVC.value.findSnackBarViewModel()
                router.dismiss(weakVC) {
                    snackBarViewModel?.showSnack(snackBarTitle)
                }
            }
            .store(in: &subscriptions)

        didTapDone
            .sink { router.dismiss($0) }
            .store(in: &subscriptions)

        interactor
            .bulkPublish(moduleIds: moduleIds, action: action)
            .removeDuplicates()
            .mapToResult()
            .sink { [weak self] state in
                guard let self else { return }
                progress = {
                    guard case .success(let progressObject) = state else {
                        return 0
                    }

                    return Double(progressObject.progress)
                }()
                trailingBarButton = {
                    switch state {
                    case .success(let progressObject):
                        switch progressObject {
                        case .completed: return .done
                        case .running: return .cancel
                        }
                    case .failure: return .done
                    }
                }()
                progressViewColor = {
                    switch state {
                    case .success(let progressObject):
                        switch progressObject {
                        case .completed: return .backgroundSuccess
                        case .running: return .accentColor
                        }
                    case .failure: return .backgroundDanger
                    }
                }()
                self.state = {
                    switch state {
                    case .success(let progressObject):
                        switch progressObject {
                        case .completed: return .completed
                        case .running: return .inProgress
                        }
                    case .failure: return .error
                    }
                }()
            }
            .store(in: &subscriptions)
    }
}
