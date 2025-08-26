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

public class TodoListViewModel: ObservableObject {

    @Published var items: [TodoItem] = []

    private let env: AppEnvironment
    private var todoStore: Store<GetPlannables>?
    private var coursesStore: Store<GetAllCourses>?

    init(env: AppEnvironment = .shared) {
        self.env = env
        self.coursesStore = env.subscribe(GetAllCourses()) { [weak self] in
            self?.fetchTodos()
        }
        self.coursesStore?.refresh()
    }

    private func fetchTodos() {
        guard let coursesStore, !coursesStore.pending else { return }
        var contextCodes: [String] = coursesStore.map(\.canvasContextID)
        if let userContextId = Context(.user, id: env.currentSession?.userID)?.canvasContextID {
            contextCodes.append(userContextId)
        }

        let start: Date = .now.startOfDay()
        let end: Date = start.addDays(28)
        let todoUseCase = GetPlannables(startDate: start, endDate: end, contextCodes: contextCodes)
        self.todoStore = env.subscribe(todoUseCase) { [weak self] in
            self?.handleFetchFinished()
        }
        self.todoStore?.refresh()
    }

    private func handleFetchFinished() {
        guard let todoStore, !todoStore.pending else { return }
        self.items = todoStore.compactMap(TodoItem.init)
    }

    func didTapItem(_ item: TodoItem, _ viewController: WeakViewController) {
        if let url = item.htmlURL {
            let to = url.appendingQueryItems(URLQueryItem(name: "origin", value: "todo"))
            env.router.route(to: to, from: viewController, options: .detail)
        }
    }
}
