//
//  AssignmentsTableViewController.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 4/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import AssignmentKit
import SoPretty
import EnrollmentKit
import TooLegit
import ReactiveCocoa
import SoLazy
import SoPersistent
import Result
import TechDebt

extension Assignment {
    func colorfulViewModel(dataSource: ContextDataSource) -> ColorfulViewModel {
        let model = ColorfulViewModel(style: .Basic)
        model.title.value = name
        model.color <~ dataSource.producer(ContextID(id: courseID, context: .Course)).map { $0?.color ?? .prettyGray() }
        model.icon.value = icon
        return model
    }
}

class AssignmentsTableViewController: Assignment.TableViewController {
    let session: Session
    let courseID: String
    let route: (UIViewController, NSURL)->()
    
    var header: GradingPeriod.Header!
    var multipleGradingPeriodsEnabled: Bool {
        return (session.enrollmentsDataSource[ContextID(id: courseID, context: .Course)] as? Course)?.multipleGradingPeriodsEnabled ?? false
    }

    init(session: Session, courseID: String, route: (UIViewController, NSURL)->()) throws {
        self.session = session
        self.courseID = courseID
        self.route = route

        super.init()

        header = try GradingPeriod.Header(session: self.session, courseID: self.courseID, viewController: self, includeGradingPeriods: multipleGradingPeriodsEnabled)
        header.selectedGradingPeriod.producer
            .startWithNext { [weak self] item in
                guard let me = self else { return }
                
                do {
                    try me.updateCollections(courseID, gradingPeriodID: item?.gradingPeriodID)
                } catch let error as NSError {
                    error.presentAlertFromViewController(me)
                }
            }

        title = NSLocalizedString("Assignments", comment: "Title for Assignments view controller")

        cbi_canBecomeMaster = true
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"I'm not ready for storyboards!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if multipleGradingPeriodsEnabled {
            header.tableView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: 44)
            tableView.tableHeaderView = header.tableView
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        header.tableView.indexPathsForSelectedRows?.forEach { header.tableView.deselectRowAtIndexPath($0, animated: true) }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let assignment = collection[indexPath]
        route(self, assignment.htmlURL)
    }

    private func updateCollections(courseID: String, gradingPeriodID: String?) throws {
        let collection = try self.collection(session, courseID: courseID, gradingPeriodID: gradingPeriodID)

        let invalidGradingPeriods = try GradingPeriod.gradingPeriodIDs(session, courseID: courseID, excludingGradingPeriodID: gradingPeriodID)
        let assignments = try Assignment.refreshSignalProducer(session, courseID: courseID, gradingPeriodID: gradingPeriodID, invalidatingGradingPeriodIDs: invalidGradingPeriods, cacheKey: cacheKey)
        let grades = try Grade.refreshSignalProducer(session, courseID: courseID, gradingPeriodID: gradingPeriodID).map { _ in () }
        let sync = SignalProducer(values: [assignments, grades]).flatten(.Merge)

        let key = cacheKey(courseID, gradingPeriodID: gradingPeriodID)
        let refresher = SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)

        prepare(collection, refresher: refresher) { [unowned self] in
            return self.viewModelFactory($0)
        }

        // manually show the refresh control because of some bug somewhere
        if refresher.shouldRefresh  {
            tableView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y - refresher.refreshControl.frame.size.height)
        }

        refresher.refresh(false)
    }

    func collection(session: Session, courseID: String, gradingPeriodID: String?) throws -> FetchedCollection<Assignment> {
        return try Assignment.collectionByDueStatus(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
    }

    func viewModelFactory(assignment: Assignment) -> ColorfulViewModel {
        let dataSource = session.enrollmentsDataSource
        return assignment.colorfulViewModel(dataSource)
    }

}

func cacheKey(courseID: String, gradingPeriodID: String?) -> String {
    return ["assignments", courseID, gradingPeriodID].flatMap { $0 }.joinWithSeparator("//")
}

class GradesTableViewController: AssignmentsTableViewController {
    let gradesCollection: FetchedCollection<Grade>

    override init(session: Session, courseID: String, route: (UIViewController, NSURL) -> ()) throws {
        self.gradesCollection = try Grade.collectionByCourseID(session, courseID: courseID)

        try super.init(session: session, courseID: courseID, route: route)

        let course = session.enrollmentsDataSource.producer(ContextID(id: courseID, context: .Course)).map { $0 as? Course }
        let gradingPeriod = header.selectedGradingPeriod.producer
        let grades = SignalProducer<Void, NoError> { [weak self] observer, _ in
            observer.sendNext(())
            self?.gradesCollection.collectionUpdated = { _ in
                observer.sendNext(())
            }
        }

        header.grade <~ combineLatest(course, gradingPeriod, grades)
            .observeOn(UIScheduler())
            .map { course, gradingPeriodItem, _ in
                if let item = gradingPeriodItem {
                    switch item {
                    case .All:
                        return "-"
                    case .Some(let gradingPeriod):
                        return course?.gradingPeriodGradeButtonTitle(gradingPeriod.id) ?? "carpenter"
                    }
                }
                return course?.gradeButtonTitle ?? "yooho"
            }

        title = NSLocalizedString("Grades", comment: "Title for Grades view controller")
        
        cbi_canBecomeMaster = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        header.tableView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: header.includeGradingPeriods ? 88 : 44)
        tableView.tableHeaderView = header.tableView
    }

    override func viewModelFactory(assignment: Assignment) -> ColorfulViewModel {
        let dataSource = session.enrollmentsDataSource
        return assignment.gradeColorfulViewModel(dataSource)
    }

    override func collection(session: Session, courseID: String, gradingPeriodID: String?) throws -> FetchedCollection<Assignment> {
        return try Assignment.collectionByAssignmentGroup(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
    }
 }

extension Course {
    func gradingPeriodGradeButtonTitle(gradingPeriodID: String) -> String {
        let grades: String = [visibleGradingPeriodGrade(gradingPeriodID), visibleGradingPeriodScore(gradingPeriodID)]
            .flatMap( { $0 } )
            .joinWithSeparator("   ")

        if grades != "" {
            return grades
        }

        return NSLocalizedString("Ungraded", comment: "Title for grade button when no grade is present")
    }
}
