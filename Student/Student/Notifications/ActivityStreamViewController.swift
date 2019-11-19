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

import UIKit
import Core

class ActivityStreamViewController: UITableViewController {

    struct Info {
        let name: String?
        let courseCode: String?
        let color: UIColor?
    }

    let env = AppEnvironment.shared
    lazy var activities = env.subscribe(GetActivities()) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourses()) { [weak self] in
        self?.cacheCourses()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.cacheCourses()
    }

    static let dateFormatter: DateFormatter = {
        var d = DateFormatter()
        d.dateFormat  = "yyyy-MM-dd HH:mm:ss ZZ"
        return d
    }()

    var courseCache: [String: Info] = [:]

    static func create() -> ActivityStreamViewController {
        let vc = loadFromStoryboard()
        return vc
    }

    override func viewDidLoad() {
        setupTableView()
        refreshData()
    }

    func setupTableView() {
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView?.refreshControl = refresh
    }

    @objc func refresh(_ control: UIRefreshControl) {
        control.endRefreshing()
        refreshData(force: true)
     }

    func refreshData(force: Bool = false) {
        courses.exhaust(while: { _ in true })
        activities.refresh(force: force)
        colors.refresh(force: force)
    }

    func update() {
        tableView.reloadData()
    }

    func cacheCourses() {
        if colors.pending || courses.pending { return }
        courses.forEach { [weak self] in self?.courseCache[ $0.id ] = Info(name: $0.name, courseCode: $0.courseCode, color: $0.color) }
        update()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        activities.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.sectionInfo(inSection: section)?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ActivityCell = tableView.dequeue(for: indexPath)
        if let a = activities[indexPath] { cell.update(a, courseCache: courseCache) }
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let info = activities.sectionInfo(inSection: section) else { return nil }
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        if let dt: Date = ActivityStreamViewController.dateFormatter.date(from: info.name) {
            view.titleLabel?.text = DateFormatter.localizedString(from: dt, dateStyle: .long, timeStyle: .none)
        }
        return view
    }
}

extension ActivityStreamViewController {
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            activities.getNextPage()
        }
    }
}

class ActivityCell: UITableViewCell {
    @IBOutlet weak var titleLabel: DynamicLabel!
    @IBOutlet weak var typeLabel: DynamicLabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var pill: TokenView!

    func update(_ activity: Activity, courseCache: [String: ActivityStreamViewController.Info] ) {
        if activity.type == .conversation {
            titleLabel.text = NSLocalizedString("New Message", comment: "")
        } else {
            titleLabel.text = activity.title
        }

        if activity.context?.contextType == .course || activity.type == .discussion, let id = activity.context?.id {
            typeLabel.text = courseCache[id]?.name
            pill.text = courseCache[id]?.courseCode
        } else {
            typeLabel.text = nil
            pill.text = nil
        }

        icon.image = activity.icon?.withRenderingMode(.alwaysTemplate)
        if let id = activity.context?.id {
            icon.tintColor = courseCache[id]?.color
            pill.backgroundColor = courseCache[id]?.color
        }
    }
}
