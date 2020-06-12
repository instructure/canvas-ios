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
import WebKit

public class DiscussionDetailsViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {
    @IBOutlet weak var courseSectionsView: UIView!
    @IBOutlet weak var courseSectionsLabel: UILabel!
    @IBOutlet weak var dueSection: UIView!
    lazy var optionsButton = UIBarButtonItem(image: .icon(.more), style: .plain, target: self, action: #selector(showTopicOptions))
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var publishedIcon: UIImageView!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var publishedView: UIView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet public weak var sectionsStack: UIStackView!
    @IBOutlet weak var submissionsSection: UIView!
    public var titleSubtitleView = TitleSubtitleView.create()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewPlaceholder: UIView!
    var webView = CoreWebView()

    public var color: UIColor?
    var context: Context = ContextModel.currentUser
    let env = AppEnvironment.shared
    var isAnnouncementRoute = false
    var isAnnouncement: Bool { topic.first?.isAnnouncement ?? isAnnouncementRoute }
    var isReady = false
    var isRendered = false
    var keyboard: KeyboardTransitioning?
    var maxDepth: UInt = 3
    var readTimer: Timer?
    var showEntryID: String?
    var showRepliesToEntryID: String?
    var topicID = ""

    var assignment: Store<GetAssignment>?
    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var entries = env.subscribe(GetDiscussionView(context: context, topicID: topicID)) { [weak self] in
        self?.update()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var groups = context.contextType == .course ? env.subscribe(GetGroups(context: context)) { [weak self] in
        self?.update()
    } : nil
    lazy var permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .postToForum ])) { [weak self] in
        self?.update()
    }
    lazy var topic = env.subscribe(GetDiscussionTopic(context: context, topicID: topicID)) { [weak self] in
        self?.updateNavBar()
        self?.update()
    }
    func entry(_ entryID: String) -> DiscussionEntry? {
        env.database.viewContext.first(where: #keyPath(DiscussionEntry.id), equals: entryID)
    }

    public static func create(
        context: Context,
        topicID: String,
        isAnnouncement: Bool = false,
        showEntryID: String? = nil,
        showRepliesToEntryID: String? = nil
    ) -> DiscussionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.isAnnouncementRoute = isAnnouncement
        controller.showEntryID = showEntryID
        controller.showRepliesToEntryID = showRepliesToEntryID
        controller.topicID = topicID
        // needs to be set early for helm to correctly place done button
        controller.navigationItem.rightBarButtonItem = controller.optionsButton
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: isAnnouncement
            ? NSLocalizedString("Announcement Details", bundle: .core, comment: "")
            : NSLocalizedString("Discussion Details", bundle: .core, comment: "")
        )
        courseSectionsView.isHidden = true

        optionsButton.accessibilityLabel = NSLocalizedString("Options", bundle: .core, comment: "")
        optionsButton.isEnabled = false

        pointsView.isHidden = true
        publishedView.isHidden = true

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        titleLabel.text = nil

        // Can't put in storyboard because that breaks cookie sharing
        // & discussion view is cached without verifiers on images
        webViewPlaceholder.addSubview(webView)
        webView.pin(inside: webViewPlaceholder)
        webView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        webView.autoresizesHeight = true // will update the height constraint
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceVertical = false
        webView.backgroundColor = .named(.backgroundLightest)
        webView.linkDelegate = self
        webView.addScript(DiscussionHTML.preact)
        webView.addScript(DiscussionHTML.js)
        webView.handle("like") { [weak self] message in self?.handleLike(message) }
        webView.handle("moreOptions") { [weak self] message in self?.handleMoreOptions(message) }
        webView.handle("ready") { [weak self] _ in self?.ready() }
        webView.loadHTMLString(
            "<style>\(DiscussionHTML.css)</style>",
            baseURL: env.api.baseURL.appendingPathComponent("\(context.pathComponent)/discussion_topics/\(topicID)")
        )

        if showRepliesToEntryID != nil {
            titleSubtitleView.title = isAnnouncement
                ? NSLocalizedString("Announcement Replies", bundle: .core, comment: "")
                : NSLocalizedString("Discussion Replies", bundle: .core, comment: "")
            navigationItem.rightBarButtonItem = nil
        }

        colors.refresh()
        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        topic.refresh()
        entries.refresh()
        permissions.refresh()
        groups?.exhaust(force: false)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
        env.pageViewLogger.startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "\(context.pathComponent)/\(isAnnouncement ? "announcements" : "discussion_topics")/\(topicID)", attributes: [:])
    }

    deinit {
        if showRepliesToEntryID == nil {
            AppStoreReview.handleNavigateFromAssignment()
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let depth: UInt = view.traitCollection.horizontalSizeClass == .compact ? 2 : 4
        if maxDepth != depth {
            maxDepth = depth
            render()
        }
    }

    func updateNavBar() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }
        spinnerView.color = color
        refreshControl.color = color
        titleSubtitleView.title = showRepliesToEntryID != nil ? (
            isAnnouncement
                ? NSLocalizedString("Announcement Replies", bundle: .core, comment: "")
                : NSLocalizedString("Discussion Replies", bundle: .core, comment: "")
        ) : (
            isAnnouncement
                ? NSLocalizedString("Announcement Details", bundle: .core, comment: "")
                : NSLocalizedString("Discussion Details", bundle: .core, comment: "")
        )
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        guard fixStudentGroupTopic() else { return }
        let courseID = context.contextType == .group ? group.first?.courseID : context.id
        if assignment?.useCase.assignmentID != topic.first?.assignmentID, let courseID = courseID {
            assignment = topic.first?.assignmentID.map {
                env.subscribe(GetAssignment(courseID: courseID, assignmentID: $0)) { [weak self] in
                    self?.update()
                }
            }
            assignment?.refresh()
        }

        if let sections = topic.first?.sections, topic.first?.isSectionSpecific == true {
            courseSectionsLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("Sections: %@", bundle: .core, comment: ""),
                ListFormatter.localizedString(from: sections.map { $0.name })
            )
            courseSectionsView.isHidden = false
        } else {
            courseSectionsView.isHidden = true
        }

        optionsButton.isEnabled = topic.first != nil

        let pending = topic.pending || entries.pending
        let error = topic.error ?? entries.error
        spinnerView.isHidden = !pending || (!topic.isEmpty && !entries.isEmpty) || error != nil || refreshControl.isRefreshing

        titleLabel.text = topic.first?.title
        pointsLabel.text = assignment?.first?.pointsPossibleText
        pointsView.isHidden = assignment?.first?.pointsPossible == nil || showRepliesToEntryID != nil

        let isPublished = topic.first?.published == true
        publishedIcon.image = .icon(isPublished ? .publish : .no, .solid)
        publishedIcon.tintColor = .named(isPublished ? .textSuccess : .textDark)
        publishedLabel.text = isPublished
            ? NSLocalizedString("Published", bundle: .core, comment: "")
            : NSLocalizedString("Unpublished", bundle: .core, comment: "")
        publishedLabel.textColor = .named(isPublished ? .textSuccess : .textDark)
        publishedView.isHidden = env.app != .teacher || isAnnouncement || showRepliesToEntryID != nil

        if env.app == .teacher, let courseID = courseID, let assignmentID = topic.first?.assignmentID {
            if dueSection.isHidden {
                let controller = AssignmentDatesViewController.create(
                    courseID: courseID,
                    assignmentID: assignmentID
                )
                embed(controller, in: dueSection)
                dueSection.isHidden = false
            }

            if topic.first?.groupTopicChildren == nil, submissionsSection.isHidden {
                let controller = SubmissionBreakdownViewController.create(
                    courseID: courseID,
                    assignmentID: assignmentID,
                    submissionTypes: [.discussion_topic]
                )
                embed(controller, in: submissionsSection)
                submissionsSection.isHidden = false
            }
        }

        render()
    }

    @objc func refresh() {
        if context.contextType == .course {
            course.refresh(force: true)
        } else {
            group.refresh(force: true)
        }
        topic.refresh(force: true)
        entries.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        assignment?.refresh(force: true)
        permissions.refresh(force: true)
    }

    var canLike: Bool {
        topic.first?.allowRating == true && (
            topic.first?.onlyGradersCanRate != true ||
            course.first?.enrollments?.contains { $0.isTeacher || $0.isTA } == true
        )
    }

    // If a topic has children, & current user is a student,
    // they should see their child group topic, not this course one
    func fixStudentGroupTopic() -> Bool {
        guard
            env.app == .student, context.contextType == .course,
            let topic = topic.first, topic.groupCategoryID != nil,
            let subs = topic.groupTopicChildren
        else { return true }
        if let groupID = groups?.first(where: { subs[$0.id] != nil })?.id, let childID = subs[groupID] {
            context = ContextModel(.group, id: groupID)
            topicID = childID
            isReady = false
            isRendered = false
            webView.loadHTMLString(
                "<style>\(DiscussionHTML.css)</style>",
                baseURL: env.api.baseURL.appendingPathComponent("\(context.pathComponent)/discussion_topics/\(topicID)")
            )
            entries = env.subscribe(GetDiscussionView(context: context, topicID: topicID)) { [weak self] in
                self?.update()
            }
            group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
                self?.updateNavBar()
            }
            groups = nil
            permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .postToForum ])) { [weak self] in
                self?.update()
            }
            self.topic = env.subscribe(GetDiscussionTopic(context: context, topicID: topicID)) { [weak self] in
                self?.update()
            }
            entries.refresh()
            group.refresh()
            permissions.refresh()
            self.topic.refresh()
        }
        return false
    }

    func ready() {
        isReady = true
        render()
    }

    func render() {
        guard isReady, let topic = topic.first, !entries.pending || !entries.isEmpty else { return }
        let script: String
        if let root = showRepliesToEntryID.flatMap({ entry($0) }) {
            script = DiscussionHTML.render(
                entry: root,
                in: topic,
                maxDepth: maxDepth,
                canLike: canLike
            )
        } else {
            var entries = self.entries.filter { $0.parentID == nil }
            if topic.sortByRating {
                entries.sort { $0.likeCount > $1.likeCount }
            }
            script = DiscussionHTML.render(
                topic: topic,
                entries: entries,
                maxDepth: maxDepth,
                canLike: canLike,
                groups: groups?.all,
                contextColor: color
            )
        }
        webView.evaluateJavaScript(script) { [weak self] (_, error) in
            if let error = error {
                print(error)
                self?.showError(error)
            } else {
                self?.rendered()
            }
        }
    }

    func rendered() {
        guard !isRendered else { return }
        isRendered = true
        if let entryID = showEntryID {
            showEntryID = nil
            webView.scrollIntoView(fragment: "entry-\(entryID)") { [weak self] isFound in
                guard !isFound, let self = self else { return }
                let controller = DiscussionDetailsViewController.create(
                    context: self.context,
                    topicID: self.topicID,
                    isAnnouncement: self.isAnnouncement,
                    showRepliesToEntryID: entryID
                )
                self.env.router.show(controller, from: self)
            }
        }
        if showRepliesToEntryID == nil {
            AppStoreReview.handleNavigateToAssignment()
            if !ExperimentalFeature.studentModules.isEnabled, env.app == .student {
                MarkDiscussionTopicRead(context: context, topicID: topicID, isRead: true).fetch()
            }
        }
        scrollViewDidScroll(scrollView) // read initial
    }
}

