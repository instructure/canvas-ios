//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit
import CanvasCore

public protocol CalendarWeekPageViewControllerDelegate: class {
    func weekPageViewController(_ calendarWeekPageViewController: CalendarWeekPageViewController, daySelected day: Date)
    func weekPageViewController(_ calendarWeekPageViewController: CalendarWeekPageViewController, willTransitionToDay day: Date)
    func weekPageViewController(_ calendarWeekPageViewController: CalendarWeekPageViewController, didFinishAnimating finished: Bool, toDay day: Date, transitionCompleted completed: Bool)
}

open class CalendarWeekPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CalendarWeekDayViewControllerDelegate {

    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    open var calendar: Calendar
    open var day: Date
    open weak var delegate: CalendarWeekPageViewControllerDelegate?
    
    // Page View Controller
    var pageViewController : UIPageViewController!

    // Data Structure
    var calendarEvents = [CalendarEvent]()

    // Temp Variables
    var transitionDay: Date?
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public init(calendar: Calendar, day: Date, delegate: CalendarWeekPageViewControllerDelegate?) {
        self.calendar = calendar
        self.day = day
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let dayViewController = viewControllerForDay(day)
        let viewControllers = [dayViewController]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ---------------------------------------------
    // MARK: - Transition Methods
    // ---------------------------------------------
    func transitionToNextWeek() {
        transitionToDayOffset(numberOfDaysInWeek())
    }
    
    func transitionToPrevWeek() {
        transitionToDayOffset(-numberOfDaysInWeek())
    }
    
    func transitionToDayOffset(_ daysOffset: Int) {
        transitionToDay(dateMovedByDays(daysOffset))
    }
    
    fileprivate func transitionToDay(_ newDay: Date) {
        let compareDates = newDay.compare(day)
        if compareDates == .orderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        var transitionDirection: UIPageViewControllerNavigationDirection = .forward
        if compareDates == .orderedAscending {
            transitionDirection = .reverse
        } else {
            transitionDirection = .forward
        }
        
        day = newDay
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                let dayViewController = strongSelf.viewControllerForDay(strongSelf.day)
                strongSelf.pageViewController.setViewControllers([dayViewController], direction: transitionDirection, animated: true, completion:nil)
            }
        }
        
    }
    
    // ---------------------------------------------
    // MARK: - UIPageViewControllerDataSource
    // ---------------------------------------------
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let prevDay = dateMovedByDays(-numberOfDaysInWeek())
        let dayViewController = viewControllerForDay(prevDay)
        return dayViewController
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextDay = dateMovedByDays(numberOfDaysInWeek())
        let dayViewController = viewControllerForDay(nextDay)
        return dayViewController
    }
    
    // ---------------------------------------------
    // MARK: - UIPageViewControllerDelegate
    // ---------------------------------------------
    open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let nextVisibleDayViewController = pendingViewControllers.first as? CalendarWeekDayViewController {
            let compareDates = nextVisibleDayViewController.day.compare(day)
            if compareDates == .orderedSame {
                // Dates are equal, no change is needed
                return
            }
            
            if compareDates == .orderedAscending {
                transitionDay = dateMovedByDays(-numberOfDaysInWeek())
            } else {
                transitionDay = dateMovedByDays(numberOfDaysInWeek())
            }
            
            nextVisibleDayViewController.setDay(transitionDay!, animated: false)

            if let delegate = delegate {
                delegate.weekPageViewController(self, willTransitionToDay: transitionDay!)
            }
        }
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            day = transitionDay!
        }
        
        if let delegate = delegate {
            delegate.weekPageViewController(self, didFinishAnimating: finished, toDay: day, transitionCompleted: completed)
        }
        
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func viewControllerForDay(_ day: Date) -> CalendarWeekDayViewController {
        return CalendarWeekDayViewController(calendar: calendar, day: day, delegate: self)
    }
    
    func dateMovedByDays(_ daysToMove: Int) -> Date {
        var components = DateComponents()
        components.day = daysToMove
        return (calendar as NSCalendar).date(byAdding: components, to:day, options: [])!
    }
    
    func numberOfDaysInWeek() -> Int {
        return (calendar as NSCalendar).maximumRange(of: .weekday).length
    }
    
    func setDay(_ day: Date, animated: Bool) {
        if let currentWeekViewController = pageViewController.viewControllers?.first as? CalendarWeekDayViewController {
            if !currentWeekViewController.dateIsInWeek(day) {
                transitionToDay(day)
                return
            }
            
            self.day = day
            currentWeekViewController.setDay(self.day, animated: animated)
        }
    }
    
    func weekdayViewController(_ weekdayViewController: CalendarWeekDayViewController, selectedDate day: Date) {
        setDay(day, animated: true)
        if let delegate = delegate {
            delegate.weekPageViewController(self, daySelected: day)
        }
    }
    
}
