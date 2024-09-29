//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class PlannerViewModel: ObservableObject {

    @Published var selectedDay: CalendarDay
    @Published var isCollapsed: Bool = true

    @Published var dayPlannables: [Plannable] = []
    @Published var plannables: [Plannable] = []
    @Published var state: StoreState = .empty

    var calendar: Calendar { selectedDay.calendar }

    let showProfile = PassthroughSubject<WeakViewController, Never>()
    let showTodoForm = PassthroughSubject<WeakViewController, Never>()
    let showEventForm = PassthroughSubject<WeakViewController, Never>()

    lazy var calendarFilterInteractor: CalendarFilterInteractor = PlannerAssembly
        .makeFilterInteractor(observedUserId: studentID)

    lazy var calendarFilterInteractorForCreation: CalendarFilterInteractor = PlannerAssembly
        .makeFilterInteractor(observedUserId: studentID, forCreating: true)

    var plannablesInteractor: PlannablesInteractor
    var studentID: String?

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    init(
        studentID: String? = nil,
        date: Date,
        router: Router,
        interactor: PlannablesInteractor? = nil,
        periodInteractor: PlannablesInteractor? = nil
    ) {
        self.studentID = studentID
        self.router = router
        self.selectedDay = CalendarDay(calendar: Cal.currentCalendar, date: date)
        self.plannablesInteractor = interactor ?? PlannablesInteractorLive(studentID: studentID)

        self.calendarFilterInteractor
            .load(ignoreCache: false)
            .replaceError(with: ())
            .sink { [weak self] _ in
                self?.refreshPlannerList()
            }
            .store(in: &subscriptions)

        showProfile
            .sink { [weak self] in self?.showProfile(from: $0) }
            .store(in: &subscriptions)

        showTodoForm
            .sink { [weak self] in self?.showTodoForm(from: $0) }
            .store(in: &subscriptions)

        showEventForm
            .sink { [weak self] in self?.showEventForm(from: $0) }
            .store(in: &subscriptions)

        plannablesInteractor
            .state
            .assign(to: &$state)

        plannablesInteractor
            .events
            .map({ [weak self] newList in
                guard let selectedDay = self?.selectedDay else { return [] }
                return newList.filter { item in
                    guard let pdate = item.date else { return false }
                    return selectedDay.calendar.isDate(pdate, inSameDayAs: selectedDay.date)
                }
            })
            .assign(to: &$dayPlannables)

        plannablesInteractor
            .events
            .assign(to: &$plannables)

        $selectedDay
            .sink(receiveValue: { [weak self] day in
                self?.refreshPlannerList(day: day)
            })
            .store(in: &subscriptions)

        $isCollapsed
            .sink(receiveValue: { [weak self] collapsed in
                self?.refreshPlannerList(collapsed: collapsed)
            })
            .store(in: &subscriptions)
    }

    private func refreshPlannerList(day: CalendarDay? = nil, collapsed: Bool? = nil) {
        let targetDay = day ?? selectedDay
        let contextCodes = calendarFilterInteractor
            .contextsForAPIFiltering()
            .map(\.canvasContextID)

        let period: CalendarPeriod
        if collapsed ?? isCollapsed {
            period = targetDay.week
        } else {
            period = targetDay.month
        }

        let interval = period.dateInterval
        plannablesInteractor.setup(
            startDate: interval.start,
            endDate: interval.end,
            contextCodes: contextCodes
        )
    }

    private func showProfile(from screen: WeakViewController) {
        router.route(to: "/profile", from: screen, options: .modal())
    }

    private func showTodoForm(from screen: WeakViewController) {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateToDoViewController(
            selectedDate: selectedDay.date,
            calendarListProviderInteractor: calendarFilterInteractor,
            completion: { [weak self] _ in
                self?.router.dismiss(weakVC)
            }
        )
        weakVC.setValue(vc)

        router.show(
            vc,
            from: screen,
            options: .modal(isDismissable: false, embedInNav: true),
            analyticsRoute: "/calendar/new"
        )
    }

    private func showEventForm(from screen: WeakViewController) {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateEventViewController(
            selectedDate: selectedDay.date,
            calendarListProviderInteractor: calendarFilterInteractorForCreation,
            completion: { [weak self] in
                if $0 == .didUpdate {
                    self?.refreshPlannerList()
                }
                self?.router.dismiss(weakVC)
            }
        )
        weakVC.setValue(vc)

        router.show(
            vc,
            from: screen,
            options: .modal(isDismissable: false, embedInNav: true),
            analyticsRoute: "/calendar/new"
        )
    }
}
