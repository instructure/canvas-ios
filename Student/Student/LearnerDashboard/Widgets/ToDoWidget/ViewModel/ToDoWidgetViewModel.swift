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
import Core
import Foundation
import SwiftUI

@Observable
final class ToDoWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = ToDoWidgetView

    let config: DashboardWidgetConfig
    let isEditable = false
    let isHiddenInEmptyState = false
    let snackBarViewModel: SnackBarViewModel

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var selectedDay: Date
    private(set) var weekStart: Date
    private(set) var showCompleted: Bool
    private(set) var isDayLoading: Bool = false

    private var allGroups: [TodoGroupViewModel] = [] {
        didSet { updateItemCounts() }
    }

    var dayItems: [TodoItemViewModel] {
        let items = allGroups
            .first { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }?
            .items ?? []
        return visibleItems(from: items)
    }

    var datesWithItems: Set<Date> {
        Set(allGroups.map { Calendar.current.startOfDay(for: $0.date) })
    }

    private(set) var itemCounts: [Date: Int] = [:]

    var isShowingToday: Bool {
        Calendar.current.isDateInToday(selectedDay)
    }

    var layoutIdentifier: [AnyHashable] {
        [state, dayItems.count, selectedDay, showCompleted, isDayLoading]
    }

    private let interactor: TodoInteractor
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    private var markDoneTimers: [String: AnyCancellable] = [:]

    init(
        config: DashboardWidgetConfig,
        interactor: TodoInteractor,
        router: Router,
        snackBarViewModel: SnackBarViewModel
    ) {
        self.config = config
        self.interactor = interactor
        self.router = router
        self.snackBarViewModel = snackBarViewModel
        self.showCompleted = false
        let today = Calendar.current.startOfDay(for: Clock.now)
        self.selectedDay = today
        self.weekStart = Self.startOfWeek(for: today)
        setupSubscriptions()
        loadItems(for: self.weekStart, ignorePlannablesCache: false)
    }

    func makeView() -> ToDoWidgetView {
        ToDoWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        let start = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: weekStart) ?? weekStart
        let end = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: weekStart) ?? weekStart
        return interactor
            .refresh(
                startDate: start,
                endDate: end,
                ignorePlannablesCache: ignoreCache,
                ignoreCoursesCache: ignoreCache,
                filterOptions: TodoFilterOptions(
                    visibilityOptions: [.showCalendarEvents, .showCompleted, .showPersonalTodos], dateRangeStart: .lastWeek, dateRangeEnd: .nextWeek
                )
            )
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.state = .error
                }
            })
            .catch { _ in Just(()) }
            .eraseToAnyPublisher()
    }

    // MARK: - Week Navigation

    func navigateToToday() {
        let today = Calendar.current.startOfDay(for: Clock.now)
        selectedDay = today
        weekStart = Self.startOfWeek(for: today)
    }

    func selectDay(_ date: Date) {
        selectedDay = Calendar.current.startOfDay(for: date)
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
            router.show(vc, from: viewController, options: .detail)
        case .calendar_event:
            let vc = PlannerAssembly.makeEventDetailsViewController(eventId: item.plannableId)
            router.show(vc, from: viewController, options: .detail)
        default:
            guard let url = item.htmlURL else { return }
            router.route(to: url.appendingOrigin("todo"), from: viewController, options: .detail)
        }
    }

    func createToDo(from viewController: WeakViewController) {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateToDoViewController(selectedDate: selectedDay) { [weak self] _ in
            guard let self else { return }
            self.router.dismiss(weakVC)
            self.loadItems(for: self.weekStart, ignorePlannablesCache: true)
        }
        weakVC.setValue(vc)
        router.show(vc, from: viewController, options: .modal(embedInNav: true))
    }

    func retryLoad() {
        state = .loading
        loadItems(for: weekStart, ignorePlannablesCache: true)
    }

    func toggleShowCompleted() {
        showCompleted.toggle()
        if showCompleted {
            markDoneTimers.values.forEach { $0.cancel() }
            markDoneTimers.removeAll()
            allGroups = interactor.todoGroups.value
        }
        for group in allGroups {
            for item in group.items {
                item.shouldKeepCompletedItemsVisible = showCompleted
            }
        }
        updateItemCounts()
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

    private func visibleItems(from items: [TodoItemViewModel]) -> [TodoItemViewModel] {
        showCompleted ? items : items.filter { $0.markAsDoneState != .done }
    }

    private func updateItemCounts() {
        itemCounts = allGroups.reduce(into: [:]) { result, group in
            result[Calendar.current.startOfDay(for: group.date)] = visibleItems(from: group.items).count
        }
    }

    private func setupSubscriptions() {
        interactor.todoGroups
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                guard let self else { return }
                for group in groups {
                    for item in group.items {
                        item.shouldKeepCompletedItemsVisible = showCompleted
                    }
                }
                allGroups = groups
                isDayLoading = false
                state = groups.isEmpty ? .empty : .data
            }
            .store(in: &subscriptions)
    }

    private func loadItems(for weekStart: Date, ignorePlannablesCache: Bool) {
        let start = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: weekStart) ?? weekStart
        let end = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: weekStart) ?? weekStart
        loadCancellable = interactor
            .refresh(
                startDate: start,
                endDate: end,
                ignorePlannablesCache: ignorePlannablesCache,
                ignoreCoursesCache: false,
                filterOptions: TodoFilterOptions(
                    visibilityOptions: [.showCalendarEvents, .showCompleted, .showPersonalTodos], dateRangeStart: .lastWeek, dateRangeEnd: .nextWeek
                )
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.state = .error
                        self?.isDayLoading = false
                    }
                },
                receiveValue: { }
            )
    }

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
                    .delay(for: .seconds(3), scheduler: DispatchQueue.main)
                    .sink { [weak self] in
                        withAnimation { self?.removeItem(withId: plannableId) }
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
                self?.restoreItem(withId: itemId)
                self?.snackBarViewModel.showSnack(String(localized: "Failed to mark item as done", bundle: .core))
            } receiveValue: { [weak self, weak item] overrideId in
                item?.overrideId = overrideId
                item?.markAsDoneState = .done
                self?.snackBarViewModel.showSnack(String(localized: "\(itemTitle) marked as done", bundle: .core))
            }
            .store(in: &subscriptions)
    }

    private func removeItem(_ item: TodoItemViewModel) {
        removeItem(withId: item.plannableId)
    }

    private func removeItem(withId plannableId: String) {
        allGroups = allGroups.compactMap { group in
            let filtered = group.items.filter { $0.plannableId != plannableId }
            return filtered.isEmpty ? nil : TodoGroupViewModel(date: group.date, items: filtered)
        }
        if allGroups.isEmpty { state = .empty }
    }

    private func restoreItem(withId itemId: String) {
        guard let item = interactor.todoGroups.value
            .flatMap({ $0.items })
            .first(where: { $0.plannableId == itemId }) else { return }
        item.resetViewIdentity()
        item.markAsDoneState = .notDone
        withAnimation {
            let groupDate = item.date.startOfDay()
            var updated = allGroups
            if let idx = updated.firstIndex(where: { $0.date == groupDate }) {
                var groupItems = updated[idx].items
                groupItems.append(item)
                groupItems.sort()
                updated[idx] = TodoGroupViewModel(date: groupDate, items: groupItems)
            } else {
                updated.append(TodoGroupViewModel(date: groupDate, items: [item]))
                updated.sort()
            }
            allGroups = updated
            if state == .empty { state = .data }
        }
    }

    private func cancelDelayedRemove(for item: TodoItemViewModel) {
        markDoneTimers[item.plannableId]?.cancel()
        markDoneTimers.removeValue(forKey: item.plannableId)
    }

    func setWeek(absoluteOffset offset: Int) {
        let base = Self.startOfWeek(for: Clock.now)
        guard let newWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: base) else { return }
        weekStart = newWeekStart
        let today = Calendar.current.startOfDay(for: Clock.now)
        selectedDay = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: today) ?? today
        isDayLoading = dayItems.isEmpty
        loadItems(for: newWeekStart, ignorePlannablesCache: false)
    }

    internal static func startOfWeek(for date: Date) -> Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: date)?.start ?? Calendar.current.startOfDay(for: date)
    }
}
