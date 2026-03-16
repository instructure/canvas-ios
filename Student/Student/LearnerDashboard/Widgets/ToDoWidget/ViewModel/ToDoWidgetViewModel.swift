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
final class ToDoWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = ToDoWidgetView

    let config: DashboardWidgetConfig
    let isHiddenInEmptyState = false
    let snackBarViewModel: SnackBarViewModel

    private(set) var state: InstUI.ScreenState = .loading

    private(set) var selectedDay: Date = .distantPast
    private var startOfWeek: Date = .distantPast
    private(set) var currentWeekDays: [Date] = []
    private(set) var yearTitle: String?
    private(set) var monthTitle: String = ""

    var showCompleted: Bool = false {
        didSet { showCompletedDidChange() }
    }
    private(set) var isDayLoading: Bool = false

    private var allGroups: [TodoGroupViewModel] = [] {
        didSet { updateItemCounts() }
    }

    var dayItems: [TodoItemViewModel] {
        let items = allGroups
            .first { $0.date.isInSameDay(as: selectedDay) }?
            .items ?? []
        return visibleItems(from: items)
    }

    var datesWithItems: Set<Date> {
        Set(allGroups.map { Calendar.current.startOfDay(for: $0.date) })
    }

    private(set) var itemCounts: [Date: Int] = [:]

    var shouldShowTodayButton: Bool {
        !selectedDay.isToday
    }

    var layoutIdentifier: [AnyHashable] {
        [state, dayItems.count, selectedDay, showCompleted, isDayLoading]
    }

    private static let widgetFilterOptions = TodoFilterOptions(
        visibilityOptions: [.showCalendarEvents, .showCompleted, .showPersonalTodos],
        dateRangeStart: .lastWeek,
        dateRangeEnd: .nextWeek
    )

    private let interactor: TodoInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    private var markDoneTimers: [String: AnyCancellable] = [:]

    init(
        config: DashboardWidgetConfig,
        interactor: TodoInteractor,
        router: Router,
        snackBarViewModel: SnackBarViewModel,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
    ) {
        self.config = config
        self.interactor = interactor
        self.router = router
        self.snackBarViewModel = snackBarViewModel
        self.scheduler = scheduler

        selectDay(Clock.now)

        setupSubscriptions()
        loadItemsForWeek(ignorePlannablesCache: false)
    }

    func makeView() -> ToDoWidgetView {
        ToDoWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        let (start, end) = widgetDateRange(for: startOfWeek)
        return interactor.refresh(
            startDate: start,
            endDate: end,
            ignorePlannablesCache: ignoreCache,
            ignoreCoursesCache: ignoreCache,
            filterOptions: Self.widgetFilterOptions
        )
        .receive(on: DispatchQueue.main)
        .catch { [weak self] _ in
            self?.state = .error
            return Just(())
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Week Navigation

    func didTapDay(_ date: Date) {
        selectDay(date)
    }

    func didTapTodayButton() {
        selectDay(Clock.now)
    }

    func setWeek(absoluteOffset offset: Int) {
        let selectedDayIndexInWeek = selectedDay.dayDifference(from: selectedDay.startOfWeek())
        let startOfNewWeek = Clock.now.startOfWeek().addWeeks(offset)
        let newDay = startOfNewWeek.addDays(selectedDayIndexInWeek)
        selectDay(newDay)

        isDayLoading = dayItems.isEmpty
        loadItemsForWeek(ignorePlannablesCache: false)
    }

    func weekDays(forOffset offset: Int) -> [Date] {
        let startOfWeek = Clock.now.startOfWeek().addWeeks(offset)
        return weekDays(of: startOfWeek)
    }

    private func selectDay(_ date: Date) {
        let day = date.startOfDay()
        guard selectedDay != day else { return }

        selectedDay = day
        startOfWeek = day.startOfWeek()
        currentWeekDays = weekDays(of: startOfWeek)
        yearTitle = day.isCurrentYear ? nil : day.formatted(.dateTime.year())
        monthTitle = day.formatted(.dateTime.month(.wide))
    }

    private func weekDays(of startOfWeek: Date) -> [Date] {
        (0..<7).compactMap { startOfWeek.addDays($0) }
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

    func createToDo(from viewController: WeakViewController) {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateToDoViewController(selectedDate: selectedDay) { [weak self] _ in
            guard let self else { return }
            self.router.dismiss(weakVC)
        }
        weakVC.setValue(vc)
        router.show(vc, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
    }

    func retryLoad() {
        state = .loading
        loadItemsForWeek(ignorePlannablesCache: true)
    }

    private func showCompletedDidChange() {
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

    private func widgetDateRange(for weekStart: Date) -> (start: Date, end: Date) {
        let start = weekStart.addWeeks(-1)
        let end = weekStart.addWeeks(2)
        return (start, end)
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
                let hasVisibleItems = !groups.flatMap { self.visibleItems(from: $0.items) }.isEmpty
                state = hasVisibleItems ? .data : .empty
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: .plannerItemDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                loadItemsForWeek(ignorePlannablesCache: true)
            }
            .store(in: &subscriptions)
    }

    private func loadItemsForWeek(ignorePlannablesCache: Bool) {
        let (start, end) = widgetDateRange(for: startOfWeek)
        loadCancellable = interactor
            .refresh(
                startDate: start,
                endDate: end,
                ignorePlannablesCache: ignorePlannablesCache,
                ignoreCoursesCache: false,
                filterOptions: Self.widgetFilterOptions
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
                    .delay(for: .seconds(3), scheduler: scheduler)
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
}
