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

public typealias DailyCalendarActivityData = [String: Int]

public class PlannerListViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateViewContainer: UIView!
    @IBOutlet weak var emptyStateHeader: DynamicLabel!
    @IBOutlet weak var emptyStateSubHeader: DynamicLabel!
    @IBOutlet weak var emptytStateImageView: UIImageView!

    let env = AppEnvironment.shared
    var studentID: String?
    var start: Date = Clock.now.startOfDay()
    var end: Date = Clock.now.endOfDay()

    lazy var plannables: Store<GetPlannables> = env.subscribe(GetPlannables(userID: studentID, startDate: start, endDate: end.addSeconds(1))) { [weak self] in
        self?.updatePlannables()
    }

    public static func create(studentID: String?) -> PlannerListViewController {
        let vc = loadFromStoryboard()
        vc.studentID = studentID ?? ""
        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTableview()
        plannables.refresh(force: true)

        emptyStateHeader.text = NSLocalizedString("No Assignments", comment: "")
        emptyStateSubHeader.text = NSLocalizedString("It looks like assignments haven’t been created in this space yet.", comment: "")
        emptytStateImageView.image = UIImage(named: "PandaNoEvents", in: .core, compatibleWith: nil)
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

    public func updateListForDates(start: Date, end: Date) {
        self.start = start
        self.end = end

        plannables = env.subscribe(GetPlannables(userID: studentID, startDate: start, endDate: end.addSeconds(1), contextCodes: [], filter: "")) { [weak self] in
            self?.updatePlannables()
        }

        plannables.refresh(force: true)
    }

    private var cachedMonth: Int?
    private var cachedMonthlyActivityData: DailyCalendarActivityData?

    public func getDailyActivityForMonth(forDate: Date, handler: @escaping (DailyCalendarActivityData?) -> Void) {

        let month = Calendar.current.dateComponents([.month], from: forDate).month
        if cachedMonth == month, let data = cachedMonthlyActivityData {
            handler(data)
            return
        }

        var data: DailyCalendarActivityData = [:]
        let request = GetPlannablesRequest(userID: studentID, startDate: forDate.startOfMonth(), endDate: forDate.endOfMonth(), contextCodes: [], filter: "")
        env.api.exhaust(request) { [weak self] response, _, _ in
            for p in response ?? [] {
                let date = DateFormatter.localizedString(from: p.plannable_date, dateStyle: .short, timeStyle: .none)
                data[date] = (data[date] ?? 0) + 1
            }
            self?.cachedMonthlyActivityData = data
            self?.cachedMonth = month
            handler(data)
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
        guard let plannable = plannables[indexPath], let htmlURL = plannable.htmlURL else { return }
        env.router.route(to: htmlURL, from: self, options: .detail(embedInNav: true))
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
