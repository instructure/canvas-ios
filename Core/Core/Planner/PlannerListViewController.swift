//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

protocol PlannerListDelegate: UIScrollViewDelegate {
    func plannerListWillRefresh()
    func getPlannables(from: Date, to: Date) -> GetPlannables
}

public class PlannerListViewController: UIViewController {
    @IBOutlet weak var emptyStateHeader: UILabel!
    @IBOutlet weak var emptyStateSubHeader: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackgroundView: TableViewBackgroundView!

    weak var delegate: PlannerListDelegate?
    let env = AppEnvironment.shared
    var start: Date = Clock.now.startOfDay() // inclusive
    var end: Date = Clock.now.startOfDay().addDays(1) // exclusive

    var plannables: Store<GetPlannables>?

    static func create(start: Date, end: Date, delegate: PlannerListDelegate?) -> PlannerListViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        controller.start = start
        controller.end = end
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        emptyStateHeader.text = NSLocalizedString("No Events Today!", bundle: .core, comment: "")
        emptyStateSubHeader.text = NSLocalizedString("It looks like a great day to rest, relax, and recharge.", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading events. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(retryAfterError), for: .primaryActionTriggered)

        refreshControl.addTarget(self, action: #selector(plannerListWillRefresh), for: .primaryActionTriggered)
        refreshControl.color = nil
        spinnerView.color = nil
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        self.view.backgroundColor = .backgroundLightest
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableViewBackgroundView.add(to: tableView)
        refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    @objc func retryAfterError() {
        refreshControl.beginRefreshing()
        delegate?.plannerListWillRefresh()
    }

    @objc func plannerListWillRefresh() {
        delegate?.plannerListWillRefresh()
    }

    func refresh(force: Bool = false) {
        errorView.isHidden = true
        plannables = delegate.flatMap { env.subscribe($0.getPlannables(from: start, to: end)) { [weak self] in
            self?.updatePlannables()
        } }
        plannables?.refresh(force: force)
    }

    private func updatePlannables() {
        guard plannables?.requested == true, plannables?.pending == false else { return }
        refreshControl.endRefreshing()
        spinnerView.isHidden = true
        emptyStateView.isHidden = plannables?.error != nil || plannables?.isEmpty != true
        errorView.isHidden = plannables?.error == nil
        tableView.reloadData()
    }
}

extension PlannerListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plannables?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlannerListCell = tableView.dequeue(for: indexPath)
        let p = plannables?[indexPath]
        cell.update(p)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let p = plannables?[indexPath], p.plannableType == .planner_note {
            let noteDetail = PlannerNoteDetailViewController.create(plannable: p)
            env.router.show(noteDetail, from: self, options: .detail)
        } else if let url = plannables?[indexPath]?.htmlURL {
            let to = url.appendingQueryItems(URLQueryItem(name: "origin", value: "calendar"))
            env.router.route(to: to, from: self, options: .detail)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

class PlannerListCell: UITableViewCell {
    @IBOutlet weak var courseCode: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var pointsDivider: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        pointsDivider.setText(pointsDivider.text, style: .textCellSupportingText)
    }

    func update(_ p: Plannable?) {
        accessibilityIdentifier = "PlannerList.event.\(p?.id ?? "")"
        courseCode.setText(p?.contextName, style: .textCellTopLabel)
        title.setText(p?.title, style: .textCellTitle)
        backgroundColor = .backgroundLightest
        let dueDateText = (p?.date).flatMap {
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short)
        }
        dueDate.setText(dueDateText, style: .textCellSupportingText)
        icon.image = p?.icon()
        let pointsText: String? = p?.pointsPossible.flatMap {
            let format = NSLocalizedString("g_points", bundle: .core, comment: "")
            return String.localizedStringWithFormat(format, $0)
        }
        points.setText(pointsText, style: .textCellSupportingText)
        pointsDivider.isHidden = dueDate.text == nil || pointsText == nil
        if !Bundle.main.isParentApp, let color = p?.color {
            courseCode.textColor = color.ensureContrast(against: .backgroundLightest)
            icon.tintColor = color.ensureContrast(against: .backgroundLightest)
        }
        accessoryType = .disclosureIndicator
    }
}
