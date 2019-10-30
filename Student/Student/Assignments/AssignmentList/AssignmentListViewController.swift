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

class AssignmentListViewController: UIViewController, ColoredNavViewProtocol {

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

    func fetchData() {
        showSpinner()

        let requestable = AssignmentListRequestable(courseID: courseID, gradingPeriodID: selectedGradingPeriod?.id.value, filter: shouldFilter)

        env.api.makeRequest(requestable, refreshToken: false) { [weak self] response, _, _ in
            self?.groups = response?.groups.compactMap { $0.assignments.count == 0 ? nil : $0 } ?? []
            self?.gradingPeriods = response?.gradingPeriods ?? []

            if !(self?.shouldFilter ?? false) {
                self?.shouldFilter = true
                if let currentPeriod = self?.gradingPeriods.current { self?.selectedGradingPeriod = currentPeriod }
            }

            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.showSpinner(show: false)
                self?.updateLabels()
            }
        }
    }

    private func configureTableView() {
        tableRefresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = tableRefresher

        tableView.registerCell(ListCell.self)
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableViewDefaultOffset = tableView.contentOffset
        showSpinner()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    @IBAction func actionFilterClicked(_ sender: Any) {
        if selectedGradingPeriod != nil {
            filterByGradingPeriod(nil)
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", comment: ""), preferredStyle: .actionSheet)

            for period in gradingPeriods {
                let action = UIAlertAction(title: period.title, style: .default) { [weak self] _ in
                    self?.filterByGradingPeriod(period)
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }

    @objc func refresh(_ control: UIRefreshControl) {
        fetchData()
    }

    func showSpinner(show: Bool = true) {
        if show {
            tableRefresher.beginRefreshing()
            var pt = tableViewDefaultOffset
            pt.y -= tableRefresher.frame.size.height
            tableView.setContentOffset(pt, animated: true)
        } else {
            tableRefresher.endRefreshing()
        }
    }
}

extension AssignmentListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].assignments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListCell = tableView.dequeue(for: indexPath)
        let a = groups[indexPath.section].assignments[indexPath.row]
        cell.textLabel?.text = a.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = a.formattedDueDate
        cell.imageView?.image = a.icon
        cell.imageView?.tintColor = color
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let assignment = groups[indexPath.section].assignments[indexPath.row]
        guard let url = assignment.htmlUrl else { return }
        env.router.route(to: url, from: self, options: nil)
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
        updateLabels()
        fetchData()
    }
}
