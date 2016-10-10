
//  CalendarViewController.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/10/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

import TooLegit
import SoLazy
import SoPretty
import SoPersistent
import EnrollmentKit
import ReactiveCocoa
import CalendarKit
import Crashlytics

public class CalendarMonthViewController: UIViewController, CalendarViewDelegate, CalendarViewDataSource {

    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // External Closures
    public var dateSelected: DateSelected!
    public var routeToURL: RouteToURL!
    public var colorForContext: ColorForContextID!
    var didFinishRefreshing: ()->() = { }

    // UI Views
    private var calendar: NSCalendar = NSCalendar.currentCalendar()
    internal var calendarView: CalendarView!
    private let toastManager = ToastManager()

    // Data Variables
    private var session: Session!

    var favCoursesCollection: FetchedCollection<Course>!
    var eventsCollection: FetchedCollection<CalendarEvent>!

    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.refreshingBegan.observeNext { [weak self] in
                self?.toastManager.statusBarToastInfo(NSLocalizedString("Refreshing Calendar Events", comment: "Refreshing Calendar Events"), completion: nil)
            }
            refresher?.refreshingCompleted.observeNext { [weak self] err in
                guard let me = self else { return }
                err?.report(alertUserFrom: me)
                me.calendarView?.reloadVisibleCells()
                me.toastManager.dismissNotification()
                me.didFinishRefreshing()
            }
        }
    }

    // Instance variables
    public var shouldHighlightDate: ShouldOperateOnDate = { date in
        return true
    }
    public var shouldSelectDate: ShouldOperateOnDate = { date in
        return true
    }

    private var backTitleDateFormatter = NSDateFormatter()

    // Default Action Closures
    private lazy var defaultDateSelected: DateSelected = {
        return { date in

            let dayViewController = CalendarDayDetailViewController.new(self.session, date: date, canvasContextIDs: self.selectedContextCodes(), routeToURL: self.routeToURL, colorForContextID: self.colorForContext)
            if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
                popGestureRecognizer.enabled = false
            }
            self.title = self.backTitleDateFormatter.stringFromDate(date)
            self.navigationController?.showViewController(dayViewController, sender: self)
        }
    }()

    private lazy var defaultRouteToURL: RouteToURL = {
        return { url in
            print("DEFAULT: routeToURL: \(url)")
        }
    }()

    private lazy var defaultColorForContextID: ColorForContextID = {
        return { contextID in
            return UIColor.greenColor()
        }
    }()

    public static func new(session: Session, dateSelected: DateSelected? = nil, colorForContextID: ColorForContextID? = nil, routeToURL: RouteToURL? = nil) -> CalendarMonthViewController {
        let controller = CalendarMonthViewController(nibName: nil, bundle: nil)
        controller.session = session

        controller.dateSelected = dateSelected ?? controller.defaultDateSelected
        controller.routeToURL = routeToURL ?? controller.defaultRouteToURL
        controller.colorForContext = colorForContextID ?? controller.defaultColorForContextID
        controller.calendarView = CalendarView(frame: CGRectZero, calendar: NSCalendar.currentCalendar(), delegate: controller, dataSource: controller)

        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        CLSLogv("locale: %@", getVaList([NSLocale.currentLocale().localeIdentifier]))
        CLSLogv("calendar: %@", getVaList([NSCalendar.currentCalendar().calendarIdentifier]))

        initNavigationButtons()

        backTitleDateFormatter.dateFormat = "MMMM"

        calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(calendarView)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[top][view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": calendarView, "top" : topLayoutGuide]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": calendarView]))

        favCoursesCollection = try! Course.favoritesCollection(session)
        favCoursesCollection.collectionUpdated = { [unowned self] _ in
            self.updateCalendarEvents()
        }

        updateCalendarEvents()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // This needs to be reset here because we set it to the previous month when drilled in
        self.title = "Calendar"
        self.view.backgroundColor = UIColor.whiteColor()

        // Scrolling needs to happen after viewDidAppear so we're hiding this until after that happens
        self.calendarView?.alpha = 0.0

    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.toastManager.dismissNotification()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Scroll to correct date
        if let _ = calendarView?.selectedDate {
            // We should be scrolled correctly already
        } else {
            self.calendarView?.scrollToToday(false)
        }

        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.calendarView?.deselectSelection()
            self.calendarView?.selectedDate = nil
        }

        // Animate the month view visible
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.calendarView?.alpha = 1.0
        })
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        calendarView = nil
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func todayButtonPressed(sender: AnyObject) {
        calendarView?.scrollToToday(true)
    }

    @IBAction func refreshButtonPressed(sender: UIBarButtonItem?) {
        self.refresher?.refresh(true)
    }

    // ---------------------------------------------
    // MARK: - Selection
    // ---------------------------------------------
    public func selectDate(date: NSDate) {
        self.calendarView?.selectDate(date)
    }

    // ---------------------------------------------
    // MARK: - CalendarViewDelegate
    // ---------------------------------------------
    public func calendarViewShouldHighlightDate(calendarView: CalendarView, date: NSDate) -> Bool {
        return shouldHighlightDate(date: date)
    }

    public func calendarViewShouldSelectDate(calendarView: CalendarView, date: NSDate) -> Bool {
        return shouldSelectDate(date: date)
    }

    public func calendarViewDidSelectDate(calendarView: CalendarView, date: NSDate) {
        dateSelected(date: date)
    }

    // ---------------------------------------------
    // MARK: - CalendarViewDataSource
    // ---------------------------------------------
    func calendarViewShouldMarkDate(calendarView: CalendarView, date: NSDate) -> Bool {
        return true
    }

    public func calendarViewColorsForMarkingDate(calendarView: CalendarView, date: NSDate) -> [UIColor] {
        let calEvents = calendarEventsForDate(date)

        var colorsForDate = Set<UIColor>()
        for calEvent in calEvents {
            guard let context = ContextID(canvasContext: calEvent.contextCode), color = session.enrollmentsDataSource[context]?.color else {
                colorsForDate.insert(UIColor.calendarTintColor)
                continue
            }

            colorsForDate.insert(color)
        }

        return Array(colorsForDate)
    }

    // ---------------------------------------------
    // MARK: - UI Update Methods
    // ---------------------------------------------
    private func initNavigationButtons() {
        var navigationButtons = [UIBarButtonItem]()
        // Navigation Buttons
        if let refreshImage = UIImage(named: "icon_sync", inBundle: CalendarMonthViewController.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) {
            let refreshButton = UIBarButtonItem(image: refreshImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthViewController.refreshButtonPressed(_:)))
            navigationButtons.append(refreshButton)
        }

        if let todayView = IconTodayView.instantiateFromNib(NSDate(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarMonthViewController.todayButtonPressed(_:))) {
            let todayButton = UIBarButtonItem(customView: todayView)
            navigationButtons.append(todayButton)
        }

        navigationItem.rightBarButtonItems = navigationButtons
    }

    // ---------------------------------------------
    // MARK: - Data Functions
    // ---------------------------------------------
    public func reloadData(forced: Bool = false) {
        self.refresher?.refresh(forced)
    }

    func updateCalendarEvents() {
        let startDate = NSDate().dateByAddingTimeInterval(-365.days)
        let endDate = NSDate().dateByAddingTimeInterval(365.days)

        eventsCollection = try! CalendarEvent.collectionByDueDate(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher = try! CalendarEvent.refresher(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher?.refresh(false)
        eventsCollection.collectionUpdated = { [unowned self] updates in
            self.calendarView?.reloadVisibleCells()
        }
    }

    public func selectedContextCodes() -> [String] {
        var contextCodes: [String] = []
        for i in 0..<favCoursesCollection.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            contextCodes.append(favCoursesCollection[indexPath].contextID.canvasContextID)
        }

        return contextCodes
    }

    internal func calendarEventsForDate(date: NSDate) -> [CalendarEvent] {
        let section = self.sectionForDate(date)
        if let section = section {
            return self.objectsInSection(section)
        }
        return [CalendarEvent]()
    }

    // We need to speed this up
    internal func sectionForDate(date: NSDate) -> Int? {
        let sections = 0..<eventsCollection.numberOfSections()
        for section in sections {
            guard let dateString = eventsCollection.titleForSection(section), collectionDate = CalendarEvent.sectionTitleDateFormatter.dateFromString(dateString) else {
                ❨╯°□°❩╯⌢"Section Date Formatter is not as expected."
            }

            if date.compare(collectionDate) == .OrderedSame {
                return section
            }
        }

        return nil
    }

    // This needs a kick in the pants too
    internal func objectsInSection(section: Int) -> [CalendarEvent] {
        var events = [CalendarEvent]()

        for i in 0..<eventsCollection.numberOfItemsInSection(section) {
            events.append(eventsCollection[NSIndexPath(forRow: i, inSection: section)])
        }
        
        return events
    }
    
}
