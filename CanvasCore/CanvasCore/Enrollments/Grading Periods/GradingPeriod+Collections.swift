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

import CoreData


import ReactiveSwift
import Result
import Cartography

extension GradingPeriodItem {
    func colorfulViewModel(_ dataSource: EnrollmentsDataSource, courseID: String, selected: ReactiveSwift.Property<Bool>) -> ColorfulViewModel {
        let model = ColorfulViewModel()
        model.title.value = title
        model.color <~ dataSource.color(for: .course(withID: courseID))
        model.accessoryType <~ selected.map { $0 ? .checkmark : .none }
        return model
    }
}


extension GradingPeriod {
    static func collectionCacheKey(_ context: NSManagedObjectContext, courseID: String) -> String {
        return cacheKey(context, [courseID])
    }

    public static func predicate(_ courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    internal static func predicate(_ courseID: String, notMatchingID id: String?) -> NSPredicate {
        return id.flatMap { NSPredicate(format: "%K == %@ && %K != %@", "courseID", courseID, "id", $0) } ?? NSPredicate(format: "%K == %@", "courseID", courseID)
    }
    
    public static func gradingPeriodIDs(_ session: Session, courseID: String, excludingGradingPeriodID: String?) throws -> [String] {
        let context = try session.enrollmentManagedObjectContext()
        let fetch: NSFetchRequest<GradingPeriod> = context.fetch(predicate(courseID, notMatchingID: excludingGradingPeriodID))
        let invalidatedGradingPeriods: [GradingPeriod] = try context.findAll(fromFetchRequest: fetch)
        return invalidatedGradingPeriods.map { $0.id }
    }

    public static func collectionByCourseID(_ session: Session, courseID: String) throws -> FetchedCollection<GradingPeriod> {
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(predicate(courseID), sortDescriptors: ["startDate".ascending])
        )
    }

    public static func refresher(_ session: Session, courseID: String) throws -> Refresher {
        let context = try session.enrollmentManagedObjectContext()
        let remote = try GradingPeriod.getGradingPeriods(session, courseID: courseID)
        let sync = GradingPeriod.syncSignalProducer(inContext: context, fetchRemote: remote) { gradingPeriod, _ in
            gradingPeriod.courseID = courseID
        }

        let key = collectionCacheKey(context, courseID: courseID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    open class TableViewController: CanvasCore.TableViewController {
        fileprivate (set) open var collection: GradingPeriodCollection!

        func prepare<VM: TableViewCellViewModel>(_ collection: GradingPeriodCollection, refresher: Refresher? = nil, viewModelFactory: @escaping (GradingPeriodItem)->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
        
        public init(session: Session, courseID: String, collection: GradingPeriodCollection, refresher: Refresher) throws {
            super.init()
            
            title = NSLocalizedString("Grading Periods", tableName: "Localizable", bundle: .core, value: "", comment: "Title for grading periods picker")
            collection.selectedGradingPeriod.signal
                .observe(on: UIScheduler())
                .observeValues { [weak collection] _ in collection?.updatesObserver.send(value: [.reload]) }

            let dataSource = session.enrollmentsDataSource
            prepare(collection, refresher: refresher) { item in
                return item.colorfulViewModel(dataSource, courseID: courseID, selected: Property(initial: false, then: self.collection.selectedGradingPeriod.producer.map { $0 == item }))
            }
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError()
        }

        open override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        }

        override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let item = collection[indexPath]
            collection.selectGradingPeriod(gradingPeriod: item)
        }

        func cancel() {
            dismiss(animated: true, completion: nil)
        }
    }
    
    open class Header: NSObject, UITableViewDataSource, UITableViewDelegate {
        // Input
        open let includeGradingPeriods: Bool
        open weak var viewController: UIViewController?
        open let grade: MutableProperty<String?>
        
        // Output
        open var selectedGradingPeriod: ReactiveSwift.Property<GradingPeriodItem?> {
            guard includeGradingPeriods else {
                return ReactiveSwift.Property(value: nil)
            }
            return ReactiveSwift.Property(initial: nil, then: gradingPeriodsList.collection.selectedGradingPeriod.producer.map { Optional($0) })
        }

        open lazy var tableView: UITableView = {
            let tableView = UITableView(frame: CGRect.zero, style: .plain)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isScrollEnabled = false
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableViewAutomaticDimension
            return tableView
        }()

        fileprivate let gradingPeriod: ReactiveSwift.Property<String?>
        fileprivate let gradingPeriodsList: TableViewController
        fileprivate var disposable: Disposable?

        var includeGrade: Bool {
            return grade.value != nil
        }

        public init?(session: Session, courseID: String, viewController: UIViewController, includeGradingPeriods: Bool, grade: MutableProperty<String?> = MutableProperty(nil)) throws {
            guard let course = session.enrollmentsDataSource[ContextID(id: courseID, context: .course)] as? Course else {
                return nil
            }

            self.includeGradingPeriods = includeGradingPeriods
            self.grade = grade

            let collection = try GradingPeriod.collectionByCourseID(session, courseID: courseID)
            let gradingPeriodsCollection = GradingPeriodCollection(course: course, gradingPeriods: collection)
            let refresher = try GradingPeriod.refresher(session, courseID: courseID)
            self.gradingPeriodsList = try TableViewController(session: session, courseID: courseID, collection: gradingPeriodsCollection, refresher: refresher)

            self.viewController = viewController

            self.gradingPeriod = ReactiveSwift.Property(initial: nil, then: gradingPeriodsCollection.selectedGradingPeriod.producer.map { $0.title })

            super.init()

            // reload table view when grading period or grade change
            SignalProducer.combineLatest(gradingPeriod.producer, grade.producer)
                .observe(on: UIScheduler())
                .startWithValues { [weak self] this in
                    if let tableView = self?.tableView {
                        tableView.reloadData()
                    }
                }

            if includeGradingPeriods {
                refresher.refresh(false)
            }
        }
        
        open func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return [includeGradingPeriods, includeGrade].filter { $0 }.count
        }
        
        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch indexPath.row {
            case 0:
                guard includeGradingPeriods else {
                    fallthrough
                }
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = gradingPeriod.value
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = NSLocalizedString("Total Grade", tableName: "Localizable", bundle: .core, value: "", comment: "Total grade label")
                cell.detailTextLabel?.text = grade.value
                cell.selectionStyle = .none
                return cell
            default: fatalError("too many rows!")
            }
        }
        
        open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            switch indexPath.row {
            case 0 where includeGradingPeriods:
                let nav = UINavigationController(rootViewController: gradingPeriodsList)
                nav.modalPresentationStyle = .formSheet

                disposable?.dispose()
                disposable = gradingPeriodsList.collection.selectedGradingPeriod.signal
                    .observe(on: UIScheduler())
                    .observeValues { _ in
                        nav.dismiss(animated: true) {
                            tableView.deselectRow(at: indexPath, animated: true)
                        }
                    }

                viewController?.present(nav, animated: true, completion: {
                    tableView.deselectRow(at: indexPath, animated: true)
                })
            default: break
            }
        }
    }
}
