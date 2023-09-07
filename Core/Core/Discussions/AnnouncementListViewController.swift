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

public class AnnouncementListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol, ErrorViewController {
    lazy var addButton = UIBarButtonItem(image: .addSolid, style: .plain, target: self, action: #selector(add))
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = CircleRefreshControl()
    public var titleSubtitleView = TitleSubtitleView.create()

    public var color: UIColor?
    var context = Context.currentUser
    let env = AppEnvironment.shared
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "\(context.pathComponent)/announcements")

    var selectedFirstTopic: Bool = false

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = context.contextType == .course ? env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var group = context.contextType == .group ? env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var topics = env.subscribe(GetAnnouncements(context: context)) { [weak self] in
        self?.update()
    }
    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: context))

    public static func create(context: Context) -> AnnouncementListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Announcements", comment: ""))

        addButton.accessibilityLabel = NSLocalizedString("Create Announcement", comment: "")

        emptyMessageLabel.text = NSLocalizedString("It looks like announcements haven’t been created in this space yet.", comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Announcements", comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading announcements. Pull to refresh to try again.", comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil
        refreshControl.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        tableView.backgroundColor = .backgroundLightest
        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        view.backgroundColor = .backgroundLightest
        colors.refresh()
        // We must force refresh because the GetCourses call deletes all existing Courses from the CoreData cache and since GetCourses response includes no permissions we lose that information.
        course?.refresh(force: true)
        group?.refresh { [context, weak group, weak env] _ in
            guard context.contextType == .group, let courseID = group?.first?.courseID else { return }
            _ = env?.subscribe(GetEnabledFeatureFlags(context: Context.course(courseID))).refresh()
        }
        topics.exhaust()
        if context.contextType != .group {
            featureFlags.refresh()
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        navigationController?.navigationBar.useContextColor(color)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc func refresh() {
        selectedFirstTopic = false
        colors.refresh(force: true)
        course?.refresh(force: true)
        group?.refresh(force: true)
        topics.exhaust(force: true) { [weak self] _ in
            if self?.topics.hasNextPage == false {
                self?.refreshControl.endRefreshing()
            }
            return true
        }
    }

    func updateNavBar() {
        if colors.pending == false,
            let name = course?.first?.name ?? group?.first?.name,
            let color = course?.first?.color ?? group?.first?.color {
            updateNavBar(subtitle: name, color: color)
            view.tintColor = color
        }
        let canAdd = (course?.first?.canCreateAnnouncement ?? group?.first?.canCreateAnnouncement) == true
        navigationItem.rightBarButtonItem = canAdd ? addButton : nil
    }

    func update() {
        loadingView.isHidden = topics.state != .loading || refreshControl.isRefreshing
        emptyView.isHidden = topics.state != .empty
        errorView.isHidden = topics.state != .error
        tableView.reloadData()

        if !selectedFirstTopic, topics.state != .loading, let url = topics.first?.htmlURL {
            selectedFirstTopic = true
            if splitViewController?.isCollapsed == false, !isInSplitViewDetail {
                env.router.route(to: url, from: self, options: .detail)
            }
        }
    }

    @objc func add() {
        env.router.route(
            to: "\(context.pathComponent)/announcements/new",
            from: self,
            options: .modal(isDismissable: false, embedInNav: true)
        )
    }

    func deleteTopic(at indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
        guard let topicID = topics[indexPath]?.id else { return completionHandler(false) }
        let alert = UIAlertController(
            title: NSLocalizedString("Delete Announcement", comment: ""),
            message: NSLocalizedString("Are you sure you would like to delete this announcement?", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            let useCase = DeleteDiscussionTopic(context: self.context, topicID: topicID)
            useCase.fetch { [weak self] _, _, error in performUIUpdate {
                if let error = error { self?.showError(error) }
            } }
        })
        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel))
        env.router.show(alert, from: self, options: .modal())
        completionHandler(true)
    }
}

extension AnnouncementListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AnnouncementListCell = tableView.dequeue(for: indexPath)
        cell.accessibilityIdentifier = "announcements.list.announcement.row-\(indexPath.row)"
        cell.update(topic: topics[indexPath], isTeacher: course?.first?.hasTeacherEnrollment == true, color: color)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = topics[indexPath]?.id else { return }
        env.router.route(to: "\(context.pathComponent)/announcements/\(id)", from: self, options: .detail)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        if topics[indexPath]?.canDelete == true {
            let action = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { [weak self] (_, _, handler) in
                self?.deleteTopic(at: indexPath, completionHandler: handler)
            }
            action.backgroundColor = .backgroundDanger
            actions.append(action)
        }
        guard !actions.isEmpty else { return nil }
        let config = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

class AnnouncementListCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: AccessIconView!
    @IBOutlet weak var titleLabel: UILabel!

    func update(topic: DiscussionTopic?, isTeacher: Bool, color: UIColor?) {
        iconImageView.icon = .announcementLine
        if isTeacher {
            iconImageView.published = topic?.published == true
        } else {
            iconImageView.state = nil
        }
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)

        titleLabel.setText(topic?.title, style: .textCellTitle)
        let dateText: String?

        if let delayed = topic?.delayedPostAt, delayed > Clock.now {
            iconImageView.icon = .calendarClockLine
            iconImageView.state = nil
            dateText = String.localizedStringWithFormat(NSLocalizedString("Delayed until %@", comment: ""), delayed.dateTimeString)
        } else if let replyAt = topic?.lastReplyAt {
            dateText = String.localizedStringWithFormat(NSLocalizedString("Last post %@", comment: ""), replyAt.dateTimeString)
        } else {
            dateText = topic?.postedAt?.dateTimeString
        }

        dateLabel.setText(dateText, style: .textCellSupportingText)

        accessibilityLabel = "\(titleLabel.text ?? "") \(dateLabel.text ?? "")"
    }
}
