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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ActivityCell = tableView.dequeue(for: indexPath)
        if let a = activities[indexPath] { cell.update(a, courseCache: courseCache) }
        return cell
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
    @IBOutlet weak var subTitleLabel: DynamicLabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var courseCode: DynamicLabel!

    func update(_ activity: Activity, courseCache: [String: ActivityStreamViewController.Info] ) {
        if activity.type == .conversation {
            titleLabel.text = NSLocalizedString("New Message", comment: "")
        } else {
            titleLabel.text = activity.title
        }

        if activity.context?.contextType == .course || activity.type == .discussion, let id = activity.context?.id {
            courseCode.text = courseCache[id]?.courseCode
        } else {
            courseCode.text = nil
        }
        
        if let date = activity.updatedAt {
            subTitleLabel.text = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
        }

        icon.image = activity.icon
        if let id = activity.context?.id {
            icon.tintColor = courseCache[id]?.color
            courseCode.textColor = courseCache[id]?.color
        }
    }
}
