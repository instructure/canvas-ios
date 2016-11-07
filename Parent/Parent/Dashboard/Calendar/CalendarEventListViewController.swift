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
    
    

import CalendarKit
import SoPersistent
import TooLegit
import EnrollmentKit
import SoLazy
import Airwolf
import ReactiveCocoa

typealias CalendarEventListSelectCalendarEventAction = (session: Session, observeeID: String, calendarEvent: CalendarEvent)->Void

class CalendarEventListViewController: UITableViewController {

    let emptyView = TableEmptyView.nibView()

    static var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("EEEEMMMMd", options: 0, locale: NSLocale.currentLocale())
        return dateFormatter
    }()

    let session: Session
    let studentID: String
    let startDate: NSDate
    let endDate: NSDate
    var dates: [NSDate]
    private var contextCodes: [String]
    private var courseNamesDictionary = [String: String]()
    var selectCalendarEventAction: CalendarEventListSelectCalendarEventAction? = nil

    var courseCollection: FetchedCollection<Course>?
    var collection: FetchedCollection<CalendarEvent>!

    var viewModelFactory: ((CalendarEvent) -> CalendarEventCellViewModel)!

    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            self.refresher?.refreshingCompleted.observeNext { [weak self] err in
                self?.updateEmptyView()
                if let s = self {
                    err?.presentAlertFromViewController(s)
                }
            }
        }
    }

    init(session: Session, studentID: String, startDate: NSDate, endDate: NSDate, contextCodes: [String]) throws {
        self.session = session
        self.studentID = studentID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes
        self.dates = startDate..<endDate

        emptyView.textLabel.text = NSLocalizedString("Nothing this week", comment: "Empty Calendar Events Text")
        emptyView.imageView?.image = UIImage(named: "empty_week")
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "week_empty_view"

        super.init(nibName: nil, bundle: nil)

        let scheme = ColorCoordinator.colorSchemeForStudentID(studentID)
        self.viewModelFactory = { [unowned self] calendarEvent in
            CalendarEventCellViewModel.init(calendarEvent: calendarEvent, courseName: self.courseNamesDictionary[calendarEvent.contextCode], highlightColor: scheme.highlightCellColor)
        }
        self.courseCollection = try Course.collectionByStudent(session, studentID: studentID)
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Can't instantiate CalendarEventListViewController from coder"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = emptyView
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.defaultTableViewBackgroundColor()
        tableView.estimatedRowHeight = 90

        CalendarEventCellViewModel.tableViewDidLoad(tableView)
        tableView.registerNib(UINib(nibName: "EmptyCalendarEventCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "EmptyCalendarEventCell")
    }
    
    private var courseUpdatesDisposable: Disposable?
    private var eventUpdatesDisposable: Disposable?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        courseUpdatesDisposable = courseCollection?.collectionUpdates
            .observeOn(UIScheduler())
            .observeNext { [unowned self] _ in
                self.updateData()
            }.map(ScopedDisposable.init)
        self.updateData()
    }

    func updateData() {
        self.contextCodes = self.courseCollection?.filter { [unowned self] course in
            if self.contextCodes.count == 0 {
                return true
            }
            return self.contextCodes.contains(ContextID(id: course.id, context: .Course).canvasContextID)
            }.map { course in
                return ContextID(id: course.id, context: .Course).canvasContextID
            } ?? []
        for course in self.courseCollection! {
            courseNamesDictionary[ContextID(id: course.id, context: .Course).canvasContextID] = course.name
        }

        self.collection = try! CalendarEvent.collectionByDueDate(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        self.refresher = try! CalendarEvent.calendarEventsAirwolfCollectionRefresher(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        
        self.refresher?.refresh(false)
        self.updateEmptyView()
        eventUpdatesDisposable = collection.collectionUpdates
            .observeOn(UIScheduler())
            .observeNext { [unowned self] updates in
                self.processUpdates(updates)
            }.map(ScopedDisposable.init)
    }

    // ---------------------------------------------
    // MARK: - UITableView DataSource
    // ---------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let collection = collection where collection.numberOfSections() != 0 else {
            return 0
        }

        return self.dates.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let collectionSection = collectionSection(section) else {
            return 1
        }

        return self.collection.numberOfItemsInSection(collectionSection)
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TableSectionHeaderView()
        view.preservesSuperviewLayoutMargins = true
        let date = self.dates[section]
        view.text = CalendarEventListViewController.dateFormatter.stringFromDate(date).uppercaseString
        view.accessibilityIdentifier = "event_list_header_\(section)"
        return view
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let collectionSection = collectionSection(indexPath.section) else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EmptyCalendarEventCell", forIndexPath: indexPath)
            return cell
        }

        let collectionIndexPath = NSIndexPath(forRow: indexPath.row, inSection: collectionSection)
        let item = collection[collectionIndexPath]
        let vm = viewModelFactory(item)
        return vm.cellForTableView(tableView, indexPath: indexPath)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let collectionSection = collectionSection(indexPath.section) else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }

        let collectionIndexPath = NSIndexPath(forRow: indexPath.row, inSection: collectionSection)
        let calendarEvent = collection[collectionIndexPath]
        selectCalendarEventAction?(session: session, observeeID: studentID, calendarEvent: calendarEvent)
    }

    // This is probably not the best way to search through the sections, but it should be fast enough for now.
    func collectionSection(daySection: Int) -> Int? {
        guard let collection = collection else {
            return nil
        }

        let sectionDate = self.dates[daySection]
        let sections = 0..<collection.numberOfSections()
        for section in sections {
            guard let dateString = collection.titleForSection(section), collectionDate = CalendarEvent.sectionTitleDateFormatter.dateFromString(dateString) else {
                ❨╯°□°❩╯⌢"Section Date Formatter is not as expected."
            }

            if sectionDate.compare(collectionDate) == .OrderedSame {
                return section
            }
        }

        return nil
    }

    func processUpdates(updates: [CollectionUpdate<CalendarEvent>]) {
        guard let tableView = tableView else { return }

        tableView.reloadData()
    }

    func updateEmptyView() {
        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = collection.numberOfSections() == 0 && !isRefreshing
        setEmptyViewVisible(emptyVisible)
    }

    func setEmptyViewVisible(visible: Bool) {
        emptyView.hidden = !visible
    }

}
