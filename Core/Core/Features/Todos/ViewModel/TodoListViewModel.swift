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

    private let env: AppEnvironment
    private let interactor: TodoInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(env: AppEnvironment = .shared, interactor: TodoInteractor? = nil) {
        self.env = env
        self.interactor = interactor ?? TodoInteractorLive(env: env, startDate: .now.startOfDay(), endDate: .now.addDays(28))
        getItems()
    }

    private func getItems() {
        interactor.todosPublisher
            .sink(receiveValue: { [weak self] items in
                self?.items = items
            })
            .store(in: &subscriptions)
    }

    func didTapItem(_ item: TodoItem, _ viewController: WeakViewController) {
        if let url = item.htmlURL {
            let to = url.appendingQueryItems(URLQueryItem(name: "origin", value: "todo"))
            env.router.route(to: to, from: viewController, options: .detail)
        }
    }
}
