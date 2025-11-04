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
import CombineSchedulers
import SwiftUI

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoGroupViewModel] = []
    @Published var state: InstUI.ScreenState = .loading
    let screenConfig = InstUI.BaseScreenConfig(
        emptyPandaConfig: .init(
            scene: VacationPanda(),
            title: String(localized: "No To-dos for now!", bundle: .core),
            subtitle: String(localized: "It looks like a great time to rest, relax, and recharge.", bundle: .core)
        )
    )
    let snackBar = SnackBarViewModel()

    private let interactor: TodoInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    /// Tracks cancellable timers for items in the done state waiting to be removed after 3 seconds
    private var markDoneTimers: [String: AnyCancellable] = [:]
    /// Tracks item IDs that have been optimistically removed via swipe and are awaiting API response
    private var optimisticallyRemovedIds: Set<String> = []

    init(
        interactor: TodoInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler

        interactor.todoGroups
            .assign(to: \.items, on: self, ownership: .weak)
            .store(in: &subscriptions)

        refresh(completion: { }, ignoreCache: false)
    }

    // MARK: - User Actions

    func refresh(completion: @escaping () -> Void, ignoreCache: Bool) {
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
            let vc = PlannerAssembly.makeToDoDetailsViewController(plannableId: item.plannableId)
            router.show(vc, from: viewController, options: .detail)
        case .calendar_event:
            let vc = PlannerAssembly.makeEventDetailsViewController(eventId: item.plannableId)
            router.show(vc, from: viewController, options: .detail)
        default:
            guard let url = item.htmlURL else { return }
            let to = url.appendingOrigin("todo")
            router.route(to: to, from: viewController, options: .detail)
            return
        }
    }

    func openProfile(_ viewController: WeakViewController) {
        router.route(to: "/profile", from: viewController, options: .modal())
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
        if item.markAsDoneState == .loading {
            return
        }

        if item.markAsDoneState == .notDone {
            performMarkAsDone(item)
        } else if item.markAsDoneState == .done {
            performMarkAsUndone(item)
        }
    }

    func markItemAsDoneWithOptimisticUI(_ item: TodoItemViewModel) {
        optimisticallyRemovedIds.insert(item.plannableId)

        withAnimation {
            removeItem(item)
        }

        let itemId = item.plannableId

        interactor.markItemAsDone(item, done: true)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] _ in
                guard let self else { return }
                self.restoreItem(withId: itemId)
                self.optimisticallyRemovedIds.remove(itemId)
                self.snackBar.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                self.optimisticallyRemovedIds.remove(itemId)

                if TabBarBadgeCounts.todoListCount > 0 {
                    TabBarBadgeCounts.todoListCount -= 1
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func restoreItem(withId itemId: String) {
        guard let itemToRestore = interactor.todoGroups.value
            .flatMap({ $0.items })
            .first(where: { $0.plannableId == itemId }) else {
            return
        }
        // We need to reset the view's ID otherwise the previous state of the cell (swiped left) will be restored.
        itemToRestore.resetViewIdentity()

        withAnimation {
            var updatedItems = items
            let groupDate = itemToRestore.date.startOfDay()

            if let groupIndex = updatedItems.firstIndex(where: { $0.date == groupDate }) {
                let group = updatedItems[groupIndex]
                var groupItems = group.items
                groupItems.append(itemToRestore)
                groupItems.sort()
                updatedItems[groupIndex] = TodoGroupViewModel(date: group.date, items: groupItems)
            } else {
                let newGroup = TodoGroupViewModel(date: groupDate, items: [itemToRestore])
                updatedItems.append(newGroup)
                updatedItems.sort()
            }

            items = updatedItems

            if state == .empty {
                state = .data
            }
        }
    }

    private func performMarkAsDone(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
        item.markAsDoneState = .loading

        interactor.markItemAsDone(item, done: true)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self, weak item] error in
                guard let item else { return }
                self?.handleMarkAsDoneError(item, error)
            } receiveValue: { [weak self, weak item] _ in
                guard let self, let item else { return }
                self.handleMarkAsDoneSuccess(item)
            }
            .store(in: &subscriptions)
    }

    private func performMarkAsUndone(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
        item.markAsDoneState = .loading

        interactor.markItemAsDone(item, done: false)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self, weak item] error in
                guard let item else { return }
                self?.handleMarkAsUndoneError(item, error)
            } receiveValue: { [weak item] _ in
                guard let item else { return }
                item.markAsDoneState = .notDone
                TabBarBadgeCounts.todoListCount += 1

                let announcement = String(localized: "\(item.title), marked as not done", bundle: .core)
                UIAccessibility.announce(announcement)
            }
            .store(in: &subscriptions)
    }

    private func cancelDelayedRemove(for item: TodoItemViewModel) {
        markDoneTimers[item.plannableId]?.cancel()
        markDoneTimers.removeValue(forKey: item.plannableId)
    }

    private func handleMarkAsDoneSuccess(_ item: TodoItemViewModel) {
        item.markAsDoneState = .done

        if TabBarBadgeCounts.todoListCount > 0 {
            TabBarBadgeCounts.todoListCount -= 1
        }

        let timer = Just(())
            .delay(for: .seconds(3), scheduler: scheduler)
            .sink { [weak self] in
                withAnimation {
                    self?.removeItem(item)
                }
                self?.markDoneTimers.removeValue(forKey: item.plannableId)
            }

        markDoneTimers[item.plannableId] = timer
    }

    private func handleMarkAsDoneError(_ item: TodoItemViewModel, _ error: Error) {
        item.markAsDoneState = .notDone
        snackBar.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
    }

    private func handleMarkAsUndoneError(_ item: TodoItemViewModel, _ error: Error) {
        item.markAsDoneState = .done
        snackBar.showSnack(String(localized: "Failed to mark item as not done", bundle: .core))
    }

    private func removeItem(_ item: TodoItemViewModel) {
        items = items.compactMap { group in
            let filteredItems = group.items.filter { $0.plannableId != item.plannableId }
            guard !filteredItems.isEmpty else { return nil }
            return TodoGroupViewModel(date: group.date, items: filteredItems)
        }

        if items.isEmpty {
            state = .empty
        }

        let announcement = String(localized: "\(item.title), marked as done", bundle: .core)
        UIAccessibility.announce(announcement)
    }
}
