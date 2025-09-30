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
import CombineExt
import UIKit

public class TodoListViewModel: ObservableObject {
    @Published var items: [TodoGroup] = []
    @Published var state: InstUI.ScreenState = .loading

    private let interactor: TodoInteractor
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: TodoInteractor, env: AppEnvironment) {
        self.interactor = interactor
        self.env = env

        interactor.todoGroups
            .assign(to: \.items, on: self, ownership: .weak)
            .store(in: &subscriptions)

        refresh(completion: { }, ignoreCache: false)
    }

    public func refresh(completion: @escaping () -> Void, ignoreCache: Bool) {
        interactor.refresh(ignoreCache: ignoreCache)
            .sinkFailureOrValue { [weak self] _ in
                self?.state = .error
                completion()
            } receiveValue: { [weak self] _ in
                let isListEmpty = self?.items.isEmpty == true
                self?.state = isListEmpty ? .empty : .data
                completion()
            }
            .store(in: &subscriptions)
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
            let to = url.appendingOrigin("todo")
            env.router.route(to: to, from: viewController, options: .detail)
            return
        }
    }

    func openProfile(_ viewController: WeakViewController) {
        env.router.route(to: "/profile", from: viewController, options: .modal())
    }

    func didTapDayHeader(_ group: TodoGroup, viewController: WeakViewController) {
        let tabController = viewController.value.tabBarController
        tabController?.selectedIndex = 1 // Switch to Calendar tab
        let splitController = tabController?.selectedViewController as? UISplitViewController
        splitController?.resetToRoot()
        let plannerController = splitController?.masterTopViewController as? PlannerViewController
        plannerController?.onAppearOnce {
            plannerController?.selectDate(group.date)
        }
    }
}