extension DiscussionDetailsViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        readTimer?.invalidate()
        readTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.readVisibleEntries()
        }
    }

    func readVisibleEntries() {
        let visible = scrollView.convert(scrollView.bounds, to: webView)
        // Get all ids of messages that have at least 18px visible
        // (or all of it is visible if it's smaller than 18px)
        webView.evaluateJavaScript("""
        Array.from(document.querySelectorAll('[id^=message-]')).filter(message => {
            const { top: minY, bottom: maxY, height } = message.getBoundingClientRect()
            return (Math.min(\(visible.maxY), maxY) - Math.max(\(visible.minY), minY)) >= Math.min(height, 18)
        }).map(message => message.id.split('-').pop())
        """) { [weak self] ids, _ in
            guard let ids = ids as? [String] else { return }
            self?.readEntries(ids: ids)
        }
    }

    func readEntries(ids: [String]) {
        for entryID in ids {
            guard let e = entry(entryID), !e.isRead, !e.isForcedRead else { continue }
            MarkDiscussionEntryRead(
                context: context,
                topicID: topicID,
                entryID: entryID,
                isRead: true,
                isForcedRead: false
            ).fetch()
        }
    }
}

extension DiscussionDetailsViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        guard
            url.host == env.currentSession?.baseURL.host,
            url.path.hasPrefix("/\(context.pathComponent)/discussion_topics/\(topicID)/")
        else {
            env.router.route(to: url, from: self)
            return true
        }
        let path = Array(url.pathComponents.dropFirst(5))
        if path.count == 1, path[0] == "reply" {
            Analytics.shared.logEvent(isAnnouncement ? "announcement_replied" : "discussion_topic_replied")
            env.router.route(to: url, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            return true
        }
        if path.count == 3, path[0] == "entries", !path[1].isEmpty, path[2] == "replies" {
            env.router.route(to: url, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            return true
        }
        if path.count == 2, path[0] == "replies" {
            let controller = DiscussionDetailsViewController.create(
                context: context,
                topicID: topicID,
                isAnnouncement: isAnnouncement,
                showRepliesToEntryID: path[1]
            )
            env.router.show(controller, from: self)
            return true
        }
        env.router.route(to: url, from: self)
        return true
    }
}

