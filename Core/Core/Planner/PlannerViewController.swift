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
    lazy var calendar = CalendarViewController.create(studentID: studentID, delegate: self)
    let listPageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    var list: PlannerListViewController! {
        listPageController.viewControllers?.first as? PlannerListViewController
    }
    var listContentOffsetY: CGFloat = 0
    var studentID = ""

    public static func create(studentID: String) -> PlannerViewController {
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
                studentID: studentID,
                start: Clock.now.startOfDay(),
                end: Clock.now.endOfDay(),
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
        list.tableView.contentInset.top = calendar.minHeight
    }
}

extension PlannerViewController: CalendarViewControllerDelegate {
    func calendarDidSelectDate(_ date: Date) {
        calendar.updateSelectedDate(date)
        let newList = PlannerListViewController.create(
            studentID: studentID,
            start: date.startOfDay(),
            end: date.endOfDay(),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.contentInset = list.tableView.contentInset
        listPageController.setViewControllers([ newList ], direction: date < list.start ? .reverse : .forward, animated: true)
    }

    func calendarDidResize(height: CGFloat, animated: Bool) {
        list.tableView.contentInset.top = height
        view.layoutIfNeeded()
        clearPageCache()
    }
}

extension PlannerViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        listContentOffsetY = scrollView.contentInset.top + scrollView.contentOffset.y
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentInset.top > calendar.minHeight else { return }
        let topSpace = -scrollView.contentOffset.y - listContentOffsetY
        let height = max(calendar.minHeight, min(calendar.maxHeight, topSpace))
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
            studentID: studentID,
            start: list.start.addDays(delta),
            end: list.end.addDays(delta),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.contentInset = list.tableView.contentInset
        return newList
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        calendar.updateSelectedDate(list.start)
    }
}
