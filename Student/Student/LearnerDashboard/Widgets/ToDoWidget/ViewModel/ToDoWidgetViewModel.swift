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
    let id: String = EditableWidgetIdentifier.todo.rawValue

    let config: DashboardWidgetConfig
    let isHiddenInEmptyState = false

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var selectedDay: Date = .distantPast
    private(set) var currentWeekDays: [Date] = []
    private(set) var yearTitle: String?
    private(set) var monthTitle: String = ""

    private(set) var itemCountPerDay: [Date: Int] = [:]
    let listViewModel: ToDoWidgetListViewModel

    var showCompleted: Bool = false {
        didSet { showCompletedDidChange() }
    }

    var shouldShowTodayButton: Bool {
        !selectedDay.isToday
    }

    var layoutIdentifier: [AnyHashable] {
        [state, listViewModel.items.count]
    }

    private let interactor: TodoInteractor
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    private var allItemsPerDay: [Date: [TodoItemViewModel]] = [:]
    private var startOfWeek: Date = .distantPast

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

        self.listViewModel = ToDoWidgetListViewModel(
            interactor: interactor,
            router: router,
            snackBarViewModel: snackBarViewModel,
            scheduler: scheduler
        )
        listViewModel.itemDidUpdate = { [weak self] in
            // Force refresh because CalendarEvent changes are not propagated to Plannable objects
            self?.loadItemsForWeek(ignorePlannablesCache: true)
        }
        listViewModel.itemDidRemoveAfterDelay = { [weak self] in
            guard let self else { return }
            state = listViewModel.items.isEmpty ? .empty : .data
        }

        selectDay(Clock.now)

        observeTodoGroups()
        observePlannerItems()
    }

    func makeView() -> AnyView {
        AnyView(ToDoWidgetView(viewModel: self))
    }

    // MARK: - Refresh / Load / Observe

    /// Refresh triggered from Dashboard via PTR or from code.
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        loadItemsForWeek(
            ignorePlannablesCache: ignoreCache,
            ignoreCoursesCache: ignoreCache
        )
    }

    /// Local reload after internal changes.
    private func loadItemsForWeek(ignorePlannablesCache: Bool) {
        if ignorePlannablesCache {
            state = .loading
        }

        loadItemsForWeek(
            ignorePlannablesCache: ignorePlannablesCache,
            ignoreCoursesCache: false
        )
        .sink() // data/empty state will be set in `observeTodoGroups()`
        .store(in: &subscriptions)
    }

    /// The actual load method. Loads only weeks surrounding the current one.
    private func loadItemsForWeek(ignorePlannablesCache: Bool, ignoreCoursesCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.refresh(
            startDate: startOfWeek.addWeeks(-1),
            endDate: startOfWeek.addWeeks(2),
            ignorePlannablesCache: ignorePlannablesCache,
            ignoreCoursesCache: ignoreCoursesCache,
            filterOptions: .dashboardWidget
        )
        .receive(on: DispatchQueue.main)
        .catch { [weak self] _ in
            self?.state = .error
            return Just(())
        }
        .eraseToAnyPublisher()
    }

    private func observeTodoGroups() {
        interactor.todoGroups
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                guard let self else { return }

                allItemsPerDay = Dictionary(
                    groups.map { ($0.date.startOfDay(), $0.items) },
                    uniquingKeysWith: { $1 }
                )
                updateItemCounts()
                updateCurrentListItems()
            }
            .store(in: &subscriptions)
    }

    private func observePlannerItems() {
        NotificationCenter.default.publisher(for: .plannerItemDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadItemsForWeek(ignorePlannablesCache: true)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Day Selection / Week Navigation

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

        updateCurrentListItems()
    }

    private func weekDays(of startOfWeek: Date) -> [Date] {
        (0..<7).compactMap { startOfWeek.addDays($0) }
    }

    // MARK: - Actions

    func didTapRetryButton() {
        loadItemsForWeek(ignorePlannablesCache: true)
    }

    func didTapAddButton(from viewController: WeakViewController) {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateToDoViewController(selectedDate: selectedDay) { [router] _ in
            router.dismiss(weakVC)
        }
        weakVC.setValue(vc)
        router.show(vc, from: viewController, options: .modal(embedInNav: true))
    }

    // MARK: - Private

    private func showCompletedDidChange() {
        if showCompleted {
            listViewModel.invalidateMarkDoneTimers()
        }

        listViewModel.showCompleted = showCompleted
        updateItemCounts()
        updateCurrentListItems()
    }

    private func updateItemCounts() {
        itemCountPerDay = allItemsPerDay.mapValues { items in
            let filteredItems = showCompleted ? items : items.filter(\.isNotDone)
            return filteredItems.count
        }
    }

    private func updateCurrentListItems() {
        let allItems = allItemsPerDay[selectedDay] ?? []

        if showCompleted {
            listViewModel.items = allItems
        } else {
            let pendingRemovalIds = Set(listViewModel.markDoneTimers.keys)
            listViewModel.items = allItems.filter {
                $0.isNotDone
                || pendingRemovalIds.contains($0.plannableId)
            }
        }

        state = listViewModel.items.isEmpty ? .empty : .data
    }
}

private extension TodoFilterOptions {
    static let dashboardWidget = TodoFilterOptions(
        visibilityOptions: [.showCalendarEvents, .showCompleted, .showPersonalTodos],
        dateRangeStart: .lastWeek,
        dateRangeEnd: .nextWeek
    )
}
