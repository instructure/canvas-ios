//
//  CalendarDayListViewController.swift
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

public class CalendarDayListViewController: UITableViewController {
    // ---------------------------------------------
    // MARK: - Constants
    // ---------------------------------------------
    let noResultsPadding: CGFloat = 50
    var didFinishRefreshing: ()->() = { }

    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // Public

    public var routeToURL: RouteToURL!
    public var colorForContextID: ColorForContextID!
    private var session: Session!
    private let toastManager = ToastManager()

    // Private
    var eventsCollection: FetchedCollection<CalendarEvent>!
    var favCoursesCollection: FetchedCollection<Course>!

    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            refresher?.refreshingCompleted.observeNext { [weak self] error in
                if let me = self {
                    me.updateEmptyView()
                    error?.presentAlertFromViewController(me)
                    me.didFinishRefreshing()
                }
            }
        }
    }

    private var calendar: NSCalendar = NSCalendar.currentCalendar()
    internal var day: NSDate? {
        didSet {
            let noResultsExplanation = wittyResponses[Int(arc4random_uniform(UInt32(wittyResponses.count)))]
            emptyView?.lblExplanation.text = noResultsExplanation
        }
    }

    // Private
    // Views
    var emptyView: NoResultsView? = nil
    var noResultsLabel: UILabel? = nil
    private var customRefreshControl: CSGFlyingPandaRefreshControl? = nil

    // Date Formatters
    var dateFormatter = NSDateFormatter()

    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------

    private let wittyResponses = [
        NSLocalizedString("Nothing to do, go play outside!", comment: "Nothing to do, go play outside!"),
        NSLocalizedString("Nothing to see here.", comment: "Nothing to see here."),
        NSLocalizedString("I give you back your time, use it wisely.", comment: "I give you back your time, use it wisely."),
        NSLocalizedString("It’s empty, what are you still doing here.", comment: "It’s empty, what are you still doing here."),
        NSLocalizedString("This would be a great time to do some extra credit.", comment: "This would be a great time to do some extra credit."),
        NSLocalizedString("You should go rate Canvas on the App Store!", comment: "You should go rate Canvas on the App Store!")
    ]

    required public init!(coder aDecoder: NSCoder) {
        fatalError("not allowed!")
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public static func new(session: Session, date: NSDate, routeToURL: RouteToURL, colorForContextID: ColorForContextID) -> CalendarDayListViewController {
        let controller = CalendarDayListViewController(nibName: nil, bundle: nil)
        controller.session = session
        controller.routeToURL = routeToURL
        controller.colorForContextID = colorForContextID
        controller.day = date
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        favCoursesCollection = try! Course.favoritesCollection(session)
        favCoursesCollection.collectionUpdated = { [unowned self] _ in
            self.updateCalendarEvents()
        }

        updateCalendarEvents()

        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle

        let noResultsExplanation = wittyResponses[Int(arc4random_uniform(UInt32(wittyResponses.count)))]
        emptyView = NoResultsView.instantiateFromNib(noResultsExplanation)
        emptyView?.frame = CGRectInset(self.view.bounds, noResultsPadding, noResultsPadding)
        tableView.backgroundView = emptyView

        tableView.backgroundColor = UIColor.calendarDayDetailBackgroundColor
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 94.0
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.refresher?.refresh(false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarDayListViewController.contentSizeCategoryChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

    // User selected a new default font size in preferences
    func contentSizeCategoryChanged(notification: NSNotification) {
        tableView.reloadData()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let tabBar = self.tabBarController?.tabBar {
            let height = tabBar.frame.height
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
        }
    }

    // ---------------------------------------------
    // MARK: - UITableViewDataSource
    // ---------------------------------------------
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventsCollection.numberOfSections()
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventsPresent = eventsCollection.numberOfItemsInSection(section) > 0
        tableView.userInteractionEnabled = eventsPresent
        emptyView?.alpha = eventsPresent ? 0.0 : 1.0

        return eventsCollection.numberOfItemsInSection(section)
    }

    private lazy var bundle: NSBundle = {
        return NSBundle(forClass: self.classForCoder)
    }()

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CalendarDayListCell! = tableView.dequeueReusableCellWithIdentifier(CalendarDayListCell.ReuseID) as? CalendarDayListCell
        if cell == nil {
            let topLevelObjects: NSArray = bundle.loadNibNamed("CalendarDayListCell", owner: self, options: [NSObject: AnyObject]())
            cell = topLevelObjects[0] as! CalendarDayListCell
        }

        configureCell(cell, indexPath: indexPath)
        return cell
    }

    func configureCell(cell: CalendarDayListCell, indexPath: NSIndexPath) {
        let calEvent = eventsCollection[indexPath]
        cell.titleLabel.text = calEvent.title
        cell.dueLabel.text = calEvent.dueText()
        cell.typeImage.image = calEvent.typeImage()

        guard let context = ContextID(canvasContext: calEvent.contextCode), color = session.enrollmentsDataSource[context]?.color else {
            cell.typeImage.tintColor = UIColor.calendarTintColor
            cell.courseLabel.text = ""
            return
        }

        cell.typeImage.tintColor = color
        let matchingContextName = session.enrollmentsDataSource.enrollmentsByContextID.filter { (contextID, enrollment) -> Bool in
            return enrollment.contextID.id == context.id
            }.map { (contextID, enrollment) -> String in
                return enrollment.name
            }.first
        cell.courseLabel.text = matchingContextName
    }

    // ---------------------------------------------
    // MARK: - UITableViewDelegate
    // ---------------------------------------------
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let calEvent = eventsCollection[indexPath]
        if let routeToURL = routeToURL, url = calEvent.routingURL {
            routeToURL(url: url)
        }
    }

    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    public func reloadData() {
        self.refresher?.refresh(true)
    }

    func updateCalendarEvents() {
        let startDate = day!.startOfDay(calendar)
        let endDate = day! + 1.daysComponents
        eventsCollection = try! CalendarEvent.collectionByDueDate(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher = try! CalendarEvent.refresher(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher?.refresh(false)
        eventsCollection.collectionUpdated = { [unowned self] updates in
            self.tableView?.reloadData()
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

    func updateEmptyView() {
        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = tableView.numberOfSections == 0 && !isRefreshing
        setEmptyViewVisible(emptyVisible)
    }
    
    func setEmptyViewVisible(visible: Bool) {
        emptyView?.hidden = !visible
    }
    
}

