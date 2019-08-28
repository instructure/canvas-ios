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
import ReactiveSwift
import CanvasCore
import class CanvasCore.Course
import Core

open class CalendarDayListViewController: UITableViewController {
    // ---------------------------------------------
    // MARK: - Constants
    // ---------------------------------------------
    @objc let noResultsPadding: CGFloat = 50
    @objc var didFinishRefreshing: ()->() = { }

    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // Public

    @objc open var routeToURL: RouteToURL!
    @objc open var colorForContextID: ColorForContextID!
    fileprivate var session: Session!
    fileprivate var toastManager: ToastManager?

    // Private
    var eventsCollection: FetchedCollection<CalendarEvent>?
    var favCoursesCollection: FetchedCollection<Course>?
    var allCoursesCollection: FetchedCollection<Course>?
    
    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            refresher?.refreshingCompleted.observeValues { [weak self] error in
                if let me = self {
                    me.updateEmptyView()
                    ErrorReporter.reportError(error, from: self)
                    me.didFinishRefreshing()
                }
            }
        }
    }

    fileprivate var calendar: Calendar = Calendar.current
    @objc internal var day: Date? {
        didSet {
            let noResultsExplanation = wittyResponses[Int(arc4random_uniform(UInt32(wittyResponses.count)))]
            emptyView?.lblExplanation.text = noResultsExplanation
        }
    }

    // Private
    // Views
    @objc var emptyView: NoResultsView? = nil
    @objc var noResultsLabel: UILabel? = nil

    // Date Formatters
    @objc var dateFormatter = DateFormatter()

    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------

    fileprivate let wittyResponses = [
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

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    @objc public static func new(_ session: Session, date: Date, routeToURL: @escaping RouteToURL, colorForContextID: @escaping ColorForContextID) -> CalendarDayListViewController {
        let controller = CalendarDayListViewController(nibName: nil, bundle: nil)
        controller.session = session
        controller.routeToURL = routeToURL
        controller.colorForContextID = colorForContextID
        controller.day = date
        return controller
    }
    
    fileprivate var favCoursesDisposable: Disposable?

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = navigationController?.navigationBar {
            toastManager = ToastManager(navigationBar: nav)
        }

        favCoursesCollection = try? Course.favoritesCollection(session)
        favCoursesDisposable = favCoursesCollection?.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.updateCalendarEvents()
            }.map(ScopedDisposable.init)
        
        allCoursesCollection = try? Course.allCoursesCollection(session)
        
        updateCalendarEvents()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let noResultsExplanation = wittyResponses[Int(arc4random_uniform(UInt32(wittyResponses.count)))]
        emptyView = NoResultsView.instantiateFromNib(noResultsExplanation)
        emptyView?.frame = self.view.bounds.insetBy(dx: noResultsPadding, dy: noResultsPadding)
        tableView.backgroundView = emptyView

        tableView.backgroundColor = UIColor.calendarDayDetailBackgroundColor
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 94.0
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.refresher?.refresh(false)
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarDayListViewController.contentSizeCategoryChanged(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    // User selected a new default font size in preferences
    @objc func contentSizeCategoryChanged(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override open func viewDidLayoutSubviews() {
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
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return eventsCollection?.numberOfSections() ?? 0
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numItems = eventsCollection?.numberOfItemsInSection(section) ?? 0
        let eventsPresent = numItems > 0
        tableView.isUserInteractionEnabled = eventsPresent
        emptyView?.alpha = eventsPresent ? 0.0 : 1.0

        return numItems
    }

    fileprivate lazy var bundle: Bundle = {
        return Bundle(for: self.classForCoder)
    }()

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CalendarDayListCell! = tableView.dequeueReusableCell(withIdentifier: CalendarDayListCell.ReuseID) as? CalendarDayListCell
        if cell == nil {
            let topLevelObjects = bundle.loadNibNamed("CalendarDayListCell", owner: self)!
            cell = (topLevelObjects[0] as! CalendarDayListCell)
        }

        configureCell(cell, indexPath: indexPath)
        return cell
    }

    @objc func configureCell(_ cell: CalendarDayListCell, indexPath: IndexPath) {
        guard let calEvent = eventsCollection?[indexPath] else {
            return
        }
        cell.titleLabel.text = calEvent.title
        cell.dueLabel.text = calEvent.dueText()
        cell.typeImage.image = calEvent.typeImage()
        cell.locationLabel.text = calEvent.locationInfo.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        guard let context = ContextID(canvasContext: calEvent.contextCode), let color = session.enrollmentsDataSource[context]?.color.value else {
            cell.typeImage.tintColor = UIColor.calendarTintColor
            cell.courseLabel.text = ""
            return
        }

        cell.typeImage.tintColor = color
        let matchingContextName = session.enrollmentsDataSource[context]?.name
        cell.courseLabel.text = matchingContextName
    }

    // ---------------------------------------------
    // MARK: - UITableViewDelegate
    // ---------------------------------------------
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Analytics.shared.logEvent("calendar_event_selected")
        if let calEvent = eventsCollection?[indexPath], let routeToURL = routeToURL, let url = calEvent.routingURL {
            routeToURL(url)
        }
    }

    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    @objc open func reloadData() {
        self.refresher?.refresh(true)
    }
    
    fileprivate var eventsDisposable: Disposable?

    @objc func updateCalendarEvents() {
        guard let day = day,
            let refresherEndDate = calendar.date(byAdding: .day, value: 1, to: day + 1.daysComponents) else {
            eventsCollection = nil
            refresher = nil
            eventsDisposable?.dispose()
            tableView.reloadData()
            return
        }
        let startDate = day.startOfDay(calendar)
        let endDate = day + 1.daysComponents
        eventsCollection = try? CalendarEvent.collectionByDueDate(session, startDate: startDate, endDate: endDate, contextCodes: selectedContextCodes())
        refresher = try? CalendarEvent.refresher(session, startDate: startDate, endDate: refresherEndDate, contextCodes: selectedContextCodes())
        refresher?.refresh(false)
        eventsDisposable = eventsCollection?.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [unowned self] updates in
                self.tableView?.reloadData()
            }.map(ScopedDisposable.init)
    }

    @objc open func selectedContextCodes() -> [String] {
        let anyFavorites = favCoursesCollection?.isEmpty == false
        guard let collection = anyFavorites ? favCoursesCollection : allCoursesCollection else {
            return []
        }
        var contextCodes: [String] = []
        for i in 0..<collection.numberOfItemsInSection(0) {
            let indexPath = IndexPath(row: i, section: 0)
            contextCodes.append(collection[indexPath].contextID.canvasContextID)
        }

        return contextCodes
    }

    @objc func updateEmptyView() {
        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = tableView.numberOfSections == 0 && !isRefreshing
        setEmptyViewVisible(emptyVisible)
    }
    
    @objc func setEmptyViewVisible(_ visible: Bool) {
        emptyView?.isHidden = !visible
    }
    
}

