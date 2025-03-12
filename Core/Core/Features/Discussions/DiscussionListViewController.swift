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

public class DiscussionListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol, ErrorViewController {
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
    var selectedFirstTopic: Bool = false
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/discussion_topics"
    )

    public var hideQuantitativeData: Bool {
        return course?.first?.hideQuantitativeData ?? false
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = context.contextType == .course ? env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var group = context.contextType == .group ? env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var topics = env.subscribe(GetDiscussionTopics(context: context)) { [weak self] in
        self?.update()
    }

    private var offlineModeInteractor: OfflineModeInteractor?

    public static func create(context: Context, offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()) -> DiscussionListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: String(localized: "Discussions", bundle: .core))

        addButton.accessibilityLabel = String(localized: "Create Discussion", bundle: .core)
        addButton.accessibilityIdentifier = "DiscussionList.newButton"

        emptyMessageLabel.text = String(localized: "It looks like discussions haven’t been created in this space yet.", bundle: .core)
        emptyTitleLabel.text = String(localized: "No Discussions", bundle: .core)
        errorView.messageLabel.text = String(localized: "There was an error loading discussions. Pull to refresh to try again.", bundle: .core)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil
        refreshControl.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        tableView.backgroundColor = .backgroundLightest
        view.backgroundColor = .backgroundLightest

        colors.refresh()
        // We must force refresh because the GetCourses call deletes all existing Courses from the CoreData cache and since GetCourses response includes no permissions we lose that information.
        course?.refresh(force: true)
        group?.refresh(force: true)
        topics.exhaust()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        navigationController?.navigationBar.useContextColor(color)
    }

    @objc func refresh() {
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
        let canAdd = (course?.first?.canCreateDiscussionTopic ?? group?.first?.canCreateDiscussionTopic) == true
        navigationItem.rightBarButtonItem = canAdd ? addButton : nil
    }

    func update() {
        loadingView.isHidden = topics.state != .loading || refreshControl.isRefreshing
        emptyView.isHidden = topics.state != .empty
        errorView.isHidden = topics.state != .error
        tableView.reloadData()

        if !selectedFirstTopic, topics.state != .loading, let firstTopic = topics.first, let url = firstTopic.htmlURL {

            selectedFirstTopic = true
            if splitViewController?.isCollapsed == false, !isInSplitViewDetail {
                if firstTopic.anonymousState != nil {
                    let emptyViewController = EmptyViewController(nibName: nil, bundle: nil)
                    env.router.show(emptyViewController, from: self, options: .detail)
                    return
                }
                env.router.route(to: url, from: self, options: .detail)
            }
        }
    }

    @objc func add() {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            return UIAlertController.showItemNotAvailableInOfflineAlert()
        }

        env.router.route(
            to: "\(context.pathComponent)/discussion_topics/new",
            userInfo: [DiscussionsAssembly.SourceViewKey: self],
            from: self,
            options: .modal(isDismissable: false, embedInNav: true)
        )
    }

    func togglePinned(at indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
        guard let topic = topics[indexPath] else { return completionHandler(false) }
        let useCase = UpdateDiscussionTopic(context: context, topicID: topic.id, form: [
            .pinned: .bool(!topic.pinned)
        ])
        useCase.fetch { [weak self] result, _, error in performUIUpdate {
            if let error = error { self?.showError(error) }
            completionHandler(result != nil)
        } }
    }

    func toggleLocked(at indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
        guard let topic = topics[indexPath] else { return completionHandler(false) }
        let useCase = UpdateDiscussionTopic(context: context, topicID: topic.id, form: [
            .locked: .bool(!topic.locked)
        ])
        useCase.fetch { [weak self] result, _, error in performUIUpdate {
            if let error = error { self?.showError(error) }
            completionHandler(result != nil)
        } }
    }

    func deleteTopic(at indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
        guard let topicID = topics[indexPath]?.id else { return completionHandler(false) }
        let alert = UIAlertController(
            title: String(localized: "Delete Discussion", bundle: .core),
            message: String(localized: "Are you sure you would like to delete this discussion?", bundle: .core),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(String(localized: "Delete", bundle: .core), style: .destructive) { _ in
            let useCase = DeleteDiscussionTopic(context: self.context, topicID: topicID)
            useCase.fetch { [weak self] _, _, error in performUIUpdate {
                if let error = error { self?.showError(error) }
            } }
        })
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        env.router.show(alert, from: self, options: .modal())
        completionHandler(true)
    }
}

