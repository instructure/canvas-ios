//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import UIKit

struct CourseSearchFilter: Equatable {
    enum SearchBy: Int {
        case courses, teachers
    }

    var searchTerm: String?
    var searchBy: SearchBy
    var term: APITerm?

    /// If true, include only courses with at least one enrollment.
    /// If false, include only courses with no enrollments.
    /// If not nil, do not filter on course enrollment status.
    var hideCoursesWithoutStudents: Bool?

    init(
        searchTerm: String? = nil,
        searchBy: SearchBy = .courses,
        hideCoursesWithoutStudents: Bool? = nil,
        term: APITerm? = nil
    ) {
        self.searchTerm = searchTerm
        self.searchBy = searchBy
        self.hideCoursesWithoutStudents = hideCoursesWithoutStudents
        self.term = term
    }
}

@available(iOS 13.0, *)
public class CourseSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, CourseSearchFilterOptionsDelegate {
    enum Section {
        case courses
    }

    var env: AppEnvironment!
    var accountID: String!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var minimumSearchLabel: UILabel!
    @IBOutlet weak var searchBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!

    var dataSource: UITableViewDiffableDataSource<Section, APICourse>!
    var courses: [APICourse] = [] {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Section, APICourse>()
            snapshot.appendSections([.courses])
            snapshot.appendItems(courses)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    var terms: [APITerm]?
    let throttle = Throttle(delay: 0.4)
    var workItem: DispatchWorkItem?
    var searchTask: URLSessionTask?
    var nextPage: GetNextRequest<[APICourse]>?
    var filter = CourseSearchFilter() {
        didSet {
            updateResults()
            updateFilterButton()
        }
    }
    var keyboard: KeyboardTransitioning?

    let tableFooterHeight: CGFloat = 20

    public static func create(env: AppEnvironment = .shared, accountID: String) -> CourseSearchViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.accountID = accountID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Courses", comment: "")
        view.backgroundColor = UIColor.named(.backgroundLightest)
        searchBySegmentedControl.addTarget(self, action: #selector(searchByDidChange), for: .valueChanged)
        emptyView.bodyText = nil
        configureFilterButton()
        configureTableView()
        configureDataSource()
        updateResults()
        loadTerms()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    func configureTableView() {
        let loadingNextPageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: tableFooterHeight))
        loadingNextPageLabel.text = NSLocalizedString("Loading more courses...", comment: "")
        loadingNextPageLabel.font = UIFont.scaledNamedFont(.medium12)
        loadingNextPageLabel.textColor = UIColor.named(.textDark)
        loadingNextPageLabel.textAlignment = .center
        loadingNextPageLabel.isHidden = true
        tableView.tableFooterView = loadingNextPageLabel
        tableView.contentInset.bottom = -tableFooterHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }

    func configureFilterButton() {
        filterButton.setImage(.icon(.filter), for: .normal)
        filterButton.adjustsImageWhenHighlighted = false
        filterButton.roundCorners(corners: .allCorners, radius: 4)
        updateFilterButton()
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, APICourse>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeue(for: indexPath) as CourseSearchCell
            cell.courseNameLabel.text = item.name
            var teachers = item.teachers?.prefix(2).map { $0.display_name } ?? []
            if let count = item.teachers?.count, count > 2 {
                let format = NSLocalizedString("plus_d_others", bundle: .core, comment: "")
                teachers.append(String.localizedStringWithFormat(format, count - 2))
            }
            cell.teachersLabel.text = teachers.joined(separator: ", ")
            cell.termLabel.text = item.term?.name
            cell.publishedIcon.published = item.workflow_state == .completed || item.workflow_state == .available
            return cell
        }
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        throttle { [weak self] in
            self?.filter.searchTerm = searchText
        }
    }

    func updateResults() {
        self.courses = []
        if let text = filter.searchTerm, text.count > 0 && text.count < 3 {
            minimumSearchLabel.isHidden = false
            return
        }
        emptyView.isHidden = true
        minimumSearchLabel.isHidden = true
        self.loadingIndicator.startAnimating()
        var searchTerm = filter.searchTerm
        if searchTerm?.isEmpty == true {
            searchTerm = nil
        }
        let searchBy: GetAccountCoursesRequest.SearchBy
        switch filter.searchBy {
        case .courses, nil:
            searchBy = .course
        case .teachers:
            searchBy = .teacher
        }
        let request = GetAccountCoursesRequest(
            accountID: self.accountID,
            searchTerm: searchTerm,
            searchBy: searchBy,
            enrollmentTermID: filter.term?.id.value,
            hideCoursesWithoutStudents: filter.hideCoursesWithoutStudents
        )
        self.searchTask?.cancel()
        self.searchTask = self.env.api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                if let error = error {
                    if (error as NSError?)?.code != NSURLErrorCancelled {
                        self.alertError(error)
                    }
                    return
                }
                self.courses = response ?? []
                if let urlResponse = urlResponse {
                    self.nextPage = request.getNext(from: urlResponse)
                }
                if self.courses.isEmpty {
                    self.emptyView.isHidden = false
                }
            }
        }
    }

    func updateFilterButton() {
        let active = filter.hideCoursesWithoutStudents == true || filter.term != nil
        filterButton.layer.borderWidth = active ? 0 : 1.3
        filterButton.layer.borderColor = active ? nil : Brand.shared.buttonPrimaryBackground.cgColor
        filterButton.backgroundColor = active ? Brand.shared.buttonPrimaryBackground : nil
        filterButton.tintColor = active ? Brand.shared.buttonPrimaryText : Brand.shared.buttonPrimaryBackground
        filterButton.setImage(.icon(.filter, active ? .solid : .line), for: .normal)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let course = dataSource?.itemIdentifier(for: indexPath) {
            env.router.route(to: .course(course.id.value), from: self, options: nil)
        }
    }

    @objc func searchByDidChange(_ control: UISegmentedControl) {
        guard let searchBy = CourseSearchFilter.SearchBy(rawValue: control.selectedSegmentIndex) else { return }
        switch searchBy {
        case .courses:
            searchBar.placeholder = NSLocalizedString("Search courses...", comment: "")
        case .teachers:
            searchBar.placeholder = NSLocalizedString("Search courses by teacher...", comment: "")
        }
        filter.searchBy = searchBy
    }

    @IBAction func filterButtonPressed(_ sender: UIButton) {
        guard let terms = terms else { return }
        let filterOptions = CourseSearchFilterOptionsViewController()
        filterOptions.terms = terms
        filterOptions.filter = filter
        filterOptions.delegate = self
        show(filterOptions, sender: self)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            getNextPage()
        }
    }

    func getNextPage() {
        guard let nextPage = nextPage else { return }
        self.nextPage = nil
        tableView.contentInset.bottom = 0
        tableView.tableFooterView?.isHidden = false
        env.api.makeRequest(nextPage) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.contentInset.bottom = -self.tableFooterHeight
                guard let courses = response, error == nil else {
                    self.nextPage = nextPage
                    self.alertError(error ?? NSError.internalError())
                    return
                }
                self.courses += courses
                if let urlResponse = urlResponse {
                    self.nextPage = nextPage.getNext(from: urlResponse)
                }
            }
        }
    }

    func courseSearchFilterOptions(_ filterOptions: CourseSearchFilterOptionsViewController, didChangeFilter filter: CourseSearchFilter) {
        self.filter = filter
    }

    func loadTerms() {
        filterButton.isHidden = true
        filterLoadingIndicator.startAnimating()
        terms = []
        let request = GetAccountTermsRequest(accountID: accountID)
        exhaustTerms(request)
    }

    func exhaustTerms<R>(_ request: R) where R: APIRequestable, R.Response == GetAccountTermsRequest.Response {
        env.api.makeRequest(request) { [weak self] response, urlResponse, _ in
            guard let self = self else { return }
            if let response = response {
                self.terms?.append(contentsOf: response.enrollment_terms)
            }
            if let urlResponse = urlResponse, let next = request.getNext(from: urlResponse) {
                self.exhaustTerms(next)
            } else {
                DispatchQueue.main.async {
                    self.filterLoadingIndicator.stopAnimating()
                    self.filterButton.isHidden = false
                }
            }
        }

    }
}

class CourseSearchCell: UITableViewCell {
    @IBOutlet weak var publishedIcon: PublishedIconView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var teachersLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!
}