extension DiscussionDetailsViewController {
    @objc func showTopicOptions() {
        guard let topic = topic.first else { return }

        let sheet = BottomSheetPickerViewController.create()
        if entries.contains(where: { $0.isRead == false }) {
            sheet.addAction(image: .icon(.check, .solid), title: NSLocalizedString("Mark All as Read", bundle: .core, comment: "")) { [weak self] in
                self?.markAllRead(isRead: true)
            }
        }
        if entries.contains(where: { $0.isRead == true }) {
            sheet.addAction(image: .icon(.no, .solid), title: NSLocalizedString("Mark All as Unread", bundle: .core, comment: "")) { [weak self] in
                self?.markAllRead(isRead: false)
            }
        }
        if topic.canUpdate {
            sheet.addAction(image: .icon(.edit), title: NSLocalizedString("Edit", bundle: .core, comment: "")) { [weak self] in
                self?.editTopic()
            }
        }
        if topic.canDelete {
            sheet.addAction(image: .icon(.trash), title: NSLocalizedString("Delete", bundle: .core, comment: "")) { [weak self] in
                self?.deleteTopic()
            }
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func editTopic() {
        let path = "\(context.pathComponent)/\(isAnnouncement ? "announcements" : "discussion_topics")/\(topicID)/edit"
        env.router.route(to: path, from: self, options: .modal(.formSheet, embedInNav: true))
    }

    func markAllRead(isRead: Bool) {
        MarkDiscussionEntriesRead(
            context: context,
            topicID: topicID,
            isRead: isRead,
            isForcedRead: true
        ).fetch { [weak self] _, _, error in performUIUpdate {
            guard let self = self else { return }
            if let error = error { return self.showError(error) }
            self.render()
        } }
    }

    func deleteTopic() {
        DeleteDiscussionTopic(context: context, topicID: topicID).fetch { [weak self] _, _, error in performUIUpdate {
            guard let self = self else { return }
            if let error = error { return self.showError(error) }
            self.env.router.dismiss(self)
        } }
    }
}

extension DiscussionDetailsViewController {
    private func handleLike(_ message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any],
            let entryID = body["entryID"] as? String,
            let isLiked = body["isLiked"] as? Bool
        else { return }
        like(entryID, isLiked: isLiked)
    }

    func like(_ entryID: String, isLiked: Bool) {
        updateActions(for: entryID, overrideLiked: isLiked)
        RateDiscussionEntry(
            context: context,
            topicID: topicID,
            entryID: entryID,
            isLiked: isLiked
        ).fetch { [weak self] _, _, error in performUIUpdate {
            if let error = error { self?.showError(error) }
            self?.updateActions(for: entryID)
        } }
    }

    func updateActions(for entryID: String, overrideLiked: Bool? = nil) {
        guard let entry = self.entry(entryID), let topic = topic.first else { return }
        webView.evaluateJavaScript(DiscussionHTML.rerenderActions(
            for: entry,
            in: topic,
            canLike: canLike,
            overrideLiked: overrideLiked
        ))
    }

    private func handleMoreOptions(_ message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any],
            let entryID = body["entryID"] as? String
        else { return }
        showMoreOptions(for: entryID)
    }

