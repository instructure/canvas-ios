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

public class CalendarToDoDetailsViewModel: ObservableObject {
    public let navigationTitle = String(localized: "To Do", bundle: .core)
    public let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    @Published public private(set) var title: String?
    @Published public private(set) var date: String?
    @Published public private(set) var description: String?
    @Published public private(set) var navBarColor: UIColor?
    @Published public var shouldShowDeleteError: Bool = false

    private let plannable: Plannable
    private let interactor: CalendarToDoInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(plannable: Plannable, interactor: CalendarToDoInteractor) {
        self.plannable = plannable
        self.interactor = interactor

        interactor.getToDo(id: plannable.id)
            .sink(
                receiveCompletion: { [weak self] in
                    switch $0 {
                    case .finished:
                        break
                    case .failure:
                        // fallback to input plannable values
                        self?.updateValues(with: plannable)
                    }
                },
                receiveValue: { [weak self] in
                    self?.updateValues(with: $0)
                }
            )
            .store(in: &subscriptions)
    }

    private func updateValues(with plannable: Plannable) {
        title = plannable.title
        date = plannable.date?.dateTimeString
        description = plannable.details
        navBarColor = plannable.color.ensureContrast(against: .backgroundLightest)
    }

    public func showEditScreen(env: AppEnvironment, from source: WeakViewController) {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeEditToDoViewController(plannable: plannable) { _ in
            env.router.dismiss(weakVC)
        }
        weakVC.setValue(vc)

        env.router.show(vc, from: source, options: .modal(isDismissable: false, embedInNav: true))
    }

    public func deleteToDo(env: AppEnvironment, from source: WeakViewController) {
        interactor.deleteToDo(id: plannable.id)
            .sink(
                receiveCompletion: { [weak self] in
                    switch $0 {
                    case .finished:
                        break
                    case .failure:
                        self?.shouldShowDeleteError = true
                    }
                },
                receiveValue: {
                    env.router.pop(from: source)
                }
            )
            .store(in: &subscriptions)
    }
}
