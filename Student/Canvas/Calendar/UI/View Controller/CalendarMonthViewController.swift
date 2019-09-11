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
import CoreData
import ReactiveSwift
import CanvasCore
import Core
import class CanvasCore.Course

open class CalendarMonthViewController: UIViewController, CalendarViewDelegate, CalendarViewDataSource, PageViewEventViewControllerLoggingProtocol {

    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // External Closures
    @objc open var dateSelected: DateSelected!
    @objc open var routeToURL: RouteToURL!
    @objc open var colorForContext: ColorForContextID!
    @objc var didFinishRefreshing: ()->() = { }

    // UI Views
    fileprivate var calendar: Calendar = Calendar.current
    @objc internal var calendarView: CalendarView!
    fileprivate var toastManager: ToastManager?

    // Data Variables
    fileprivate var session: Session!

    var allCoursesCollection: FetchedCollection<Course>?
    var favCoursesCollection: FetchedCollection<Course>?

    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.refreshingBegan.observeValues { [weak self] in
                self?.toastManager?.beginToastInfo(NSLocalizedString("Refreshing Calendar Events", comment: "Refreshing Calendar Events"))
            }
            refresher?.refreshingCompleted.observeValues { [weak self] err in
                guard let me = self else { return }
                ErrorReporter.reportError(err, from: self)
                me.calendarView?.reloadVisibleCells()
                me.toastManager?.endToast()
                me.didFinishRefreshing()
            }
        }
    }

    // Instance variables
    @objc open var shouldHighlightDate: ShouldOperateOnDate = { date in
        return true
    }
    @objc open var shouldSelectDate: ShouldOperateOnDate = { date in
        return true
    }

    fileprivate var backTitleDateFormatter = DateFormatter()

    // Default Action Closures
    fileprivate lazy var defaultDateSelected: DateSelected = {
        return { date in

            let dayViewController = CalendarDayDetailViewController.new(self.session, date: date, canvasContextIDs: self.selectedContextCodes(), routeToURL: self.routeToURL, colorForContextID: self.colorForContext)
            if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
                popGestureRecognizer.isEnabled = false
            }
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.backTitleDateFormatter.string(from: date), style: .plain, target: nil, action: nil)
            self.navigationController?.show(dayViewController, sender: self)
        }
    }()

    fileprivate lazy var defaultRouteToURL: RouteToURL = {
        return { url in
            print("DEFAULT: routeToURL: \(url)")
        }
    }()

    fileprivate lazy var defaultColorForContextID: ColorForContextID = {
        return { contextID in
            return UIColor.green
        }
    }()

    @objc public static func new(_ session: Session, dateSelected: DateSelected? = nil, colorForContextID: ColorForContextID? = nil, routeToURL: RouteToURL? = nil) -> CalendarMonthViewController {
        let controller = CalendarMonthViewController(nibName: nil, bundle: nil)
        controller.session = session

        controller.dateSelected = dateSelected ?? controller.defaultDateSelected
        controller.routeToURL = routeToURL ?? controller.defaultRouteToURL
        controller.colorForContext = colorForContextID ?? controller.defaultColorForContextID
        controller.calendarView = CalendarView(frame: CGRect.zero, calendar: Calendar.current, delegate: controller, dataSource: controller)

        return controller
    }

    fileprivate var favCoursesDisposable: Disposable?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.useGlobalNavStyle()
        initNavigationButtons()
        backTitleDateFormatter.dateFormat = "MMMM"

        calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(calendarView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["view": calendarView as Any]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["view": calendarView as Any]))

        favCoursesCollection = try? Course.favoritesCollection(session)
        favCoursesDisposable = favCoursesCollection?.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.updateCalendarEvents()
            }

        allCoursesCollection = try? Course.allCoursesCollection(session)
        
        if let nav = navigationController?.navigationBar {
            self.toastManager = ToastManager(navigationBar: nav)
        }

        updateCalendarEvents()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // This needs to be reset here because we set it to the previous month when drilled in
        self.title = NSLocalizedString("Calendar", comment: "Calendar page title")
        self.view.backgroundColor = .white

        // Scrolling needs to happen after viewDidAppear so we're hiding this until after that happens
        self.calendarView?.alpha = 0.0
        startTrackingTimeOnViewController()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.toastManager?.endToast()
        stopTrackingTimeOnViewController(eventName: "/calendar")
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Scroll to correct date
        if let _ = calendarView?.selectedDate {
            // We should be scrolled correctly already
        } else {
            self.calendarView?.scrollToToday(false)
        }

        if UIDevice.current.userInterfaceIdiom == .phone {
            self.calendarView?.deselectSelection()
            self.calendarView?.selectedDate = nil
        }

        // Animate the month view visible
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.calendarView?.alpha = 1.0
        })
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func todayButtonPressed(_ sender: Any) {
        calendarView?.scrollToToday(true)
    }

    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem?) {
        self.refresher?.refresh(true)
    }

    // ---------------------------------------------
    // MARK: - Selection
    // ---------------------------------------------
    @objc open func selectDate(_ date: Date) {
        self.calendarView?.selectDate(date)
    }

    // ---------------------------------------------
    // MARK: - CalendarViewDelegate
    // ---------------------------------------------
    @objc open func calendarViewShouldHighlightDate(_ calendarView: CalendarView, date: Date) -> Bool {
        return shouldHighlightDate(date)
    }

    @objc open func calendarViewShouldSelectDate(_ calendarView: CalendarView, date: Date) -> Bool {
        return shouldSelectDate(date)
    }

    @objc open func calendarViewDidSelectDate(_ calendarView: CalendarView, date: Date) {
        Analytics.shared.logEvent("calendar_day_selected")
        dateSelected(date)
    }

    // ---------------------------------------------
    // MARK: - CalendarViewDataSource
    // ---------------------------------------------
    @objc func calendarViewShouldMarkDate(_ calendarView: CalendarView, date: Date) -> Bool {
        return true
    }

    @objc open func calendarViewNumberOfEventsForDate(_ calendarView: CalendarView, date: Date) -> Int {
        let min = date.dateAtMidnight
        let max = min.addingTimeInterval(24 * 60 * 60)
        do {
            let context = try session.calendarEventsManagedObjectContext()
            let predicate = CalendarEvent.predicate(min, endDate: max, contextCodes: selectedContextCodes())
            let fetch: NSFetchRequest<CalendarEvent> = context.fetch(predicate)
            let count = try context.count(for: fetch)
            return count
        } catch {
            return 0
        }
    }

    // ---------------------------------------------
    // MARK: - UI Update Methods
    // ---------------------------------------------
    fileprivate func initNavigationButtons() {
        var navigationButtons = [UIBarButtonItem]()
        // Navigation Buttons
        let refreshImage = UIImage.icon(.refresh).withRenderingMode(.alwaysTemplate)
        let refreshButton = UIBarButtonItem(image: refreshImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(CalendarMonthViewController.refreshButtonPressed(_:)))
        refreshButton.accessibilityLabel = NSLocalizedString("Refresh", comment: "Button to refresh the calendar events")
        navigationButtons.append(refreshButton)

        if let todayView = IconTodayView.instantiateFromNib(Date(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarMonthViewController.todayButtonPressed(_:))) {
            let todayButton = UIBarButtonItem(customView: todayView)
            navigationButtons.append(todayButton)
        }

        navigationItem.rightBarButtonItems = navigationButtons
    }

    // ---------------------------------------------
    // MARK: - Data Functions
    // ---------------------------------------------
    @objc open func reloadData(_ forced: Bool = false) {
        self.refresher?.refresh(forced)
    }

    fileprivate var eventsDisposable: Disposable?
    
    @objc func updateCalendarEvents() {
        let startDate = Date() + -365.daysComponents
        let endDate = Date() + 365.daysComponents

        refresher = try? CalendarEvent.refresher(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher?.refresh(false)
    }

    @objc open func selectedContextCodes() -> [String] {
        let anyFavorites = favCoursesCollection?.isEmpty == false
        guard let collection = (anyFavorites ? favCoursesCollection : allCoursesCollection) else {
            return []
        }
        var contextCodes: [String] = []
        for i in 0..<collection.numberOfItemsInSection(0) {
            let indexPath = IndexPath(row: i, section: 0)
            contextCodes.append(collection[indexPath].contextID.canvasContextID)
        }

        return contextCodes
    }
    
}
