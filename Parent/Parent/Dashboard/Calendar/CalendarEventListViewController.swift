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

import ReactiveSwift
import CanvasCore
import Core

class CalendarEventListViewController: UITableViewController {
    var env = AppEnvironment.shared

    @objc let emptyView = TableEmptyView.nibView()

    @objc static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEEMMMMd", options: 0, locale: NSLocale.current)
        return dateFormatter
    }()

    @objc let session: Session
    @objc let studentID: String
    @objc let startDate: Date
    @objc let endDate: Date
    fileprivate var contextCodes: [String]
    fileprivate var courseNamesDictionary = [String: String]()

    @objc func selectCalendarEventAction(_ session: Session, _ observeeID: String, _ calendarEvent: CalendarEvent) {
        guard let courseID = ContextID(canvasContext: calendarEvent.contextCode)?.id else { return }
        switch calendarEvent.type {
        case .assignment, .quiz:
            guard let assignmentID = calendarEvent.assignmentID else { fallthrough }
            env.router.route(to: .course(courseID, assignment: assignmentID), from: self, options: .modal(embedInNav: true, addDoneButton: true))
        default:
            env.router.route(to: .courseCalendarEvent(courseID: courseID, eventID: calendarEvent.id), from: self, options: .modal(embedInNav: true, addDoneButton: true))
        }
    }

    var courseCollection: FetchedCollection<CanvasCore.Course>?
    var collection: FetchedCollection<CalendarEvent>!

    var viewModelFactory: ((CalendarEvent) -> CalendarEventCellViewModel)!

    var refresher: Refresher? {
        didSet {
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            _ = self.refresher?.refreshingCompleted.observeValues { [weak self] err in
                self?.updateEmptyView()
                if let s = self, let e = err {
                    ErrorReporter.reportError(e, from: s)
                }
            }
        }
    }

    @objc init(session: Session, studentID: String, startDate: Date, endDate: Date, contextCodes: [String]) throws {
        self.session = session
        self.studentID = studentID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes

        emptyView.textLabel.text = NSLocalizedString("Nothing this week", comment: "Empty Calendar Events Text")
        emptyView.imageView?.image = UIImage(named: "PandaNoEvents", in: .core, compatibleWith: nil)
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "week_empty_view"

        super.init(nibName: nil, bundle: nil)

        self.viewModelFactory = { [unowned self] calendarEvent in
            CalendarEventCellViewModel.init(calendarEvent: calendarEvent, courseName: self.courseNamesDictionary[calendarEvent.contextCode], highlightColor: .named(.backgroundLight))
        }
        self.courseCollection = try Course.collectionByStudent(session, studentID: studentID)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Can't instantiate CalendarEventListViewController from coder")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = emptyView
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.named(.backgroundLightest)
        tableView.estimatedRowHeight = 90

        CalendarEventCellViewModel.tableViewDidLoad(tableView)
        tableView.register(UINib(nibName: "EmptyCalendarEventCell", bundle: Bundle(for: ParentAppDelegate.self)), forCellReuseIdentifier: "EmptyCalendarEventCell")
    }

    fileprivate var courseUpdatesDisposable: Disposable?
    fileprivate var eventUpdatesDisposable: Disposable?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scheme = ColorScheme.observee(studentID)
        navigationController?.navigationBar.useContextColor(scheme.color)

        courseUpdatesDisposable = courseCollection?.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in
                self.updateData()
            }.map(ScopedDisposable.init)
        self.updateData()
    }

    @objc func updateData() {
        self.contextCodes = self.courseCollection?.filter { [unowned self] course in
            if self.contextCodes.count == 0 {
                return true
            }
            return self.contextCodes.contains(ContextID(id: course.id, context: .course).canvasContextID)
            }.map { course in
                return ContextID(id: course.id, context: .course).canvasContextID
            } ?? []
        for course in self.courseCollection! {
            courseNamesDictionary[ContextID(id: course.id, context: .course).canvasContextID] = course.name
        }
        //  swiftlint:disable:next force_try
        self.collection = try! CalendarEvent.collectionByDueDate(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        //  swiftlint:disable:next force_try
        self.refresher = try! CalendarEvent.refresher(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        self.refresher?.refresh(false)

        self.updateEmptyView()
        eventUpdatesDisposable = collection.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [unowned self] updates in
                self.processUpdates(updates)
            }.map(ScopedDisposable.init)
    }

    // ---------------------------------------------
    // MARK: - UITableView DataSource
    // ---------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let collection = collection, collection.numberOfSections() != 0 else {
            return 0
        }

        return Calendar.current.numberOfDaysInWeek
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let collectionSection = collectionSection(section) else {
            return 1
        }

        return self.collection.numberOfItemsInSection(collectionSection)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TableSectionHeaderView()
        view.preservesSuperviewLayoutMargins = true
        let date = startDate + section.daysComponents
        view.text = CalendarEventListViewController.dateFormatter.string(from: date).uppercased()
        view.accessibilityIdentifier = "event_list_header_\(section)"
        view.accessibilityTraits = UIAccessibilityTraits.header
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let collectionSection = collectionSection(indexPath.section) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCalendarEventCell", for: indexPath)
            return cell
        }

        let collectionIndexPath = IndexPath(row: indexPath.row, section: collectionSection)
        let item = collection[collectionIndexPath]
        let vm = viewModelFactory(item)
        return vm.cellForTableView(tableView, indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collectionSection = collectionSection(indexPath.section) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        let collectionIndexPath = IndexPath(row: indexPath.row, section: collectionSection)
        let calendarEvent = collection[collectionIndexPath]
        selectCalendarEventAction(session, studentID, calendarEvent)
    }

    // This is probably not the best way to search through the sections, but it should be fast enough for now.
    func collectionSection(_ daySection: Int) -> Int? {
        guard let collection = collection else {
            return nil
        }

        let sectionDate = startDate + daySection.daysComponents
        let sections = 0..<collection.numberOfSections()
        for section in sections {
            guard let dateString = collection.titleForSection(section), let collectionDate = CalendarEvent.sectionTitleDateFormatter.date(from: dateString) else {
                fatalError("Section Date Formatter is not as expected.")
            }

            if sectionDate.compare(collectionDate) == .orderedSame {
                return section
            }
        }

        return nil
    }

    func processUpdates(_ updates: [CollectionUpdate<CalendarEvent>]) {
        guard let tableView = tableView else { return }

        tableView.reloadData()
    }

    @objc func updateEmptyView() {
        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = collection.numberOfSections() == 0 && !isRefreshing
        setEmptyViewVisible(emptyVisible)
    }

    @objc func setEmptyViewVisible(_ visible: Bool) {
        emptyView.isHidden = !visible
    }

}
