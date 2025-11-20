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
    @Published private(set) var items: [TodoGroupViewModel] = []
    @Published private(set) var state: InstUI.ScreenState = .loading
    @Published private(set) var filterIcon: Image = .filterLine
    let screenConfig = InstUI.BaseScreenConfig(
        emptyPandaConfig: .init(
            scene: VacationPanda(),
            title: String(localized: "No To-dos for now!", bundle: .core),
            subtitle: String(localized: "It looks like a great time to rest, relax, and recharge.", bundle: .core)
        )
    )
    let snackBar = SnackBarViewModel()

    private static let autoRemovalDelay: TimeInterval = 3

    private let interactor: TodoInteractor
    private let router: Router
    private let sessionDefaults: SessionDefaults
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    /// Tracks cancellable timers for items in the done state waiting to be removed
    private var markDoneTimers: [String: AnyCancellable] = [:]
    /// Tracks item IDs that have been optimistically removed via swipe and are awaiting API response
    private var optimisticallyRemovedIds: Set<String> = []

    init(
        interactor: TodoInteractor,
        router: Router,
        sessionDefaults: SessionDefaults,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.sessionDefaults = sessionDefaults
        self.scheduler = scheduler

        interactor.todoGroups
            .receive(on: scheduler)
            .assign(to: \.items, on: self, ownership: .weak)
            .store(in: &subscriptions)

        updateFilterIcon()
        refresh(completion: { }, ignoreCache: false)
    }

    // MARK: - User Actions

    func refresh(completion: @escaping () -> Void, ignoreCache: Bool) {
        interactor.refresh(ignoreCache: ignoreCache)
            .receive(on: scheduler)
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
        guard item.isTappable else { return }

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

    func openFilter(_ viewController: WeakViewController) {
        let filterVC = TodoAssembly.makeTodoFilterViewController(
            sessionDefaults: sessionDefaults,
            onFiltersChanged: handleFiltersChanged
        )
        router.show(filterVC, from: viewController, options: .modal(embedInNav: true, addDoneButton: false))
    }

    func handleFiltersChanged() {
        updateFilterIcon()

        interactor.isCacheExpired()
            .sink { [weak self] cacheExpired in
                guard let self else { return }

                if cacheExpired {
                    self.state = .loading
                }

                self.refresh(completion: {}, ignoreCache: false)
            }
            .store(in: &subscriptions)
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

    /// Cancels any pending auto-removal timer immediately when swipe is committed.
    /// This is called before the animation delay to prevent the cell getting removed while the swipe animation is being finished for undo action.
    func handleSwipeCommitted(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
    }

    /// Performs the mark as done/undone action after the swipe animation completes.
    /// Timer cancellation happens earlier in handleSwipeCommitted to avoid race conditions.
    func handleSwipeAction(_ item: TodoItemViewModel) {
        if item.shouldToggleInPlaceAfterSwipe {
            toggleItemStateInPlace(item)
        } else {
            removeItemWithOptimisticUI(item)
        }
    }

    // MARK: - Private Methods -
    // MARK: Swipe Gesture

    private func toggleItemStateInPlace(_ item: TodoItemViewModel) {
        let isCurrentlyDone = item.markAsDoneState == .done
        item.markAsDoneState = .loading

        interactor.markItemAsDone(item, done: !isCurrentlyDone)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self, weak item] _ in
                guard let item else { return }
                item.markAsDoneState = isCurrentlyDone ? .done : .notDone
                self?.snackBar.showSnack(String(localized: "Failed to update item", bundle: .core))
            } receiveValue: { [weak item] _ in
                guard let item else { return }
                item.markAsDoneState = isCurrentlyDone ? .notDone : .done

                if isCurrentlyDone {
                    TabBarBadgeCounts.todoListCount += 1
                } else {
                    if TabBarBadgeCounts.todoListCount > 0 {
                        TabBarBadgeCounts.todoListCount -= 1
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func removeItemWithOptimisticUI(_ item: TodoItemViewModel) {
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

    // MARK: List Management

    private func removeItem(_ item: TodoItemViewModel) {
        items = items.compactMap { group in
            let filteredItems = group.items.filter { $0.plannableId != item.plannableId }
            guard !filteredItems.isEmpty else { return nil }
            return TodoGroupViewModel(date: group.date, items: filteredItems)
        }

        if items.isEmpty {
            state = .empty
        }
    }

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

    // MARK: Checkbox Button Actions

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

                let announcement = String(
                    localized: "\(item.title), marked as not done",
                    bundle: .core,
                    comment: "VoiceOver announcement when a to-do item is unmarked as complete. The item title is inserted before the status message."
                )
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
            .delay(for: .seconds(Self.autoRemovalDelay), scheduler: scheduler)
            .sink { [weak self] in
                withAnimation {
                    self?.removeItem(item)
                }
                self?.markDoneTimers.removeValue(forKey: item.plannableId)
            }

        markDoneTimers[item.plannableId] = timer

        let announcement = String(
            localized: "\(item.title), marked as done",
            bundle: .core,
            comment: "VoiceOver announcement when a to-do item is marked as complete. The item title is inserted before the status message."
        )
        UIAccessibility.announce(announcement)
    }

    private func handleMarkAsDoneError(_ item: TodoItemViewModel, _ error: Error) {
        item.markAsDoneState = .notDone
        snackBar.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
    }

    private func handleMarkAsUndoneError(_ item: TodoItemViewModel, _ error: Error) {
        item.markAsDoneState = .done
        snackBar.showSnack(String(localized: "Failed to mark item as not done", bundle: .core))
    }

    // MARK: Filter Updates

    private func updateFilterIcon() {
        let filterOptions = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default
        filterIcon = filterOptions.isDefault ? .filterLine : .filterSolid
    }
}
