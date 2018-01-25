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
    
    

import Foundation
import ReactiveSwift
import Result
import TechDebt
import CanvasCore

extension Course {
    func totalGrade(_ gradingPeriodItem: GradingPeriodItem?) -> String {
        let grades: [String?]
        let empty = "-"

        if let gradingPeriodItem = gradingPeriodItem {
            switch gradingPeriodItem {
            case .some(let gradingPeriod):
                grades = [visibleGradingPeriodGrade(gradingPeriod.id), visibleGradingPeriodScore(gradingPeriod.id)]
            case .all:
                guard totalForAllGradingPeriodsEnabled else {
                    return empty
                }
                grades = [visibleGradingPeriodGrade(nil), visibleGradingPeriodScore(nil)]
            }
        } else {
            grades = [visibleGrade, visibleScore]
        }

        let totalGrade = grades
            .flatMap { $0 }
            .joined(separator: "  ")

        if totalGrade.isEmpty {
            return empty
        }

        return totalGrade
    }
}

extension Assignment {
    func colorfulViewModel(_ dataSource: EnrollmentsDataSource) -> ColorfulViewModel {
        let model = ColorfulViewModel(features: .icon)
        model.title.value = name
        model.color <~ dataSource.color(for: .course(withID: courseID))
        model.icon.value = icon
        return model
    }
}

