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

// TODO: remove
extension ModulePublishProgressViewModel {
    final class DummyInteractor {
        typealias State = ModulePublishProgressViewModel.ViewState
        let state = CurrentValueSubject<State, Never>(.inProgress)
        let progress = CurrentValueSubject<Double, Never>(0)

        func start(shouldFail: Bool) {
            let total = 7
            let errorTreshold = 5
            let interval = 0.5
            for i in 0...total {
                guard !shouldFail || i <= errorTreshold else { break }
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) { [weak self] in
                    let stateValue: State = switch i {
                    case total: .completed
                    case errorTreshold: shouldFail ? .error : .inProgress
                    default: .inProgress
                    }
                    self?.state.send(stateValue)
                    self?.progress.send(Double(i) / Double(total))
                }
            }
        }
    }
}

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

    private let interactor: DummyInteractor
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        action: ModulePublishAction,
        allModules: Bool,
        interactor: DummyInteractor = .init(),
        router: Router
    ) {
        self.action = action
        self.allModules = allModules
        self.interactor = interactor

        interactor.state
            .assign(to: &$state)

        interactor.state
            .map {
                switch $0 {
                case .inProgress:
                        .accentColor
                case .completed:
                        .backgroundSuccess
                case .error:
                        .backgroundDanger
                }
            }
            .assign(to: &$progressViewColor)

        interactor.state
            .map {
                switch $0 {
                case .inProgress:
                        .cancel
                case .completed:
                        .done
                case .error:
                        .done
                }
            }
            .assign(to: &$trailingBarButton)

        interactor.progress
            .assign(to: &$progress)

        // TODO: remove
        interactor.start(shouldFail: !allModules)

        didTapDismiss
            .sink { router.dismiss($0) }
            .store(in: &subscriptions)

        didTapCancel
            .sink { weakVC, snackBarTitle in
                // TODO: send cancel request silently: no spinner, no errors
                let snackBarViewModel = weakVC.value.findSnackBarViewModel()
                router.dismiss(weakVC) {
                    snackBarViewModel?.showSnack(snackBarTitle)
                }
            }
            .store(in: &subscriptions)

        didTapDone
            .sink { router.dismiss($0) }
            .store(in: &subscriptions)
    }
}
