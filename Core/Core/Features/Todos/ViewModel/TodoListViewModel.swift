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
    @Published var items: [TodoGroupViewModel] = []
    @Published var state: InstUI.ScreenState = .loading
    let screenConfig = InstUI.BaseScreenConfig(
        emptyPandaConfig: .init(
            scene: VacationPanda(),
            title: String(localized: "No To-dos for now!", bundle: .core),
            subtitle: String(localized: "It looks like a great time to rest, relax, and recharge.", bundle: .core)
        )
    )

    private let interactor: TodoInteractor
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()
    /// Tracks cancellable timers for items in the done state waiting to be removed after 3 seconds
    private var markDoneTimers: [String: AnyCancellable] = [:]

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

    func didTapItem(_ item: TodoItemViewModel, _ viewController: WeakViewController) {
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

    func didTapDayHeader(_ group: TodoGroupViewModel, viewController: WeakViewController) {
        let tabController = viewController.value.tabBarController
        tabController?.selectedIndex = 1 // Switch to Calendar tab
        let splitController = tabController?.selectedViewController as? UISplitViewController
        splitController?.resetToRoot()
        let plannerController = splitController?.masterTopViewController as? PlannerViewController
        plannerController?.onAppearOnce {
            plannerController?.selectDate(group.date)
        }
    }

    func markItemAsDone(_ item: TodoItemViewModel) {
        if item.markDoneState == .notDone {
            performMarkAsDone(item)
        } else if item.markDoneState == .done {
            performMarkAsUndone(item)
        }
    }

    private func performMarkAsDone(_ item: TodoItemViewModel) {
        markDoneTimers[item.id]?.cancel()
        item.markDoneState = .loading

        let useCase = MarkPlannableItemDone(
            plannableId: item.id,
            plannableType: item.plannableType,
            overrideId: item.overrideId,
            done: true
        )

        useCase.fetch(environment: env) { [weak self, weak item] _, _, error in
            guard let self, let item else { return }

            if let error {
                self.handleMarkAsDoneError(item, error)
            } else {
                self.handleMarkAsDoneSuccess(item)
            }
        }
    }

    private func performMarkAsUndone(_ item: TodoItemViewModel) {
        markDoneTimers[item.id]?.cancel()
        markDoneTimers.removeValue(forKey: item.id)
        item.markDoneState = .loading

        let useCase = MarkPlannableItemDone(
            plannableId: item.id,
            plannableType: item.plannableType,
            overrideId: item.overrideId,
            done: false
        )

        useCase.fetch(environment: env) { [weak self, weak item] _, _, error in
            guard let self, let item else { return }

            if let error {
                self.handleMarkAsUndoneError(item, error)
            } else {
                item.markDoneState = .notDone
            }
        }
    }

    private func handleMarkAsDoneSuccess(_ item: TodoItemViewModel) {
        item.markDoneState = .done

        let timer = Just(())
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.removeItem(item)
                self?.markDoneTimers.removeValue(forKey: item.id)
            }

        markDoneTimers[item.id] = timer
    }

    private func handleMarkAsDoneError(_ item: TodoItemViewModel, _ error: Error) {
        item.markDoneState = .notDone
        // TODO: Show error snackbar in Phase 6
        print("Error marking as done: \(error)")
    }

    private func handleMarkAsUndoneError(_ item: TodoItemViewModel, _ error: Error) {
        item.markDoneState = .done
        // TODO: Show error snackbar in Phase 6
        print("Error marking as undone: \(error)")
    }

    private func removeItem(_ item: TodoItemViewModel) {
        items = items.compactMap { group in
            let filteredItems = group.items.filter { $0.id != item.id }
            guard !filteredItems.isEmpty else { return nil }
            return TodoGroupViewModel(date: group.date, items: filteredItems)
        }

        if items.isEmpty {
            state = .empty
        }
    }
}
