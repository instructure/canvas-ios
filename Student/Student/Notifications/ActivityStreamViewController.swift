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

class ActivityStreamViewController: ScreenViewTrackableViewController {

    struct Info {
        let name: String?
        let courseCode: String?
        let color: UIColor?
    }

    let env = AppEnvironment.shared
    lazy var activities = env.subscribe(GetActivities(context: context)) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourses()) { [weak self] in
        self?.cacheCourses()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.cacheCourses()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateContainer: UIView!
    @IBOutlet weak var emptyStateHeader: DynamicLabel!
    @IBOutlet weak var emptyStateSubHeader: DynamicLabel!

    lazy var profileButton = UIBarButtonItem(image: .hamburgerSolid, style: .plain, target: self, action: #selector(openProfile))

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMd", options: 0, locale: NSLocale.current)
        return dateFormatter
    }()

    var courseCache: [String: Info] = [:]
    var context: Context?
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/notifications", attributes: ["customPageViewPath": "/"]
    )

    static func create(context: Context? = nil) -> ActivityStreamViewController {
        let vc = loadFromStoryboard()
        vc.context = context
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Notifications", comment: "Notifications tab title")
        navigationItem.titleView = Brand.shared.headerImageView()
        view.backgroundColor = .backgroundLightest
        setupTableView()
        emptyStateHeader.text = NSLocalizedString("No Notifications", comment: "")
        emptyStateSubHeader.text = NSLocalizedString("There's nothing to be notified of yet.", comment: "")
        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.navigationBar.backItem == nil {
            navigationItem.leftBarButtonItem = profileButton
            navigationController?.navigationBar.useGlobalNavStyle()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow { tableView.deselectRow(at: indexPath, animated: true) }
    }

    func setupTableView() {
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        let refreshControl = CircleRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        tableView.backgroundColor = .backgroundLightest
    }

    @objc func refresh() {
        refreshData(force: true)
    }

    private func isDataLoading() -> Bool {
        activities.pending || courses.pending || colors.pending
    }

    func refreshData(force: Bool = false) {
        guard !isDataLoading() else { return }
        courses.exhaust { _ in true }
        activities.refresh(force: force)
        colors.refresh(force: force)
    }

    func update() {
        guard !isDataLoading() else { return }
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
        emptyStateContainer.isHidden = !activities.isEmpty
    }

    func cacheCourses() {
        if colors.pending || courses.pending { return }
        courses.forEach { [weak self] in self?.courseCache[ $0.id ] = Info(name: $0.name, courseCode: $0.courseCode, color: $0.color) }
        update()
    }

    @objc func openProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }
}

extension ActivityStreamViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ActivityCell = tableView.dequeue(for: indexPath)
        if let a = activities[indexPath] { cell.update(a, courseCache: courseCache) }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let a = activities[indexPath], let url = a.htmlURL else { return }
        env.router.route(to: url, from: self, options: .detail)
    }
}

extension ActivityStreamViewController {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        backgroundColor = .backgroundLightest
        if activity.type == ActivityType.conversation {
            titleLabel.setText(NSLocalizedString("New Message", comment: ""), style: .textCellTitle)
        } else {
            titleLabel.setText(activity.title, style: .textCellTitle)
        }

        if activity.context?.contextType == .course || activity.type == .discussion, let id = activity.context?.id {
            courseCode.setText(courseCache[id]?.courseCode, style: .textCellTopLabel)
            courseCode.isHidden = false
        } else {
            courseCode.text = nil
            courseCode.isHidden = true
        }

        if let date = activity.updatedAt {
            subTitleLabel.setText(ActivityStreamViewController.dateFormatter.string(from: date), style: .textCellSupportingText)
        }

        icon.image = activity.icon
        if let id = activity.context?.id {
            icon.tintColor = courseCache[id]?.color
            courseCode.textColor = courseCache[id]?.color
        }
    }
}
