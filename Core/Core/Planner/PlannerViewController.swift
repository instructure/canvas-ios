//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UIKit

public class PlannerViewController: UIViewController {
    lazy var profileButton = UIBarButtonItem(image: .icon(.hamburger, .solid), style: .plain, target: self, action: #selector(openProfile))
    lazy var addNoteButton = UIBarButtonItem(image: .icon(.add, .solid), style: .plain, target: self, action: #selector(addNote))
    lazy var todayButton = UIBarButtonItem(image: .icon(.calendarTodayLine), style: .plain, target: self, action: #selector(selectToday))

    lazy var calendar = CalendarViewController.create(delegate: self, selectedDate: selectedDate)
    let listPageController = PagesViewController()
    var list: PlannerListViewController! {
        listPageController.currentPage as? PlannerListViewController
    }

    let env = AppEnvironment.shared
    var listContentOffsetY: CGFloat = 0
    public var selectedDate: Date = Clock.now
    var studentID: String?

    lazy var planners: Store<LocalUseCase<Planner>> = env.subscribe(scope: .where(#keyPath(Planner.studentID), equals: studentID)) { [weak self] in
        self?.plannerListWillRefresh()
    }
    var planner: Planner? { planners.first }
    lazy var syncContext = env.database.newBackgroundContext()

    public static func create(studentID: String? = nil, selectedDate: Date = Clock.now) -> PlannerViewController {
        let controller = PlannerViewController()
        controller.studentID = studentID
        controller.selectedDate = selectedDate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = Brand.shared.headerImageView()
        navigationItem.leftBarButtonItem = profileButton
        navigationItem.rightBarButtonItems = [ addNoteButton, todayButton ]
        profileButton.accessibilityIdentifier = "PlannerCalendar.profileButton"
        profileButton.accessibilityLabel = NSLocalizedString("Profile Menu", bundle: .core, comment: "")
        addNoteButton.accessibilityIdentifier = "PlannerCalendar.addNoteButton"
        addNoteButton.accessibilityLabel = NSLocalizedString("Add Planner Note", bundle: .core, comment: "")
        todayButton.accessibilityIdentifier = "PlannerCalendar.todayButton"
        todayButton.accessibilityLabel = NSLocalizedString("Go to today", bundle: .core, comment: "")

        embed(listPageController, in: view)
        listPageController.dataSource = self
        listPageController.delegate = self
        listPageController.setCurrentPage(PlannerListViewController.create(
            start: selectedDate.startOfDay(),
            end: selectedDate.startOfDay().addDays(1),
            delegate: self
        ))

        embed(calendar, in: view) { child, container in
            child.view.pinToLeftAndRightOfSuperview()
            child.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        }

        let divider = DividerView()
        divider.tintColor = .named(.borderMedium)
        divider.isOpaque = false
        view.addSubview(divider)
        divider.pinToLeftAndRightOfSuperview()
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.topAnchor.constraint(equalTo: calendar.view.bottomAnchor).isActive = true

        calendar.view.layoutIfNeeded()
        list.tableView.scrollIndicatorInsets.top = calendar.minHeight
        list.tableView.contentInset.top = calendar.minHeight

        planners.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useGlobalNavStyle()
    }

    @objc func openProfile() {
        env.router.route(to: .profile, from: self, options: .modal())
    }

    @objc func addNote() {
        env.router.show(CreateTodoViewController.create(), from: self, options: .modal(embedInNav: true))
    }

    @objc func selectToday() {
        let date = Clock.now.startOfDay()
        calendar.showDate(date)
        updateList(date)
    }

    func getPlannables(from: Date, to: Date) -> GetPlannables {
        var contextCodes: [String]?
        if let planner = planner, !planner.allSelected {
            contextCodes = planner.selectedCourses.map {
                Context(.course, id: $0.id).canvasContextID
            }
            if let studentID = studentID ?? env.currentSession?.userID {
                contextCodes?.append(Context(.user, id: studentID).canvasContextID)
            }
        }
        return GetPlannables(userID: studentID, startDate: from, endDate: to, contextCodes: contextCodes, syncContext: syncContext)
    }

    func updateList(_ date: Date) {
        guard !calendar.calendar.isDate(date, inSameDayAs: list.start) else { return }
        let newList = PlannerListViewController.create(
            start: date.startOfDay(),
            end: date.startOfDay().addDays(1),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.contentInset = list.tableView.contentInset
        listPageController.setCurrentPage(newList, direction: date < list.start ? .reverse : .forward)
    }
}

extension PlannerViewController: CalendarViewControllerDelegate {
    func calendarDidSelectDate(_ date: Date) {
        selectedDate = date
        calendar.showDate(date)
        updateList(date)
    }

    func calendarDidTransitionToDate(_ date: Date) {
        selectedDate = date
        calendar.updateSelectedDate(date)
        updateList(date)
    }

    func calendarDidResize(height: CGFloat, animated: Bool) {
        list.tableView.scrollIndicatorInsets.top = height
        list.tableView.contentInset.top = height
        view.layoutIfNeeded()
    }

    func calendarWillFilter() {
        let filter = PlannerFilterViewController.create(studentID: studentID)
        env.router.show(filter, from: self, options: .modal(embedInNav: true, addDoneButton: true))
    }

    func numberOfCalendars() -> Int? {
        if planner?.allSelected == true {
            return nil
        }
        return planner?.selectedCourses.count
    }
}

extension PlannerViewController: PlannerListDelegate {
    func plannerListWillRefresh() {
        calendar.refresh(force: true)
        list.refresh(force: true)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        listContentOffsetY = scrollView.contentOffset.y
        scrollView.contentInset.bottom = max(0, scrollView.frame.height - scrollView.contentSize.height - calendar.minHeight)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging, scrollView.contentInset.top > calendar.minHeight else { return }
        let topSpace = scrollView.contentInset.top + listContentOffsetY - scrollView.contentOffset.y
        let height = max(calendar.minHeight, min(calendar.maxHeight, topSpace))
        scrollView.scrollIndicatorInsets.top = height
        calendar.setHeight(height)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.contentInset.bottom = 0
        calendar.setExpanded(calendar.isExpanded)
    }
}

extension PlannerViewController: PagesViewControllerDataSource, PagesViewControllerDelegate {
    public func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController? {
        return listPageDelta(-1, from: (page as? PlannerListViewController)!)
    }

    public func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController? {
        return listPageDelta(1, from: (page as? PlannerListViewController)!)
    }

    func listPageDelta(_ delta: Int, from list: PlannerListViewController) -> PlannerListViewController {
        let newList = PlannerListViewController.create(
            start: list.start.addDays(delta),
            end: list.end.addDays(delta),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.scrollIndicatorInsets = list.tableView.scrollIndicatorInsets
        newList.tableView.contentInset = list.tableView.contentInset
        newList.title = DateFormatter.localizedString(from: newList.start, dateStyle: .long, timeStyle: .none)
        return newList
    }

    public func pagesViewController(_ pages: PagesViewController, didTransitionTo page: UIViewController) {
        selectedDate = list.start
        calendar.showDate(list.start)
    }
}
