//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import ReactiveCocoa
import Cartography

extension GradingPeriodItem {
    func colorfulViewModel(dataSource: EnrollmentsDataSource, courseID: String, selected: Bool) -> ColorfulViewModel {
        let model = ColorfulViewModel(style: .Basic)
        model.title.value = title
        model.color <~ dataSource.producer(ContextID(id: courseID, context: .Course)).map { $0?.color ?? .prettyGray() }
        model.accessoryType.value = selected ? .Checkmark : .None
        return model
    }
}


extension GradingPeriod {
    static func collectionCacheKey(context: NSManagedObjectContext, courseID: String) -> String {
        return cacheKey(context, [courseID])
    }

    public static func predicate(courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    internal static func predicate(courseID: String, notMatchingID id: String?) -> NSPredicate {
        return id.flatMap { NSPredicate(format: "%K == %@ && %K != %@", "courseID", courseID, "id", $0) } ?? NSPredicate(format: "%K == %@", "courseID", courseID)
    }
    
    public static func gradingPeriodIDs(session: Session, courseID: String, excludingGradingPeriodID: String?) throws -> [String] {
        let context = try session.enrollmentManagedObjectContext()
        let invalidatedGradingPeriods: [GradingPeriod] = try context.findAll(fromFetchRequest: GradingPeriod.fetch(GradingPeriod.predicate(courseID, notMatchingID: excludingGradingPeriodID), sortDescriptors: nil, inContext: context))
        return invalidatedGradingPeriods.map { $0.id }
    }

    public static func collectionByCourseID(session: Session, courseID: String) throws -> FetchedCollection<GradingPeriod> {
        let frc = GradingPeriod.fetchedResults(GradingPeriod.predicate(courseID), sortDescriptors: ["startDate".ascending], sectionNameKeypath: nil, inContext: try session.enrollmentManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session, courseID: String) throws -> Refresher {
        let context = try session.enrollmentManagedObjectContext()
        let remote = try GradingPeriod.getGradingPeriods(session, courseID: courseID)
        let sync = GradingPeriod.syncSignalProducer(inContext: context, fetchRemote: remote) { gradingPeriod, _ in
            gradingPeriod.courseID = courseID
        }

        let key = collectionCacheKey(context, courseID: courseID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public class TableViewController: SoPersistent.TableViewController {
        private (set) public var collection: GradingPeriodCollection!

        func prepare<VM: TableViewCellViewModel>(collection: GradingPeriodCollection, refresher: Refresher? = nil, viewModelFactory: GradingPeriodItem->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
        
        public init(session: Session, courseID: String, collection: GradingPeriodCollection, refresher: Refresher) throws {
            super.init()
            
            title = NSLocalizedString("Grading Periods", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "Title for grading periods picker")
            collection.selectedGradingPeriod.producer
                .observeOn(UIScheduler())
                .startWithNext { [weak collection] _ in collection?.updatesObserver.sendNext([.Reload]) }

            let dataSource = session.enrollmentsDataSource
            prepare(collection, refresher: refresher) { item in
                return item.colorfulViewModel(dataSource, courseID: courseID, selected: item == self.collection.selectedGradingPeriod.value)
            }
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError()
        }

        public override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancel))
        }

        override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = collection[indexPath]
            collection.selectedGradingPeriod.value = item
        }

        func cancel() {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    public class Header: NSObject, UITableViewDataSource, UITableViewDelegate {
        // Input
        public let includeGradingPeriods: Bool
        public weak var viewController: UIViewController?
        public let grade: MutableProperty<String?>
        
        // Output
        public var selectedGradingPeriod: AnyProperty<GradingPeriodItem?> {
            guard includeGradingPeriods else {
                return AnyProperty(ConstantProperty(nil))
            }
            return AnyProperty(gradingPeriodsList.collection.selectedGradingPeriod)
        }

        public lazy var tableView: UITableView = {
            let tableView = UITableView(frame: CGRectZero, style: .Plain)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.scrollEnabled = false
            tableView.tableFooterView = UIView(frame: CGRectZero)
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableViewAutomaticDimension
            return tableView
        }()

        private let gradingPeriod: AnyProperty<String?>
        private let gradingPeriodsList: TableViewController
        private var disposable: Disposable?

        var includeGrade: Bool {
            return grade.value != nil
        }

        public init(session: Session, courseID: String, viewController: UIViewController, includeGradingPeriods: Bool, grade: MutableProperty<String?> = MutableProperty(nil)) throws {
            guard let course = session.enrollmentsDataSource[ContextID(id: courseID, context: .Course)] as? Course else {
                ❨╯°□°❩╯⌢"We gots to have the course. Shouldn't we already have all teh courses?"
            }

            self.includeGradingPeriods = includeGradingPeriods
            self.grade = grade

            let collection = try GradingPeriod.collectionByCourseID(session, courseID: courseID)
            let gradingPeriodsCollection = GradingPeriodCollection(course: course, gradingPeriods: collection)
            let refresher = try GradingPeriod.refresher(session, courseID: courseID)
            self.gradingPeriodsList = try TableViewController(session: session, courseID: courseID, collection: gradingPeriodsCollection, refresher: refresher)

            self.viewController = viewController

            self.gradingPeriod = AnyProperty(initialValue: nil, producer: gradingPeriodsCollection.selectedGradingPeriod.producer.map { $0?.title })

            super.init()

            // reload table view when grading period or grade change
            combineLatest(gradingPeriod.producer, grade.producer)
                .observeOn(UIScheduler())
                .startWithNext { [weak self] this in
                    if let tableView = self?.tableView {
                        tableView.reloadData()
                    }
                }

            if includeGradingPeriods {
                refresher.refresh(false)
            }
        }
        
        public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return [includeGradingPeriods, includeGrade].filter { $0 }.count
        }
        
        public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            switch indexPath.row {
            case 0:
                guard includeGradingPeriods else {
                    fallthrough
                }
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
                cell.textLabel?.text = gradingPeriod.value
                cell.accessoryType = .DisclosureIndicator
                return cell
            case 1:
                let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
                cell.textLabel?.text = NSLocalizedString("Total Grade", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "Total grade label")
                cell.detailTextLabel?.text = grade.value
                cell.selectionStyle = .None
                return cell
            default: fatalError("too many rows!")
            }
        }
        
        public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            switch indexPath.row {
            case 0 where includeGradingPeriods:
                let nav = UINavigationController(rootViewController: gradingPeriodsList)
                nav.modalPresentationStyle = .FormSheet

                disposable?.dispose()
                disposable = gradingPeriodsList.collection.selectedGradingPeriod.signal
                    .observeOn(UIScheduler())
                    .observeNext { _ in
                        nav.dismissViewControllerAnimated(true) {
                            tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        }
                    }

                viewController?.presentViewController(nav, animated: true, completion: {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                })
            default: break
            }
        }
    }
}
