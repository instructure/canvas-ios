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

class AssignmentListViewController: UIViewController {

    var presenter: AssignmentListPresenter?
    var color: UIColor?
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var gradingPeriodLabel: DynamicLabel!
    @IBOutlet weak var filterButton: DynamicButton!
    let tableRefresher = UIRefreshControl()
    var tableViewDefaultOffset: CGPoint = .zero

    static func create(env: AppEnvironment = .shared, courseID: String, sort: GetAssignments.Sort = .position) -> AssignmentListViewController {
        let vc = loadFromStoryboard()
        vc.presenter = AssignmentListPresenter(view: vc, courseID: courseID, sort: sort)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleViewInNavbar(title: NSLocalizedString("Assignments", comment: ""))
        configureTableView()
        configureSpinner()
        presenter?.refresh()

        filterButton.setTitleColor(color, for: .normal)
    }

    private func configureSpinner() {
        spinner.addConstraintsWithVFL("H:[view(44)]")
        spinner.addConstraintsWithVFL("V:[view(44)]")
        spinner.centerInSuperview(yMultiplier: 0.9)
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
        if presenter?.selectedGradingPeriodID != nil {
            presenter?.filterByGradingPeriod(nil)
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", comment: ""), preferredStyle: .actionSheet)
            let gps: [GradingPeriod] = presenter?.gradingPeriods.all ?? []
            for gp in gps {
                let action = UIAlertAction(title: gp.title, style: .default) { [weak self] _ in
                    self?.presenter?.filterByGradingPeriod(gp)
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }

    @objc func refresh(_ control: UIRefreshControl) {
        presenter?.refresh(force: true)
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
        return presenter?.assignments?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = presenter?.assignments?.sectionInfo(inSection: section) else { return 0 }
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListCell = tableView.dequeue(for: indexPath)
        cell.textLabel?.text = presenter?.assignments?[indexPath]?.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = presenter?.assignments?[indexPath]?.formattedDueDate()
        cell.imageView?.image = presenter?.assignments?[indexPath]?.icon
        cell.imageView?.tintColor = color
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let assignment = presenter?.assignments?[indexPath.row] else { return }
        presenter?.select(assignment, from: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = presenter?.title(forSection: section)
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

extension AssignmentListViewController: AssignmentListViewProtocol {
    func update(loading: Bool) {
        showSpinner(show: loading)
        filterButton.setTitle(presenter?.filterButtonTitle, for: .normal)
        gradingPeriodLabel.text = presenter?.gradingPeriodTitle
        tableView.reloadData()
        view.layoutIfNeeded()
    }
}
