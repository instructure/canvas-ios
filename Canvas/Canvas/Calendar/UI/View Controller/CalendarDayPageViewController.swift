//
//  CalendarDayPageViewController.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/10/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

import TooLegit
import CalendarKit

public protocol CalendarDayPageViewControllerDelegate {
    func dayPageViewController(calendarDayPageViewController: CalendarDayPageViewController, willTransitionToDay day: NSDate)
    func dayPageViewController(calendarDayPageViewController: CalendarDayPageViewController, didFinishAnimating finished: Bool, toDay day: NSDate, transitionCompleted completed: Bool)
}

public class CalendarDayPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    private var pageViewController : UIPageViewController!
    private var session : Session!
    
    internal var date: NSDate!
    private var delegate: CalendarDayPageViewControllerDelegate? = nil
    private let calendar = NSCalendar.currentCalendar()
    
    var dateFormatter = NSDateFormatter()
    var calendarEvents = [CalendarEvent]()
    var transitionDay: NSDate?
    
    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------
    public var colorForContextID: ColorForContextID!
    public var routeToURL: RouteToURL!
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public static func new(session: Session, date: NSDate, delegate: CalendarDayPageViewControllerDelegate? = nil, routeToURL: RouteToURL, colorForContextID: ColorForContextID) -> CalendarDayPageViewController {
        let controller = CalendarDayPageViewController(nibName: nil, bundle: nil)
        
        controller.session = session
        controller.date = date
        controller.delegate = delegate
        controller.routeToURL = routeToURL
        controller.colorForContextID = colorForContextID
        controller.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.calendarDayDetailBackgroundColor

        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let dayViewController = viewControllerForDay(date)
        let viewControllers = [dayViewController]
        pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        pageViewController.view.frame = view.bounds
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ---------------------------------------------
    // MARK: - Transition Methods
    // ---------------------------------------------
    func transitionToNextDay() {
        transitionToDayOffset(1)
    }
    
    func transitionToPreviousDay() {
        transitionToDayOffset(-1)
    }
    
    func transitionToNextWeek() {
        transitionToDayOffset(7)
    }
    
    func transitionToPrevWeek() {
        transitionToDayOffset(-7)
    }
    
    func transitionToToday() {
        transitionToDay(NSDate())
    }
    
    private func transitionToDayOffset(daysOffset: Int) {
        transitionToDay(dateMovedByDays(daysOffset))
    }
    
    func transitionToDay(newDay: NSDate) {
        let compareDates = newDay.compare(date)
        if compareDates == .OrderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        var transitionDirection: UIPageViewControllerNavigationDirection = .Forward
        if compareDates == .OrderedAscending {
            transitionDirection = .Reverse
        } else {
            transitionDirection = .Forward
        }
        
        date = newDay
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let strongSelf = self {
                let dayViewController = strongSelf.viewControllerForDay(strongSelf.date)
                strongSelf.pageViewController.setViewControllers([dayViewController], direction: transitionDirection, animated: true, completion: nil)
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - PageViewControllerDataSource
    // ---------------------------------------------
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let prevDay = dateMovedByDays(-1)
        let dayViewController = viewControllerForDay(prevDay)
        return dayViewController
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let nextDay = dateMovedByDays(1)
        let dayViewController = viewControllerForDay(nextDay)
        return dayViewController
    }
    
    // ---------------------------------------------
    // MARK: - PageViewControllerDelegate
    // ---------------------------------------------
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let nextVisibleDayViewController = pendingViewControllers.first as? CalendarDayListViewController {
            if let delegate = delegate, day = nextVisibleDayViewController.day {
                delegate.dayPageViewController(self, willTransitionToDay: day)
            }
        }
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !finished || !completed {
            return
        }
        
        if let visibleDayViewController = pageViewController.viewControllers?.first as? CalendarDayListViewController, day = visibleDayViewController.day {
            self.date = day
            if let delegate = delegate {
                delegate.dayPageViewController(self, didFinishAnimating: finished, toDay: day, transitionCompleted: completed)
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - View Controller Factory Method
    // ---------------------------------------------
    public func viewControllerForDay(day: NSDate) -> CalendarDayListViewController {
        return CalendarDayListViewController.new(session, date: day, routeToURL: routeToURL, colorForContextID: colorForContextID)
    }
    
    func dateMovedByDays(daysToMove: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = daysToMove
        return calendar.dateByAddingComponents(components, toDate:date, options: [])!
    }
    
}
