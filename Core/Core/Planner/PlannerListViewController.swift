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

public class PlannerListViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateViewContainer: UIView!
    @IBOutlet weak var emptyStateHeader: UILabel!
    @IBOutlet weak var emptyStateSubHeader: UILabel!
    @IBOutlet weak var emptyStateTop: NSLayoutConstraint!

    weak var delegate: UIScrollViewDelegate?
    let env = AppEnvironment.shared
    var studentID: String?
    var start: Date = Clock.now.startOfDay()
    var end: Date = Clock.now.endOfDay()

    lazy var plannables = env.subscribe(GetPlannables(userID: studentID, startDate: start, endDate: end)) { [weak self] in
        self?.updatePlannables()
    }

    public static func create(studentID: String? = nil, start: Date, end: Date, delegate: UIScrollViewDelegate?) -> PlannerListViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        controller.studentID = studentID
        controller.start = start
        controller.end = end
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTableview()
        plannables.refresh(force: true)

        emptyStateHeader.text = NSLocalizedString("No Assignments", comment: "")
        emptyStateSubHeader.text = NSLocalizedString("It looks like assignments haven’t been created in this space yet.", comment: "")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    private func configureTableview() {
        tableView.tableFooterView = UIView()
    }

    private func updatePlannables() {
        let pending = plannables.pending
        if !pending {
            if let error = plannables.error { showError(error) }
            tableView.reloadData()

            emptyStateViewContainer.isHidden = plannables.count > 0
        }
    }
}

extension PlannerListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plannables.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlannerListCell = tableView.dequeue(for: indexPath)
        let p = plannables[indexPath]
        cell.update(p)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = plannables[indexPath]?.htmlURL else { return }
        env.router.route(to: url, from: self, options: .detail(embedInNav: true))
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
        emptyStateTop.constant = max(scrollView.contentInset.top, -scrollView.contentOffset.y)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

class PlannerListCell: UITableViewCell {
    @IBOutlet weak var points: DynamicLabel!
    @IBOutlet weak var dueDate: DynamicLabel!
    @IBOutlet weak var title: DynamicLabel!
    @IBOutlet weak var courseCode: DynamicLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var icon: UIImageView!

    func update(_ p: Plannable?) {
        guard let p = p else { return }
        courseCode.text = p.contextName
        title.text = p.title
        dueDate.text = DateFormatter.localizedString(from: p.date, dateStyle: .medium, timeStyle: .short)
        icon.image = p.icon()

        if let value = p.pointsPossible {
            points.text = GradeFormatter.numberFormatter.string(from: NSNumber(value: value))
        } else { points.text = nil }
    }
}
