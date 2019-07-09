//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore

public protocol CalendarDayPageViewControllerDelegate {
    func dayPageViewController(_ calendarDayPageViewController: CalendarDayPageViewController, willTransitionToDay day: Date)
    func dayPageViewController(_ calendarDayPageViewController: CalendarDayPageViewController, didFinishAnimating finished: Bool, toDay day: Date, transitionCompleted completed: Bool)
}

open class CalendarDayPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    fileprivate var pageViewController : UIPageViewController!
    fileprivate var session : Session!
    
    @objc internal var date: Date!
    fileprivate var delegate: CalendarDayPageViewControllerDelegate? = nil
    fileprivate let calendar = Calendar.current
    
    @objc var dateFormatter = DateFormatter()
    @objc var calendarEvents = [CalendarEvent]()
    @objc var transitionDay: Date?
    
    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------
    @objc open var colorForContextID: ColorForContextID!
    @objc open var routeToURL: RouteToURL!
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public static func new(_ session: Session, date: Date, delegate: CalendarDayPageViewControllerDelegate? = nil, routeToURL: @escaping RouteToURL, colorForContextID: @escaping ColorForContextID) -> CalendarDayPageViewController {
        let controller = CalendarDayPageViewController(nibName: nil, bundle: nil)
        
        controller.session = session
        controller.date = date
        controller.delegate = delegate
        controller.routeToURL = routeToURL
        controller.colorForContextID = colorForContextID
        controller.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return controller
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.calendarDayDetailBackgroundColor

        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let dayViewController = viewControllerForDay(date)
        let viewControllers = [dayViewController]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        pageViewController.view.frame = view.bounds
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ---------------------------------------------
    // MARK: - Transition Methods
    // ---------------------------------------------
    @objc func transitionToNextDay() {
        transitionToDayOffset(1)
    }
    
    @objc func transitionToPreviousDay() {
        transitionToDayOffset(-1)
    }
    
    @objc func transitionToNextWeek() {
        transitionToDayOffset(7)
    }
    
    @objc func transitionToPrevWeek() {
        transitionToDayOffset(-7)
    }
    
    @objc func transitionToToday() {
        transitionToDay(Date())
    }
    
    fileprivate func transitionToDayOffset(_ daysOffset: Int) {
        transitionToDay(dateMovedByDays(daysOffset))
    }
    
    @objc func transitionToDay(_ newDay: Date) {
        let compareDates = newDay.compare(date)
        if compareDates == .orderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        var transitionDirection: UIPageViewController.NavigationDirection = .forward
        if compareDates == .orderedAscending {
            transitionDirection = .reverse
        } else {
            transitionDirection = .forward
        }
        
        date = newDay
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                let dayViewController = strongSelf.viewControllerForDay(strongSelf.date)
                strongSelf.pageViewController.setViewControllers([dayViewController], direction: transitionDirection, animated: true, completion: nil)
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - PageViewControllerDataSource
    // ---------------------------------------------
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let prevDay = dateMovedByDays(-1)
        let dayViewController = viewControllerForDay(prevDay)
        return dayViewController
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextDay = dateMovedByDays(1)
        let dayViewController = viewControllerForDay(nextDay)
        return dayViewController
    }
    
    // ---------------------------------------------
    // MARK: - PageViewControllerDelegate
    // ---------------------------------------------
    open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let nextVisibleDayViewController = pendingViewControllers.first as? CalendarDayListViewController {
            if let delegate = delegate, let day = nextVisibleDayViewController.day {
                delegate.dayPageViewController(self, willTransitionToDay: day as Date)
            }
        }
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !finished || !completed {
            return
        }
        
        if let visibleDayViewController = pageViewController.viewControllers?.first as? CalendarDayListViewController, let day = visibleDayViewController.day {
            self.date = day as Date
            if let delegate = delegate {
                delegate.dayPageViewController(self, didFinishAnimating: finished, toDay: day as Date, transitionCompleted: completed)
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - View Controller Factory Method
    // ---------------------------------------------
    @objc open func viewControllerForDay(_ day: Date) -> CalendarDayListViewController {
        return CalendarDayListViewController.new(session, date: day, routeToURL: routeToURL, colorForContextID: colorForContextID)
    }
    
    @objc func dateMovedByDays(_ daysToMove: Int) -> Date {
        var components = DateComponents()
        components.day = daysToMove
        return (calendar as NSCalendar).date(byAdding: components, to:date, options: [])!
    }
    
}
