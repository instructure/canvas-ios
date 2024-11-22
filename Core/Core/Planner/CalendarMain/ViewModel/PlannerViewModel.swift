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
import SwiftUI

public class PlannerViewModel: ObservableObject {

    @Published var selectedDay: CalendarDay
    @Published var dayPlannables: [Plannable] = []
    @Published var plannables: [Plannable] = []
    @Published var state: StoreState = .empty

    var calendar: Calendar { selectedDay.calendar }

    let showProfile = PassthroughSubject<WeakViewController, Never>()
    let showTodoForm = PassthroughSubject<WeakViewController, Never>()
    let showEventForm = PassthroughSubject<WeakViewController, Never>()
    let showCalendars = PassthroughSubject<WeakViewController, Never>()
    let showPlannableDetails = PassthroughSubject<(event: Plannable, screen: WeakViewController), Never>()

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

        showCalendars
            .sink { [weak self] in self?.showCalendarsView(from: $0) }
            .store(in: &subscriptions)

        showPlannableDetails
            .sink { [weak self] (event, screen) in
                self?.showDetails(for: event, from: screen)
            }
            .store(in: &subscriptions)

        plannablesInteractor
            .state
            .assign(to: &$state)

        plannablesInteractor
            .events
            .assign(to: &$plannables)

        plannablesInteractor
            .events
            .sink(receiveValue: { [weak self] newList in
                self?.updateDayPlannables(from: newList)
            })
            .store(in: &subscriptions)

        $selectedDay
            .sink(receiveValue: { [weak self] day in
                self?.refreshPlannerList(day: day)
                self?.updateDayPlannables(day: day)
            })
            .store(in: &subscriptions)
    }

    private func updateDayPlannables(day: CalendarDay? = nil, from list: [Plannable]? = nil) {
        let targetDay = day ?? selectedDay
        let calendar = targetDay.calendar
        let newList = list ?? plannables
        dayPlannables = newList.filter { item in
            guard let pdate = item.date else { return false }
            return calendar.isDate(pdate, inSameDayAs: targetDay.date)
        }
    }

    private func refreshPlannerList(day: CalendarDay? = nil) {
        let targetDay = day ?? selectedDay
        let contextCodes = calendarFilterInteractor
            .contextsForAPIFiltering()
            .map(\.canvasContextID)

        let startDate = targetDay.sameDayPrevMonth().month.startDate
        let endDate = targetDay.sameDayNextMonth().month.endDate
        plannablesInteractor.setup(
            startDate: startDate,
            endDate: endDate,
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

    private func showCalendarsView(from screen: WeakViewController) {
        let filter = PlannerAssembly.makeFilterViewController(observedUserId: studentID) { [weak self] in
            self?.refreshPlannerList()
        }
        router.show(
            filter,
            from: screen,
            options: .modal(.formSheet, isDismissable: false, embedInNav: true),
            analyticsRoute: "/calendar/filter"
        )
    }

    private func showDetails(for plannable: Plannable, from screen: WeakViewController) {
        switch plannable.plannableType {
        case .planner_note:
            let vc = PlannerAssembly.makeToDoDetailsViewController(plannable: plannable)
            router.show(vc, from: screen, options: .detail)
        case .calendar_event:
            let vc = PlannerAssembly.makeEventDetailsViewController(eventId: plannable.id) { [weak self] output in
                switch output {
                case .didUpdate, .didDelete:
                    self?.refreshPlannerList()
                case .didCancel:
                    break
                }
            }
            router.show(vc, from: screen, options: .detail)
        default:
            if let url = plannable.htmlURL {
                let to = url.appendingQueryItems(URLQueryItem(name: "origin", value: "calendar"))
                router.route(to: to, from: screen, options: .detail)
            }
        }
    }
}

// MARK: - PlannerModel Environment

public struct PlannerViewModelEnvironmentWrapper {
    let model: PlannerViewModel?
}

extension PlannerViewModel: EnvironmentKey {
    public static var defaultValue: PlannerViewModelEnvironmentWrapper {
        PlannerViewModelEnvironmentWrapper(model: nil)
    }
}

extension EnvironmentValues {
    public var plannerViewModel: PlannerViewModelEnvironmentWrapper {
        get { self[PlannerViewModel.self] }
        set { self[PlannerViewModel.self] = newValue }
    }
}

extension PlannerViewModel {
    func wrapped() -> PlannerViewModelEnvironmentWrapper {
        return PlannerViewModelEnvironmentWrapper(model: self)
    }
}