    func showMoreOptions(for entryID: String) {
        guard let entry = self.entry(entryID), let topic = topic.first else { return }
        let canEdit = env.app == .teacher || (
            !topic.lockedForUser &&
            entry.author?.id == env.currentSession?.userID
        )

        let sheet = BottomSheetPickerViewController.create()
        if entry.isRead == false {
            sheet.addAction(image: .icon(.check, .solid), title: NSLocalizedString("Mark as Read", bundle: .core, comment: "")) { [weak self] in
                self?.markRead(entryID, isRead: true)
            }
        } else {
            sheet.addAction(image: .icon(.no, .solid), title: NSLocalizedString("Mark as Unread", bundle: .core, comment: "")) { [weak self] in
                self?.markRead(entryID, isRead: false)
            }
        }
        if canEdit {
            sheet.addAction(image: .icon(.edit), title: NSLocalizedString("Edit", bundle: .core, comment: "")) { [weak self] in
                self?.editEntry(entryID)
            }
            sheet.addAction(image: .icon(.trash), title: NSLocalizedString("Delete", bundle: .core, comment: "")) { [weak self] in
                self?.deleteEntry(entryID)
            }
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func editEntry(_ entryID: String) {
        let entry = self.entry(entryID)
        let controller = DiscussionReplyViewController.create(context: context, topicID: topicID, replyToEntryID: entry?.parentID, editEntryID: entryID)
        env.router.show(controller, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
    }

    func markRead(_ entryID: String, isRead: Bool) {
        MarkDiscussionEntryRead(
            context: context,
            topicID: topicID,
            entryID: entryID,
            isRead: isRead,
            isForcedRead: true
        ).fetch()
    }

    func deleteEntry(_ entryID: String) {
        DeleteDiscussionEntry(
            context: context,
            topicID: topicID,
            entryID: entryID
        ).fetch { [weak self] _, _, error in
            if let error = error { self?.showError(error) }
        }
    }
}