extension DiscussionListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return topics.numberOfSections
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch topics.sections?[section].name {
        case "0":
            return SectionHeaderView.create(title: String(localized: "Pinned Discussions", bundle: .core), section: section)
        case "1":
            return SectionHeaderView.create(title: String(localized: "Discussions", bundle: .core), section: section)
        case "2":
            return SectionHeaderView.create(title: String(localized: "Closed for Comments", bundle: .core), section: section)
        default:
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.sections?[section].numberOfObjects ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DiscussionListCell = tableView.dequeue(for: indexPath)
        let topic = topics[indexPath]
        cell.update(topic: topic, isTeacher: course?.first?.hasTeacherEnrollment == true, color: color)
        if topic?.anonymousState != nil && offlineModeInteractor?.isOfflineModeEnabled() == true {
            cell.selectionStyle = .none
            cell.contentView.alpha = 0.5
            cell.statusLabel.text = String(localized: "Not supported", bundle: .core)
            cell.statusLabel.isHidden = false
            cell.statusDot.isHidden = true
            cell.repliesLabel.isHidden = true
            cell.repliesDot.isHidden = true
            cell.unreadLabel.isHidden = true
            cell.unreadDot.isHidden = true
            cell.pointsLabel.isHidden = true
            cell.pointsDot.isHidden = true
            cell.dateLabel.isHidden = true
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
        }

        if hideQuantitativeData {
            cell.pointsLabel.isHidden = true
            cell.pointsDot.isHidden = true
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let htmlURL = topics[indexPath]?.htmlURL else { return }
        env.router.route(to: htmlURL, from: self, options: .detail)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        if topics[indexPath]?.canDelete == true {
            let action = UIContextualAction(style: .destructive, title: String(localized: "Delete", bundle: .core)) { [weak self] (_, _, handler) in
                self?.deleteTopic(at: indexPath, completionHandler: handler)
            }
            action.backgroundColor = .backgroundDanger
            actions.append(action)
        }
        if course?.first?.hasTeacherEnrollment == true {
            var title = topics[indexPath]?.locked == true ? String(localized: "Open", bundle: .core) : String(localized: "Close", bundle: .core)
            var action = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, handler) in
                self?.toggleLocked(at: indexPath, completionHandler: handler)
            }
            action.backgroundColor = .backgroundWarning
            actions.append(action)
            title = topics[indexPath]?.pinned == true ? String(localized: "Unpin", bundle: .core) : String(localized: "Pin", bundle: .core)
            action = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, handler) in
                self?.togglePinned(at: indexPath, completionHandler: handler)
            }
            action.backgroundColor = .backgroundInfo
            actions.append(action)
        }
        guard !actions.isEmpty else { return nil }
        let config = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

class DiscussionListCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: AccessIconView!
    @IBOutlet weak var pointsDot: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var repliesDot: UILabel!
    @IBOutlet weak var statusDot: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unreadDot: UIView!
    @IBOutlet weak var unreadLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        pointsDot.setText(pointsDot.text, style: .textCellBottomLabel)
        repliesDot.setText(repliesDot.text, style: .textCellBottomLabel)
        statusDot.setText(statusDot.text, style: .textCellBottomLabel)
        setupInstDisclosureIndicator()
    }

    func update(topic: DiscussionTopic?, isTeacher: Bool, color: UIColor?) {
        accessibilityIdentifier = "DiscussionListCell.\(topic?.id ?? "")"
        iconImageView.icon = topic?.assignmentID == nil ? .discussionLine : .assignmentLine
        if isTeacher {
            iconImageView.published = topic?.published == true
        } else {
            iconImageView.state = nil
        }
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)

        titleLabel.setText(topic?.title, style: .textCellTitle)

        statusDot.isHidden = true
        statusLabel.isHidden = true
        let dateText: String?

        if topic?.assignment?.dueAt == nil, let replyAt = topic?.lastReplyAt {
            dateText = String.localizedStringWithFormat(String(localized: "Last post %@", bundle: .core), replyAt.dateTimeString)
        } else if isTeacher, topic?.assignment?.dueAt != nil, topic?.assignment?.hasOverrides == true {
            dateText = String(localized: "Multiple Due Dates", bundle: .core)
        } else if topic?.assignment?.dueAt != nil, let lockAt = topic?.assignment?.lockAt, lockAt < Clock.now {
            dateText = topic?.assignment?.dueText
            statusLabel.text = String(localized: "Closed", bundle: .core)
            statusLabel.isHidden = false
            statusDot.isHidden = false
        } else {
            dateText = topic?.assignment?.dueText
        }

        dateLabel.setText(dateText, style: .textCellSupportingText)
        pointsLabel.setText(topic?.assignment?.pointsPossibleText, style: .textCellBottomLabel)
        pointsLabel.isHidden = topic?.assignment?.pointsPossible == nil
        pointsDot.isHidden = topic?.assignment?.pointsPossible == nil

        repliesLabel.setText(topic?.nRepliesString, style: .textCellBottomLabel)
        unreadLabel.setText(topic?.nUnreadString, style: .textCellBottomLabel)
        unreadDot.isHidden = topic?.unreadCount == 0
        unreadDot.backgroundColor = .backgroundInfo

        accessibilityIdentifier = "DiscussionListCell.\(topic?.id ?? "")"
        accessibilityLabel = [titleLabel.text, statusLabel.text, dateLabel.text, pointsLabel.text, repliesLabel.text, unreadLabel.text].compactMap { $0 }.joined(separator: " ")
    }

    override func prepareForReuse() {
        contentView.alpha = 1.0
        repliesLabel.isHidden = false
        repliesDot.isHidden = false
        unreadLabel.isHidden = false
        unreadDot.isHidden = false
        dateLabel.isHidden = false
        isUserInteractionEnabled = true
    }
}
