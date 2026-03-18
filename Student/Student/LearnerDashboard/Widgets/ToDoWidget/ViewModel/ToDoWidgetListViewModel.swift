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

import Combine
import CombineSchedulers
import Core
import Foundation
import SwiftUI

@Observable
final class ToDoWidgetListViewModel {

    var items: [TodoItemViewModel] = []

    private let interactor: TodoInteractor
    private let router: Router
    private let snackBarViewModel: SnackBarViewModel
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    private var markDoneTimers: [String: AnyCancellable] = [:]

    init(
        interactor: TodoInteractor,
        router: Router,
        snackBarViewModel: SnackBarViewModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.interactor = interactor
        self.router = router
        self.snackBarViewModel = snackBarViewModel
        self.scheduler = scheduler
    }

    // MARK: - Item Actions

    func didTapItem(_ item: TodoItemViewModel, _ viewController: WeakViewController) {
        guard item.isTappable else {
            snackBarViewModel.showSnack(String(localized: "No additional details available.", bundle: .core))
            return
        }
        switch item.type {
        case .planner_note:
            let vc = PlannerAssembly.makeToDoDetailsViewController(plannableId: item.plannableId)
            router.show(vc, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
        case .calendar_event:
            let vc = PlannerAssembly.makeEventDetailsViewController(eventId: item.plannableId)
            router.show(vc, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
        default:
            guard let url = item.htmlURL else { return }
            router.route(to: url.appendingOrigin("todo"), from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
        }
    }

    func markItemAsDone(_ item: TodoItemViewModel) {
        guard item.markAsDoneState != .loading else { return }
        if item.markAsDoneState == .notDone {
            performMarkAsDone(item)
        } else {
            performMarkAsUndone(item)
        }
    }

    func handleSwipeCommitted(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
    }

    func handleSwipeAction(_ item: TodoItemViewModel) {
        if item.shouldToggleInPlaceAfterSwipe {
            toggleItemStateInPlace(item)
        } else {
            removeItemWithOptimisticUI(item)
        }
    }

    // MARK: - Private

    private func performMarkAsDone(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
        item.markAsDoneState = .loading
        interactor.markItemAsDone(item, done: true)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self, weak item] _ in
                guard let item else { return }
                item.markAsDoneState = .notDone
                self?.snackBarViewModel.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
            } receiveValue: { [weak self, weak item] overrideId in
                guard let self, let item else { return }
                item.overrideId = overrideId
                item.markAsDoneState = .done

                self.snackBarViewModel.showSnack(String(localized: "\(item.title) marked as done", bundle: .core))

                guard !item.shouldKeepCompletedItemsVisible else { return }
                let plannableId = item.plannableId
                let timer = Just(())
                    .delay(for: .seconds(3), scheduler: scheduler)
                    .sink { [weak self] in
                        withAnimation { self?.removeItem(with: plannableId) }
                        self?.markDoneTimers.removeValue(forKey: plannableId)
                    }
                markDoneTimers[plannableId] = timer
            }
            .store(in: &subscriptions)
    }

    private func performMarkAsUndone(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
        let itemTitle = item.title
        item.markAsDoneState = .loading
        interactor.markItemAsDone(item, done: false)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self, weak item] _ in
                item?.markAsDoneState = .done
                self?.snackBarViewModel.showSnack(String(localized: "Failed to mark item as not done", bundle: .core))
            } receiveValue: { [weak self, weak item] overrideId in
                item?.overrideId = overrideId
                item?.markAsDoneState = .notDone
                self?.snackBarViewModel.showSnack(String(localized: "\(itemTitle) marked as not done", bundle: .core))
            }
            .store(in: &subscriptions)
    }

    private func toggleItemStateInPlace(_ item: TodoItemViewModel) {
        let isCurrentlyDone = item.markAsDoneState == .done
        let itemTitle = item.title
        item.markAsDoneState = .loading
        interactor.markItemAsDone(item, done: !isCurrentlyDone)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self, weak item] _ in
                item?.markAsDoneState = isCurrentlyDone ? .done : .notDone
                self?.snackBarViewModel.showSnack(String(localized: "Failed to update item", bundle: .core))
            } receiveValue: { [weak self, weak item] overrideId in
                item?.overrideId = overrideId
                item?.markAsDoneState = isCurrentlyDone ? .notDone : .done
                if isCurrentlyDone {
                    self?.snackBarViewModel.showSnack(String(localized: "\(itemTitle) marked as not done", bundle: .core))
                } else {
                    self?.snackBarViewModel.showSnack(String(localized: "\(itemTitle) marked as done", bundle: .core))
                }
            }
            .store(in: &subscriptions)
    }

    private func removeItemWithOptimisticUI(_ item: TodoItemViewModel) {
        let itemId = item.plannableId
        let itemTitle = item.title
        withAnimation { removeItem(item) }
        interactor.markItemAsDone(item, done: true)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self] _ in
                self?.restoreItem(with: itemId)
                self?.snackBarViewModel.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
            } receiveValue: { [weak self, weak item] overrideId in
                item?.overrideId = overrideId
                item?.markAsDoneState = .done
                self?.snackBarViewModel.showSnack(String(localized: "\(itemTitle) marked as done", bundle: .core))
            }
            .store(in: &subscriptions)
    }

    private func removeItem(_ item: TodoItemViewModel) {
        guard let itemIndex = items.firstIndex(of: item) else { return }

        items.remove(at: itemIndex)
    }

    private func removeItem(with plannableId: String) {
        guard let itemIndex = items.firstIndex(where: { $0.plannableId == plannableId }) else { return }

        items.remove(at: itemIndex)
    }

    private func restoreItem(with plannableId: String) {
        guard let item = interactor.todoGroups.value
            .flatMap({ $0.items })
            .first(where: { $0.plannableId == plannableId })
        else { return }

        item.resetViewIdentity()
        item.markAsDoneState = .notDone

        withAnimation {
            var updatedItems = items
            updatedItems.append(item)
            updatedItems.sort()
            items = updatedItems
        }
    }

    private func cancelDelayedRemove(for item: TodoItemViewModel) {
        markDoneTimers[item.plannableId]?.cancel()
        markDoneTimers.removeValue(forKey: item.plannableId)
    }
}
