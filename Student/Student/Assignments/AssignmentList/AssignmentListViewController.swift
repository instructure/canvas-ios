//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Core

class AssignmentListViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {

    var color: UIColor?
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var gradingPeriodLabel: DynamicLabel!
    @IBOutlet weak var filterButton: DynamicButton!
    var groups: [APIAssignmentListGroup] = []
    var gradingPeriods: [APIAssignmentListGradingPeriod] = []
    var selectedGradingPeriod: APIAssignmentListGradingPeriod?
    var filterButtonTitle: String = NSLocalizedString("Clear filter", comment: "")
    var gradingPeriodTitle: String?
    let tableRefresher = UIRefreshControl()
    var tableViewDefaultOffset: CGPoint = .zero
    var courseID: String!
    var env: AppEnvironment!
    var shouldFilter = false
    var assignments: [String: [APIAssignmentListAssignment]] = [:]
    var pagingCursor: String?
    var sectionHasNext: [Bool] = []
    var fetchedRequests: [String: String] = [:]
    var groupIDsWithAssignments = [String: String]()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavbar()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.updateNavbar()
    }

    static func create(env: AppEnvironment = .shared, courseID: String, sort: GetAssignments.Sort = .position) -> AssignmentListViewController {

        let vc = loadFromStoryboard()
        vc.courseID = courseID
        vc.env = env
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        courses.refresh()
        colors.refresh()

        setupTitleViewInNavbar(title: NSLocalizedString("Assignments", comment: ""))
        configureTableView()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
        if let indexPath = tableView.indexPathForSelectedRow { tableView.deselectRow(at: indexPath, animated: true) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func configureTableView() {
        tableRefresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = tableRefresher

        tableView.registerCell(ListCell.self)
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableViewDefaultOffset = tableView.contentOffset
        showSpinner()
    }

    func fetchData() {
        DispatchQueue.main.async { [weak self] in self?.showSpinner() }

        let requestable = AssignmentListRequestable(courseID: courseID, gradingPeriodID: selectedGradingPeriod?.id.value, filter: shouldFilter, cursor: pagingCursor)

        if let cursor = pagingCursor {
            guard fetchedRequests[cursor] == nil else { return }
            fetchedRequests[cursor] = cursor
        }

        env.api.makeRequest(requestable, refreshToken: true) { [weak self] response, _, error in
            if let error = error {
                self?.showError(error);
                return
            }

            self?.processAPIResponse(response)
        }
    }

    func processAPIResponse( _ response: APIAssignmentListResponse? ) {
        guard let response = response else { return }
        //  if this is the first time we have a count of the groups,
        //  setup flags for which sections have more pages
        if sectionHasNext.count == 0 {
            //  since this is the first pass, get indexes of groups
            //  that we care about (i.e. assignment.count > 0).  Groups
            //  w/ 0 assignments should not be shown.  All groups are returned
            //  with paging, so we need to keep indexes of groups we care about
            for g in response.groups {
                if g.assignments.count > 0 {
                    groupIDsWithAssignments[g.id.value] = g.id.value
                }
            }
            sectionHasNext = Array(repeating: false, count: groupIDsWithAssignments.count)
        }

        groups = response.groups.filter{ groupIDsWithAssignments[ $0.id.value ] != nil }
        gradingPeriods = response.gradingPeriods

        //  append new assignments to existing arrays
        for ( index, g ) in groups.enumerated() {
            let groupID = g.id.value
            var existing = assignments[groupID] ?? []
            //  if it's the first run or hasNextPage == true, then append assignments
            if existing.count == 0 || sectionHasNext[index] == true {
                existing += g.assignments
                assignments[groupID] = existing
            }

            //  handle paging cursor
            if let pageInfo = g.pageInfo {
                sectionHasNext[index] = pageInfo.hasNextPage
            }
        }

        //  cursor should be the same for all assignmentConnections
        pagingCursor = groups.compactMap{ $0.pageInfo?.endCursor }.first

        if !(shouldFilter) {
            shouldFilter = true
            if let currentPeriod = gradingPeriods.current { selectedGradingPeriod = currentPeriod }
        }

        performUIUpdate { [weak self] in
            self?.tableView.reloadData()
            self?.showSpinner(show: false)
            self?.updateLabels()
            self?.selectFirstCellOnIpad()
        }
    }

    func resetAPIRequestState() {
        assignments = [:]
        pagingCursor = nil
        sectionHasNext = []
        fetchedRequests = [:]
        groupIDsWithAssignments = [:]
    }

    func selectFirstCellOnIpad() {
        if let splitView = splitViewController, splitView.viewControllers.count == 2 {
            let ip = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: ip, animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: ip)
        }
    }

    @IBAction func actionFilterClicked(_ sender: UIButton) {
        if selectedGradingPeriod != nil {
            filterByGradingPeriod(nil)
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", comment: ""), preferredStyle: .actionSheet)

            for period in gradingPeriods {
                let action = AlertAction(period.title, style: .default) { [weak self] _ in
                    self?.filterByGradingPeriod(period)
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
            alert.addAction(cancel)

            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.sourceView = sender

            env.router.show(alert, from: self, options: .modal)
        }
    }

    @objc func refresh(_ control: UIRefreshControl) {
        fetchData()
    }

    func showSpinner(show: Bool = true) {
        if show {
            tableRefresher.beginRefreshing()
        } else {
            tableRefresher.endRefreshing()
        }
    }
}

extension AssignmentListViewController: UITableViewDataSource, UITableViewDelegate {
    func assignment(for indexPath: IndexPath) -> APIAssignmentListAssignment? {
        return assignments[ groups[indexPath.section].id.value ]?[indexPath.row]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let loadCell = sectionHasNext[section] ? 1 : 0
        let assignmentCnt = assignments[ groups[section].id.value ]?.count ?? 0
        return assignmentCnt + loadCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListCell = tableView.dequeue(for: indexPath)
        let loadCell = sectionHasNext[indexPath.section]
        if loadCell && indexPath.row == assignments[ groups[indexPath.section].id.value ]?.count ?? 0 {
            cell.textLabel?.text = NSLocalizedString("Loading...", comment: "")
            cell.detailTextLabel?.text = nil
            cell.imageView?.image = nil

            DispatchQueue.global().async { [weak self] in
                self?.fetchData()
            }

        } else {
            let a = assignment(for: indexPath)
            cell.textLabel?.text = a?.name
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.text = a?.formattedDueDate
            cell.imageView?.image = a?.icon
            cell.imageView?.tintColor = color
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let a = assignment(for: indexPath)
        guard let url = a?.htmlUrl else { return }
        env.router.route(to: url, from: self, options: [.detail, .embedInNav])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = groups[section].name
        return view
    }

    class ListCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            textLabel?.font = UIFont.scaledNamedFont(.semibold16)
            detailTextLabel?.font = UIFont.scaledNamedFont(.medium14)
            detailTextLabel?.textColor = UIColor.named(.textDark)
            accessoryType = .disclosureIndicator
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension AssignmentListViewController {
    func updateLabels() {
        let buttonTitle = selectedGradingPeriod == nil ? NSLocalizedString("Filter", comment: "") : NSLocalizedString("Clear filter", comment: "")
        filterButton.setTitle(buttonTitle, for: .normal)
        gradingPeriodLabel.text = selectedGradingPeriod?.title ?? NSLocalizedString("All Grading Periods", comment: "")
    }

    func updateNavbar() {
        if let color = courses.first?.color {
            self.color = color
            filterButton.setTitleColor(color, for: .normal)
            updateNavBar(subtitle: nil, color: color)
        }
    }

    func filterByGradingPeriod(_ selected: APIAssignmentListGradingPeriod?) {
        selectedGradingPeriod = selected
        resetAPIRequestState()
        updateLabels()
        showSpinner(show: true)
        fetchData()
    }
}
