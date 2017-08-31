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

import TooLegit
import SoLazy
import SoPretty
import SoPersistent
import EnrollmentKit
import ReactiveSwift
import CalendarKit
import Crashlytics

open class CalendarMonthViewController: UIViewController, CalendarViewDelegate, CalendarViewDataSource {

    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // External Closures
    open var dateSelected: DateSelected!
    open var routeToURL: RouteToURL!
    open var colorForContext: ColorForContextID!
    var didFinishRefreshing: ()->() = { }

    // UI Views
    fileprivate var calendar: Calendar = Calendar.current
    internal var calendarView: CalendarView!
    fileprivate let toastManager = ToastManager()

    // Data Variables
    fileprivate var session: Session!

    var favCoursesCollection: FetchedCollection<Course>!
    var eventsCollection: FetchedCollection<CalendarEvent>!

    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.refreshingBegan.observeValues { [weak self] in
                self?.toastManager.statusBarToastInfo(NSLocalizedString("Refreshing Calendar Events", comment: "Refreshing Calendar Events"), completion: nil)
            }
            refresher?.refreshingCompleted.observeValues { [weak self] err in
                guard let me = self else { return }
                ErrorReporter.reportError(err, from: self)
                me.calendarView?.reloadVisibleCells()
                me.toastManager.dismissNotification()
                me.didFinishRefreshing()
            }
        }
    }

    // Instance variables
    open var shouldHighlightDate: ShouldOperateOnDate = { date in
        return true
    }
    open var shouldSelectDate: ShouldOperateOnDate = { date in
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

    open static func new(_ session: Session, dateSelected: DateSelected? = nil, colorForContextID: ColorForContextID? = nil, routeToURL: RouteToURL? = nil) -> CalendarMonthViewController {
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
        
        CLSLogv("locale: %@", getVaList([Locale.current.identifier]))
        CLSLogv("calendar: %@", getVaList([Calendar.current.description]))

        initNavigationButtons()

        backTitleDateFormatter.dateFormat = "MMMM"

        calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(calendarView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[top][view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": calendarView, "top" : topLayoutGuide]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": calendarView]))

        favCoursesCollection = try! Course.favoritesCollection(session)
        favCoursesDisposable = favCoursesCollection.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.updateCalendarEvents()
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

    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.toastManager.dismissNotification()
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

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        calendarView = nil
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
    open func selectDate(_ date: Date) {
        self.calendarView?.selectDate(date)
    }

    // ---------------------------------------------
    // MARK: - CalendarViewDelegate
    // ---------------------------------------------
    open func calendarViewShouldHighlightDate(_ calendarView: CalendarView, date: Date) -> Bool {
        return shouldHighlightDate(date)
    }

    open func calendarViewShouldSelectDate(_ calendarView: CalendarView, date: Date) -> Bool {
        return shouldSelectDate(date)
    }

    open func calendarViewDidSelectDate(_ calendarView: CalendarView, date: Date) {
        dateSelected(date)
    }

    // ---------------------------------------------
    // MARK: - CalendarViewDataSource
    // ---------------------------------------------
    func calendarViewShouldMarkDate(_ calendarView: CalendarView, date: Date) -> Bool {
        return true
    }

    open func calendarViewColorsForMarkingDate(_ calendarView: CalendarView, date: Date) -> [UIColor] {
        let calEvents = calendarEventsForDate(date as Date)

        var colorsForDate = Set<UIColor>()
        for calEvent in calEvents {
            guard let context = ContextID(canvasContext: calEvent.contextCode), let color = session.enrollmentsDataSource[context]?.color else {
                colorsForDate.insert(UIColor.calendarTintColor)
                continue
            }

            if let c = color.value {
                colorsForDate.insert(c)
            }
        }

        return Array(colorsForDate)
    }

    // ---------------------------------------------
    // MARK: - UI Update Methods
    // ---------------------------------------------
    fileprivate func initNavigationButtons() {
        var navigationButtons = [UIBarButtonItem]()
        // Navigation Buttons
        if let refreshImage = UIImage(named: "icon_sync", in: CalendarMonthViewController.bundle, compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate) {
            let refreshButton = UIBarButtonItem(image: refreshImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CalendarMonthViewController.refreshButtonPressed(_:)))
            refreshButton.accessibilityLabel = NSLocalizedString("Refresh", comment: "Button to refresh the calendar events")
            navigationButtons.append(refreshButton)
        }

        if let todayView = IconTodayView.instantiateFromNib(Date(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarMonthViewController.todayButtonPressed(_:))) {
            let todayButton = UIBarButtonItem(customView: todayView)
            navigationButtons.append(todayButton)
        }

        navigationItem.rightBarButtonItems = navigationButtons
    }

    // ---------------------------------------------
    // MARK: - Data Functions
    // ---------------------------------------------
    open func reloadData(_ forced: Bool = false) {
        self.refresher?.refresh(forced)
    }

    fileprivate var eventsDisposable: Disposable?
    
    func updateCalendarEvents() {
        let startDate = Date() + -365.daysComponents
        let endDate = Date() + 365.daysComponents

        eventsCollection = try! CalendarEvent.collectionByDueDate(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher = try! CalendarEvent.refresher(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher?.refresh(false)
        eventsDisposable = eventsCollection.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [unowned self] updates in
                self.calendarView?.reloadVisibleCells()
            }.map(ScopedDisposable.init)
    }

    open func selectedContextCodes() -> [String] {
        var contextCodes: [String] = []
        for i in 0..<favCoursesCollection.numberOfItemsInSection(0) {
            let indexPath = IndexPath(row: i, section: 0)
            contextCodes.append(favCoursesCollection[indexPath].contextID.canvasContextID)
        }

        return contextCodes
    }

    internal func calendarEventsForDate(_ date: Date) -> [CalendarEvent] {
        let section = self.sectionForDate(date)
        if let section = section {
            return self.objectsInSection(section)
        }
        return [CalendarEvent]()
    }

    // We need to speed this up
    internal func sectionForDate(_ date: Date) -> Int? {
        let sections = 0..<eventsCollection.numberOfSections()
        for section in sections {
            if let dateString = eventsCollection.titleForSection(section), dateString == CalendarEvent.sectionTitleDateFormatter.string(from: date) {
                return section
            }
        }

        return nil
    }

    // This needs a kick in the pants too
    internal func objectsInSection(_ section: Int) -> [CalendarEvent] {
        var events = [CalendarEvent]()

        for i in 0..<eventsCollection.numberOfItemsInSection(section) {
            events.append(eventsCollection[IndexPath(row: i, section: section)])
        }
        
        return events
    }
    
}
