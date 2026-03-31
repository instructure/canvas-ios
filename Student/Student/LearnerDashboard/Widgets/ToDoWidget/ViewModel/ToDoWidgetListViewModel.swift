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

    private static let autoRemovalDelay: TimeInterval = 3

    var items: [TodoItemViewModel] = []
    var itemDidUpdate: (() -> Void)?
    var itemDidRemoveAfterDelay: (() -> Void)?
    var showCompleted: Bool = false

    private let interactor: TodoInteractor
    private let router: Router
    private let snackBar: SnackBarViewModel
    private let scheduler: AnySchedulerOf<DispatchQueue>

    private var subscriptions = Set<AnyCancellable>()

    /// Tracks cancellable timers for items in the done state waiting to be removed
    private(set) var markDoneTimers: [String: AnyCancellable] = [:]

    init(
        interactor: TodoInteractor,
        router: Router,
        snackBarViewModel: SnackBarViewModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.interactor = interactor
        self.router = router
        self.snackBar = snackBarViewModel
        self.scheduler = scheduler
    }

    // MARK: - Item Action

    func didTapItem(_ item: TodoItemViewModel, _ viewController: WeakViewController) {
        guard item.isTappable else {
            showSnackForNoDetailsTap()
            return
        }

        switch item.type {
        case .planner_note:
            let vc = PlannerAssembly.makeToDoDetailsViewController(plannableId: item.plannableId)
            router.show(vc, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
        case .calendar_event:
            let vc = PlannerAssembly.makeEventDetailsViewController(eventId: item.plannableId) { [weak self] in
                if $0 == .didUpdate {
                    self?.itemDidUpdate?()
                }
            }
            router.show(vc, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
        default:
            guard let url = item.htmlURL else { return }
            router.route(to: url.appendingOrigin("todo"), from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
        }
    }

    // MARK: - Checkbox Actions

    func markItemAsDone(_ item: TodoItemViewModel) {
        guard item.markAsDoneState != .loading else { return }

        if item.markAsDoneState == .notDone {
            performMarkAsDone(item)
        } else {
            performMarkAsUndone(item)
        }
    }

    private func performMarkAsDone(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
        item.markAsDoneState = .loading

        interactor.markItemAsDone(item, done: true)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self, weak item] _ in
                item?.markAsDoneState = .notDone
                self?.showSnackForFailedDone()
            } receiveValue: { [weak self, weak item] overrideId in
                item?.overrideId = overrideId
                self?.handleMarkAsDoneSuccess(item)
            }
            .store(in: &subscriptions)
    }

    private func performMarkAsUndone(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
        item.markAsDoneState = .loading

        interactor.markItemAsDone(item, done: false)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self, weak item] _ in
                item?.markAsDoneState = .done
                self?.showSnackForFailedUndone()
            } receiveValue: { [weak self, weak item] overrideId in
                item?.overrideId = overrideId
                self?.handleMarkAsUndoneSuccess(item)
            }
            .store(in: &subscriptions)
    }

    private func handleMarkAsDoneSuccess(_ item: TodoItemViewModel?) {
        guard let item else { return }

        item.markAsDoneState = .done
        a11yAnnounceDone(item)

        if showCompleted {
            return
        }

        let timer = Just(())
            .delay(for: .seconds(Self.autoRemovalDelay), scheduler: scheduler)
            .sink { [weak self] in
                withAnimation {
                    self?.removeItem(item)
                }
                self?.markDoneTimers.removeValue(forKey: item.plannableId)
                // Trigger a state change, because this removal is UI only,
                // it won't trigger an interactor.todoGroup publish.
                self?.itemDidRemoveAfterDelay?()
            }
        markDoneTimers[item.plannableId] = timer
    }

    private func handleMarkAsUndoneSuccess(_ item: TodoItemViewModel?) {
        guard let item else { return }

        item.markAsDoneState = .notDone
        a11yAnnounceUndone(item)
    }

    func invalidateMarkDoneTimers() {
        markDoneTimers.values.forEach { $0.cancel() }
        markDoneTimers.removeAll()
    }

    // MARK: - Swipe Actions

    func handleSwipeCommitted(_ item: TodoItemViewModel) {
        cancelDelayedRemove(for: item)
    }

    func handleSwipeAction(_ item: TodoItemViewModel) {
        if item.markAsDoneState == .done || showCompleted {
            toggleItemStateInPlace(item)
        } else {
            removeItemWithOptimisticUI(item)
        }
    }

    private func toggleItemStateInPlace(_ item: TodoItemViewModel) {
        let isCurrentlyDone = item.markAsDoneState == .done
        item.markAsDoneState = .loading

        interactor.markItemAsDone(item, done: !isCurrentlyDone)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self, weak item] _ in
                item?.markAsDoneState = isCurrentlyDone ? .done : .notDone
                if isCurrentlyDone {
                    self?.showSnackForFailedUndone()
                } else {
                    self?.showSnackForFailedDone()
                }
            } receiveValue: { [weak item] overrideId in
                item?.overrideId = overrideId
                item?.markAsDoneState = isCurrentlyDone ? .notDone : .done
            }
            .store(in: &subscriptions)
    }

    private func removeItemWithOptimisticUI(_ item: TodoItemViewModel) {
        withAnimation {
            removeItem(item)
        }

        let itemId = item.plannableId

        interactor.markItemAsDone(item, done: true)
            .receive(on: DispatchQueue.main)
            .sinkFailureOrValue { [weak self] _ in
                self?.restoreItem(with: itemId)
                self?.showSnackForFailedDone()
            } receiveValue: { [weak item] overrideId in
                item?.overrideId = overrideId
                item?.markAsDoneState = .done
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Remove/Restore item

    private func removeItem(_ item: TodoItemViewModel) {
        guard let itemIndex = items.firstIndex(of: item) else { return }

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

// MARK: - Notify User

private extension ToDoWidgetListViewModel {

    func a11yAnnounceDone(_ item: TodoItemViewModel) {
        let announcement = String(
            localized: "\(item.title), marked as done",
            bundle: .core,
            comment: "VoiceOver announcement when a to-do item is marked as complete. The item title is inserted before the status message."
        )
        UIAccessibility.announce(announcement)
    }

    func a11yAnnounceUndone(_ item: TodoItemViewModel) {
        let announcement = String(
            localized: "\(item.title), marked as not done",
            bundle: .core,
            comment: "VoiceOver announcement when a to-do item is unmarked as complete. The item title is inserted before the status message."
        )
        UIAccessibility.announce(announcement)
    }

    func showSnackForFailedDone() {
        snackBar.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
    }

    func showSnackForFailedUndone() {
        snackBar.showSnack(String(localized: "Failed to mark item as not done", bundle: .core))
    }

    func showSnackForNoDetailsTap() {
        snackBar.showSnack(String(localized: "No additional details available.", bundle: .core))
    }
}
