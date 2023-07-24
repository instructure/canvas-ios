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

public class ConferenceListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    public let titleSubtitleView = TitleSubtitleView.create()

    public var color: UIColor?
    var context = Context.currentUser
    let env = AppEnvironment.shared
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/conferences"
    )

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var conferences = env.subscribe(GetConferences(context: context)) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    public static func create(context: Context) -> ConferenceListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Conferences", bundle: .core, comment: ""))

        emptyMessageLabel.text = NSLocalizedString("There are no conferences to display yet.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Conferences", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading conferences. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        tableView.backgroundColor = .backgroundLightest
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.separatorColor = .borderMedium

        colors.refresh()
        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        conferences.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
        navigationController?.navigationBar.useContextColor(color)
    }

    func updateNavBar() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }
        view.tintColor = color
        spinnerView.color = color
        refreshControl.color = color
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        spinnerView.isHidden = !conferences.pending || !conferences.isEmpty || conferences.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = conferences.pending || !conferences.isEmpty || conferences.error != nil
        errorView.isHidden = conferences.error == nil
        tableView.reloadData()
    }

    @objc func refresh() {
        conferences.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension ConferenceListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return conferences.sections?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = conferences.sections?[section].numberOfObjects ?? 0
        if conferences.hasNextPage, conferences.sections?.count == section + 1 {
            count += 1
        }
        return count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = conferences[IndexPath(row: 0, section: section)]?.isConcluded == true
            ? NSLocalizedString("Concluded Conferences", bundle: .core, comment: "")
            : NSLocalizedString("New Conferences", bundle: .core, comment: "")
        view.titleLabel?.accessibilityIdentifier = "ConferencesList.header-\(section)"
        return view
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if conferences.hasNextPage && indexPath.row == conferences.sections?[indexPath.section].numberOfObjects {
            conferences.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }
        let cell = tableView.dequeue(ConferenceListCell.self, for: indexPath)
        cell.update(conferences[indexPath], color: color)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let conference = conferences[indexPath] else { return }
        env.router.route(to: "/\(context.pathComponent)/conferences/\(conference.id)", from: self, options: .detail)
    }
}

class ConferenceListCell: UITableViewCell {
    @IBOutlet weak var iconView: AccessIconView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func update(_ conference: Conference?, color: UIColor?) {
        backgroundColor = .backgroundLightest
        iconView.icon = .conferences
        if Bundle.main.isTeacherApp {
            iconView.state = conference?.isConcluded == true ? .unpublished : .published
        }
        titleLabel.setText(conference?.title, style: .textCellTitle)
        titleLabel.accessibilityIdentifier = (conference?.id).map { "ConferencesList.cell-\($0).title" }
        statusLabel.setText(conference?.statusText, style: .textCellSupportingText)
        statusLabel.textColor = conference?.statusColor
        statusLabel.accessibilityIdentifier = (conference?.id).map { "ConferencesList.cell-\($0).status" }
        detailsLabel.setText(conference?.details, style: .textCellBottomLabel)
        detailsLabel.accessibilityIdentifier = (conference?.id).map { "ConferencesList.cell-\($0).details" }
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
    }
}
