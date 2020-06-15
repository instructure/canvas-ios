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

public class SyllabusSummaryViewController: UITableViewController {
    let env = AppEnvironment.shared
    var courseID: String!
    var context: Context { Context(.course, id: courseID) }
    public weak var colorDelegate: ColorDelegate?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    public lazy var assignments = env.subscribe(GetCalendarEvents(context: context, type: .assignment)) {}
    public lazy var events = env.subscribe(GetCalendarEvents(context: context, type: .event)) {}

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    public lazy var summary: Store<LocalUseCase<CalendarEventItem>> = {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CalendarEventItem.contextRaw), self.context.canvasContextID)
        let hasStartAt = NSSortDescriptor(key: #keyPath(CalendarEventItem.hasStartAt), ascending: false)
        let startAt = NSSortDescriptor(key: #keyPath(CalendarEventItem.startAt), ascending: true)
        let title = NSSortDescriptor(key: #keyPath(CalendarEventItem.title), ascending: true, naturally: true)
        let order = [hasStartAt, startAt, title]
        let scope = Scope(predicate: predicate, order: order)
        return env.subscribe(scope: scope) { [weak self] in
            self?.update()
        }
    }()

    public static func create(courseID: String, colorDelegate: ColorDelegate? = nil) -> SyllabusSummaryViewController {
        let viewController = SyllabusSummaryViewController(nibName: nil, bundle: nil)
        viewController.courseID = courseID
        viewController.colorDelegate = colorDelegate
        return viewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.separatorInset = .zero
        tableView.separatorColor = .named(.borderMedium)
        tableView.tableFooterView = UIView()
        tableView.registerCell(SyllabusSummaryItemCell.self)

        let refresh = CircleRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .primaryActionTriggered)
        tableView.refreshControl = refresh

        course.refresh()
        color.refresh()
        summary.refresh()

        assignments.exhaust(force: false)
        events.exhaust(force: false)
    }

    func update() {
        let pending = assignments.pending || events.pending
        if tableView.refreshControl?.isRefreshing == true, !pending {
            tableView.refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        assignments.exhaust(force: true)
        events.exhaust(force: true)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summary.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SyllabusSummaryItemCell.self, for: indexPath)
        let item = summary[indexPath.row]
        cell.backgroundColor = .named(.backgroundLightest)
        cell.itemNameLabel?.text = item?.title
        cell.iconImageView?.image = item?.type == .assignment ? .icon(.assignment, .line) : .icon(.calendarMonth, .line)
        cell.iconImageView?.tintColor = colorDelegate?.iconColor ?? course.first?.color
        cell.dateLabel?.text = item?.startAt.flatMap(formatDate(_:)) ?? NSLocalizedString("No Due Date", bundle: .core, comment: "")
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = summary[indexPath]
        if let url = item?.htmlUrl {
            env.router.route(to: url, from: self)
        }
    }

    func formatDate(_ date: Date) -> String? {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
}

class SyllabusSummaryItemCell: UITableViewCell {

    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var itemNameLabel: DynamicLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        loadFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}