class AssignmentsTableViewController: FetchedTableViewController<Assignment>, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    let session: Session
    let courseID: String
    let route: (UIViewController, URL)->()
    
    var header: GradingPeriod.Header!
    var searchController: UISearchController!
    
    var multipleGradingPeriodsEnabled: Bool {
        return (session.enrollmentsDataSource[ContextID(id: courseID, context: .course)] as? Course)?.multipleGradingPeriodsEnabled ?? false
    }

    init(session: Session, courseID: String, route: @escaping (UIViewController, URL)->()) throws {
        self.session = session
        self.courseID = courseID
        self.route = route

        super.init()

        header = try GradingPeriod.Header(session: self.session, courseID: self.courseID, viewController: self, includeGradingPeriods: multipleGradingPeriodsEnabled)
        header.selectedGradingPeriod.producer
            .startWithValues { [weak self] item in
                guard let me = self else { return }
                
                do {
                    try me.updateCollections(courseID, gradingPeriodID: item?.gradingPeriodID)
                } catch let error as NSError {
                    ErrorReporter.reportError(error, from: self)
                }
            }

        title = NSLocalizedString("Assignments", comment: "Title for Assignments view controller")
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"I'm not ready for storyboards!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true

        if multipleGradingPeriodsEnabled {
            header.tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
            tableView.tableHeaderView = header.tableView
//            configureSearchController(header.tableView)
        } else {
//            configureSearchController(tableView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        header.tableView.indexPathsForSelectedRows?.forEach { header.tableView.deselectRow(at: $0, animated: true) }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = collection[indexPath]
        route(self, assignment.htmlURL)
    }

    fileprivate func configureSearchController(_ table: UITableView) {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search here...", comment: "Placeholder text for search bar on assignments page")
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        table.tableHeaderView = searchController.searchBar

        // TODO: When removing the custom split stuff, we should nuke this code
        // if iPad...
        if self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular {
            searchController.hidesNavigationBarDuringPresentation = false
        }
        
        if let refresher = refresher {
            refresher.refreshingBegan.observeValues({ [weak self] in
                self?.searchController.searchBar.isUserInteractionEnabled = false
            })
            
            refresher.refreshingCompleted.observeValues({ [weak self] _ in
                self?.searchController.searchBar.isUserInteractionEnabled = true
            })
        }
    }
    
    fileprivate func updateCollections(_ courseID: String, gradingPeriodID: String?, name: String? = nil) throws {
        let collection = try self.collection(session, courseID: courseID, gradingPeriodID: gradingPeriodID, name: name)
        
        let invalidGradingPeriods = try GradingPeriod.gradingPeriodIDs(session, courseID: courseID, excludingGradingPeriodID: gradingPeriodID)
        let assignments = try Assignment.refreshSignalProducer(session, courseID: courseID, gradingPeriodID: gradingPeriodID, invalidatingGradingPeriodIDs: invalidGradingPeriods, cacheKey: cacheKey)
        let grades = try Grade.refreshSignalProducer(session, courseID: courseID, gradingPeriodID: gradingPeriodID).map { _ in () }
        let sync: SignalProducer<SignalProducer<Void, NSError>, NSError> = SignalProducer([assignments, grades])
        
        let key = cacheKey(courseID, gradingPeriodID: gradingPeriodID)
        let refresher = SignalProducerRefresher(refreshSignalProducer: sync.flatten(.merge), scope: session.refreshScope, cacheKey: key)
        
        prepare(collection, refresher: refresher) { [weak self] (assignment: Assignment) -> ColorfulViewModel in
            guard let me = self else { return ColorfulViewModel(features: .icon) }
            return me.viewModelFactory(assignment)
        }

        if let sc = searchController, sc.isActive {
            refreshControl = nil
        }

        if isViewLoaded {
            refresher.refresh(false)
        }
    }
    
    func collection(_ session: Session, courseID: String, gradingPeriodID: String?, name: String? = nil) throws -> FetchedCollection<Assignment> {
        return try Assignment.collectionByDueStatus(session, courseID: courseID, gradingPeriodID: gradingPeriodID, filteredByName: name)
    }

    func viewModelFactory(_ assignment: Assignment) -> ColorfulViewModel {
        let dataSource = session.enrollmentsDataSource
        return assignment.colorfulViewModel(dataSource)
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text ?? ""
        
        let fuzzySearchString = self.fuzzySearchStringFormatter(searchString)
        
        do {
            try updateCollections(courseID, gradingPeriodID: header.selectedGradingPeriod.value?.gradingPeriodID, name: fuzzySearchString)
        } catch let error as NSError {
            ErrorReporter.reportError(error, from: self)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let r = refresher else { return true }
        
        return !r.isRefreshing
    }
    
    fileprivate func fuzzySearchStringFormatter(_ searchString: String) -> String {
       let searchWithWildcards = NSMutableString(string: "*")
        
        searchString.enumerateSubstrings(in: searchString.startIndex..<searchString.endIndex, options: [.byComposedCharacterSequences], { (substring, substringRange, enclosingRange, stop) -> () in
            if let substring = substring {
                searchWithWildcards.append(substring)
                searchWithWildcards.append("*")
            }
        })
        
        return searchWithWildcards as String
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        refresher?.makeRefreshable(self)
    }
}

func cacheKey(_ courseID: String, gradingPeriodID: String?) -> String {
    return ["assignments", courseID, gradingPeriodID].flatMap { $0 }.joined(separator: "//")
}

class GradesTableViewController: AssignmentsTableViewController {
    let gradesCollection: FetchedCollection<Grade>

    override init(session: Session, courseID: String, route: @escaping (UIViewController, URL) -> ()) throws {
        self.gradesCollection = try Grade.collectionByCourseID(session, courseID: courseID)

        try super.init(session: session, courseID: courseID, route: route)

        guard let course = session.enrollmentsDataSource[ContextID(id: courseID, context: .course)] as? Course else {
            let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Error loading course.", comment: "")]
            throw NSError(domain: "com.instructure.ios", code: -1, userInfo: userInfo)
        }

        let gradingPeriod = header.selectedGradingPeriod.signal
        let grades = gradesCollection.collectionUpdates

        header.grade.value = course.totalGrade(header.selectedGradingPeriod.value)
        header.grade <~ Signal.combineLatest(gradingPeriod, grades)
            .observe(on: UIScheduler())
            .map { gradingPeriodItem, _ in
                return course.totalGrade(gradingPeriodItem)
            }

        title = NSLocalizedString("Grades", comment: "Title for Grades view controller")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        header.tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: header.includeGradingPeriods ? 88 : 44)
        tableView.tableHeaderView = header.tableView
//        configureSearchController(header.tableView)
    }

    override func viewModelFactory(_ assignment: Assignment) -> ColorfulViewModel {
        let dataSource = session.enrollmentsDataSource
        return assignment.gradeColorfulViewModel(dataSource)
    }

    override func collection(_ session: Session, courseID: String, gradingPeriodID: String?, name: String? = nil) throws -> FetchedCollection<Assignment> {
        return try Assignment.collectionByAssignmentGroup(session, courseID: courseID, gradingPeriodID: gradingPeriodID, filteredByName: name)
    }
}
