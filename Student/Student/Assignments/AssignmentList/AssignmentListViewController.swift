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
    var selectedGradingPeriod: GradingPeriod?
    var filterButtonTitle: String = NSLocalizedString("Clear filter", comment: "")
    var gradingPeriodTitle: String?
    let tableRefresher = CircleRefreshControl()
    var tableViewDefaultOffset: CGPoint = .zero
    var courseID: String!
    var env = AppEnvironment.shared

    var appTraitCollection: UITraitCollection?

    var model = AssignmentListModel()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavbar()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.updateNavbar()
    }

    lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.gradingPeriodsDidUpdate()
    }

    static func create(
        env: AppEnvironment = .shared,
        courseID: String,
        sort: GetAssignments.Sort = .position,
        appTraitCollection: UITraitCollection? = AppEnvironment.shared.window?.traitCollection
    ) -> AssignmentListViewController {
        let controller = loadFromStoryboard()
        controller.appTraitCollection = appTraitCollection
        controller.courseID = courseID
        controller.env = env
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleViewInNavbar(title: NSLocalizedString("Assignments", comment: ""))
        configureTableView()

        showSpinner()
        courses.refresh()
        colors.refresh()
        gradingPeriods.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
        if let indexPath = tableView.indexPathForSelectedRow { tableView.deselectRow(at: indexPath, animated: true) }
    }

    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableRefresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = tableRefresher

        tableView.registerCell(ListCell.self)
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableViewDefaultOffset = tableView.contentOffset
    }

    func fetchData(showActivityIndicator: Bool = false, cursor: String? = nil) {
        if showActivityIndicator {
            performUIUpdate { [weak self] in self?.showSpinner() }
        }

        let filter: AssignmentFilter
        if let id = selectedGradingPeriod?.id {
            filter = .gradingPeriod(id: id)
        } else {
            filter = .allGradingPeriods
        }

        let requestable = AssignmentListRequestable(courseID: courseID, filter: filter, pageSize: 25, cursor: cursor)
        env.api.makeRequest(requestable, refreshToken: true) { [weak self] response, _, error in
            if let error = error {
                self?.showError(error)
                return
            }
            self?.processAPIResponse(response)
        }
    }

    func processAPIResponse( _ response: APIAssignmentListResponse? ) {
        guard let response = response else { return }
        model.addResponse(response: response)
        performUIUpdate { [weak self] in
            self?.showSpinner(show: false)
            self?.tableView.reloadData()
            self?.updateLabels()
            self?.updateFilterButton()
            self?.selectFirstCellOnIpad()
        }
    }

    func resetAPIRequestState() {
        model = AssignmentListModel()
    }

    func selectFirstCellOnIpad() {
        let ip = IndexPath(row: 0, section: 0)
        if model.assignment(for: ip) != nil, splitViewController != nil, appTraitCollection?.horizontalSizeClass == .regular, !isInSplitViewDetail {
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

            env.router.show(alert, from: self, options: .modal())
        }
    }

    @objc func refresh(_ control: CircleRefreshControl) {
        resetAPIRequestState()
        gradingPeriods.refresh(force: true)
    }

    func showSpinner(show: Bool = true) {
        if show {
            tableRefresher.beginRefreshing()
        } else if tableRefresher.isRefreshing {
            tableRefresher.endRefreshing()
        }
    }
}

extension AssignmentListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { model.groups.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = model.assignmentCount(forSection: section)
        let loadingCell = model.hasNext(forSection: section) ? 1 : 0
        return cnt + loadingCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListCell = tableView.dequeue(for: indexPath)
        let loadingCell = model.hasNext(forSection: indexPath.section) && (indexPath.row == model.assignmentCount(forSection: indexPath.section))

        if loadingCell {
            cell.textLabel?.text = NSLocalizedString("Loading...", comment: "")
            cell.detailTextLabel?.text = nil
            cell.imageView?.image = nil
            cell.accessibilityIdentifier = nil
            let cursor = model.dequeueCursor(forSection: indexPath.section)
            fetchData(cursor: cursor)
            return cell
        }

        let a = model.assignment(for: indexPath)
        cell.textLabel?.text = a?.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = a?.formattedDueDate
        cell.imageView?.image = a?.icon
        cell.imageView?.tintColor = color
        if let id = a?.id {
            let cellId = "assignment-list.assignment-list-row.cell-\(id)"
            cell.accessibilityIdentifier = cellId
            cell.textLabel?.accessibilityIdentifier = "\(cellId).name"
            cell.detailTextLabel?.accessibilityIdentifier = "\(cellId).due"
        } else {
            cell.accessibilityIdentifier = nil
            cell.textLabel?.accessibilityIdentifier = nil
            cell.detailTextLabel?.accessibilityIdentifier = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = model.assignment(for: indexPath)
        guard let url = assignment?.htmlUrl else { return }
        env.router.route(to: url, from: self, options: .detail)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        if let group = model.group(forSection: section) {
            view.titleLabel?.text = group.name
        }
        return view
    }

    class ListCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            backgroundColor = .backgroundLightest
            textLabel?.font = UIFont.scaledNamedFont(.semibold16)
            detailTextLabel?.font = UIFont.scaledNamedFont(.medium14)
            detailTextLabel?.textColor = UIColor.textDark
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
        gradingPeriodLabel.text = selectedGradingPeriod?.title ?? NSLocalizedString("All", comment: "")
    }

    func updateFilterButton() {
        filterButton.isHidden = gradingPeriods.count == 0
    }

    func updateNavbar() {
        if let color = courses.first?.color {
            self.color = color
            filterButton.setTitleColor(color, for: .normal)
            updateNavBar(subtitle: courses.first?.name, color: color)
            tableRefresher.color = color
        }
    }

    func gradingPeriodsDidUpdate() {
        if gradingPeriods.pending == false && gradingPeriods.requested {
            selectedGradingPeriod = gradingPeriods.all.current
            fetchData(showActivityIndicator: true)
        }
    }

    func filterByGradingPeriod(_ selected: GradingPeriod?) {
        selectedGradingPeriod = selected
        resetAPIRequestState()
        updateLabels()
        fetchData(showActivityIndicator: true)
    }
}
