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
import Combine

public class TodoListViewModel: ObservableObject {

    @Published var items: [TodoItem] = []
    @Published var hasError: Bool = false

    private let env: AppEnvironment
    private let interactor: TodoInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(env: AppEnvironment = .shared, interactor: TodoInteractor? = nil) {
        self.env = env
        self.interactor = interactor ?? TodoInteractorLive(env: env, startDate: .now.startOfDay(), endDate: .now.addDays(28))
        refresh()
    }

    public func refresh(completion: (() -> Void)? = nil) {
        interactor.todosPublisher
            .catch { [weak self] _ in
                self?.hasError = true
                let empty: [TodoItem] = []
                return Just(empty).eraseToAnyPublisher()
            }
            .sink { [weak self] items in
                self?.hasError = false
                self?.items = items
            }
            .store(in: &subscriptions)

        if let completion {
            completion()
        }
    }

    func didTapItem(_ item: TodoItem, _ viewController: WeakViewController) {
        switch item.type {
        case .planner_note:
            let vc = PlannerAssembly.makeToDoDetailsViewController(plannableId: item.id)
            env.router.show(vc, from: viewController, options: .detail)
        case .calendar_event:
            let vc = PlannerAssembly.makeEventDetailsViewController(eventId: item.id)
            env.router.show(vc, from: viewController, options: .detail)
        default:
            guard let url = item.htmlURL else { return }
            let to = url.appendingOrigin("calendar")
            env.router.route(to: to, from: viewController, options: .detail)
            return
        }
    }
}
