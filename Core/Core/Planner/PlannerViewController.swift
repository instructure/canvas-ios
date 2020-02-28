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
    lazy var calendar = CalendarViewController.create(delegate: self)
    let listPageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    var list: PlannerListViewController! {
        listPageController.viewControllers?.first as? PlannerListViewController
    }
    var listContentOffsetY: CGFloat = 0
    var studentID: String?
    let env = AppEnvironment.shared
    lazy var planners: Store<LocalUseCase<Planner>> = env.subscribe(scope: .where(#keyPath(Planner.studentID), equals: studentID)) { [weak self] in
        self?.plannerListWillRefresh()
    }
    var planner: Planner? { planners.first }

    public static func create(studentID: String? = nil) -> PlannerViewController {
        let controller = PlannerViewController()
        controller.studentID = studentID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        embed(listPageController, in: view)
        listPageController.dataSource = self
        listPageController.delegate = self
        listPageController.setViewControllers([
            PlannerListViewController.create(
                start: Clock.now.startOfDay(),
                end: Clock.now.startOfDay().addDays(1),
                delegate: self
            ),
        ], direction: .forward, animated: false)
        for view in listPageController.view.subviews {
            if let scroll = view as? UIScrollView {
                scroll.canCancelContentTouches = true
            }
        }

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

    func getPlannables(from: Date, to: Date) -> GetPlannables {
        let contextCodes = planner?.selectedCourses.map { $0.canvasContextID } ?? []
        return GetPlannables(userID: studentID, startDate: from, endDate: to, contextCodes: contextCodes)
    }
}

extension PlannerViewController: CalendarViewControllerDelegate {
    func calendarDidSelectDate(_ date: Date) {
        calendar.updateSelectedDate(date)
        let newList = PlannerListViewController.create(
            start: date.startOfDay(),
            end: date.startOfDay().addDays(1),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.contentInset = list.tableView.contentInset
        listPageController.setViewControllers([ newList ], direction: date < list.start ? .reverse : .forward, animated: true)
    }

    func calendarDidResize(height: CGFloat, animated: Bool) {
        list.tableView.scrollIndicatorInsets.top = height
        list.tableView.contentInset.top = height
        view.layoutIfNeeded()
        clearPageCache()
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
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging, scrollView.contentInset.top > calendar.minHeight else { return }
        let topSpace = scrollView.contentInset.top + listContentOffsetY - scrollView.contentOffset.y
        listContentOffsetY = scrollView.contentOffset.y
        let height = max(calendar.minHeight, min(calendar.maxHeight, topSpace))
        scrollView.scrollIndicatorInsets.top = height
        scrollView.contentInset.top = height
        calendar.setHeight(height)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        calendar.setExpanded(calendar.isExpanded)
    }
}

extension PlannerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func clearPageCache() {
        listPageController.dataSource = nil
        listPageController.dataSource = self
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return listPageDelta(-1, from: (viewController as? PlannerListViewController)!)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return listPageDelta(1, from: (viewController as? PlannerListViewController)!)
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
        return newList
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        calendar.updateSelectedDate(list.start)
    }
}
