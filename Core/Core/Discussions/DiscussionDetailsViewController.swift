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

import Foundation
import UIKit
import WebKit

public class DiscussionDetailsViewController: UIViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate, ErrorViewController {
    lazy var optionsButton = UIBarButtonItem(image: .icon(.more), style: .plain, target: self, action: #selector(showTopicOptions))
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var publishedIcon: UIImageView!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var publishedView: UIView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var spinnerView: CircleProgressView!
    public var titleSubtitleView = TitleSubtitleView.create()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewPlaceholder: UIView!
    var webView = CoreWebView()

    public var color: UIColor?
    var context: Context = ContextModel.currentUser
    let env = AppEnvironment.shared
    var isAnnouncementRoute = false
    var isAnnouncement: Bool { topic.first?.isAnnouncement ?? isAnnouncementRoute }
    var keyboard: KeyboardTransitioning?
    var maxDepth = 3
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

    public static func create(context: Context, topicID: String, isAnnouncement: Bool = false) -> DiscussionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.isAnnouncementRoute = isAnnouncement
        controller.topicID = topicID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: isAnnouncement
            ? NSLocalizedString("Announcement Details", bundle: .core, comment: "")
            : NSLocalizedString("Discussion Details", bundle: .core, comment: "")
        )

        optionsButton.accessibilityLabel = NSLocalizedString("Options", bundle: .core, comment: "")
        optionsButton.isEnabled = false
        navigationItem.rightBarButtonItem = optionsButton

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
        webView.backgroundColor = .named(.backgroundLightest)
        webView.linkDelegate = self
        webView.addScript(Self.js)
        webView.handle("like") { [weak self] message in self?.handleLike(message) }
        webView.handle("moreOptions") { [weak self] message in self?.handleMoreOptions(message) }
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceVertical = false

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

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let depth = view.traitCollection.horizontalSizeClass == .compact ? 2 : 4
        if maxDepth != depth {
            maxDepth = depth
            loadHTML()
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
        titleSubtitleView.title = isAnnouncement
            ? NSLocalizedString("Announcement Details", bundle: .core, comment: "")
            : NSLocalizedString("Discussion Details", bundle: .core, comment: "")
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        guard fixStudentGroupTopic() else { return }
        if assignment?.useCase.assignmentID != topic.first?.assignmentID,
            let courseID = context.contextType == .group ? group.first?.courseID : context.id {
            assignment = topic.first?.assignmentID.map {
                env.subscribe(GetAssignment(courseID: courseID, assignmentID: $0)) { [weak self] in
                    self?.update()
                }
            }
            assignment?.refresh()
        }

        optionsButton.isEnabled = topic.first != nil

        let pending = topic.pending || entries.pending
        let error = topic.error ?? entries.error
        spinnerView.isHidden = !pending || (!topic.isEmpty && !entries.isEmpty) || error != nil || refreshControl.isRefreshing

        titleLabel.text = topic.first?.title
        pointsLabel.text = assignment?.first?.pointsPossibleText
        pointsView.isHidden = assignment?.first?.pointsPossible == nil

        if topic.first?.published == true {
            publishedIcon.image = .icon(.publish, .solid)
            publishedIcon.tintColor = .named(.textSuccess)
            publishedLabel.text = NSLocalizedString("Published", bundle: .core, comment: "")
            publishedLabel.textColor = .named(.textSuccess)
        } else {
            publishedIcon.image = .icon(.no, .solid)
            publishedIcon.tintColor = .named(.textDark)
            publishedLabel.text = NSLocalizedString("Unpublished", bundle: .core, comment: "")
            publishedLabel.textColor = .named(.textDark)
        }
        publishedView.isHidden = env.app != .teacher || isAnnouncement

        loadHTML()
    }

    @objc func refresh() {
        topic.refresh(force: true)
        entries.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        assignment?.refresh(force: true)
        permissions.refresh(force: true)
    }

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
            guard let entry = self.entry(path[1]) else { return true }
            let controller = CoreWebViewController()
            let titleView = TitleSubtitleView.create()
            titleView.title = isAnnouncement
                ? NSLocalizedString("Announcement Replies", bundle: .core, comment: "")
                : NSLocalizedString("Discussion Replies", bundle: .core, comment: "")
            titleView.subtitle = titleSubtitleView.subtitle
            controller.navigationItem.titleView = titleView
            controller.webView.linkDelegate = self
            controller.webView.addScript(Self.js)
            controller.webView.handle("like") { [weak self] message in self?.handleLike(message) }
            controller.webView.handle("moreOptions") { [weak self] message in self?.handleMoreOptions(message) }
            let html = controller.webView.html(for: """
                <style>\(Self.css)</style>
                \(entryHTML(entry, depth: 0))
            """)
            controller.webView.loadHTMLString(html, baseURL: topic.first?.htmlURL)
            env.router.show(controller, from: self)
            return true
        }
        env.router.route(to: url, from: self)
        return true
    }

    var canRate: Bool {
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

    var isLoaded = false
    func loaded() {
        guard !isLoaded else { return }
        isLoaded = true
        // AppStoreReview.handleNavigateToAssignment()
        MarkDiscussionTopicRead(context: context, topicID: topicID, isRead: true).fetch()
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
            self.loadHTML()
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
        guard let entry = self.entry(entryID) else { return }
        webView.evaluateJavaScript("""
        document.getElementById('actions-\(entryID)').outerHTML =
        \(CoreWebView.jsString(entryButtonsHTML(entry, overrideLiked: overrideLiked)))
        """)
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

extension DiscussionDetailsViewController {
    // shortcuts to encode text for html
    static func t(_ text: String?) -> String { CoreWebView.htmlString(text) }
    func t(_ text: String?) -> String { CoreWebView.htmlString(text) }

    func loadHTML() {
        guard let topic = topic.first, !entries.pending || !entries.isEmpty else { return }
        var entries = self.entries.filter { $0.parentID == nil }
        if topic.sortByRating {
            entries.sort { $0.likeCount > $1.likeCount }
        }
        webView.loadHTMLString(webView.html(for: """
            \(Self.topicHTML(topic))
            \(topicReplyButton)
            \(groupTopicChildrenList(topic))
            \(entries.isEmpty ? "" : """
            <h2 class="\(Styles.heading)">
                \(t(NSLocalizedString("Replies", bundle: .core, comment: "")))
            </h2>
            """)
            \(entries.map { entryHTML($0, depth: 0) } .joined(separator: "\n"))
            """
        ), baseURL: topic.htmlURL)
        loaded()
    }

    public static func topicHTML(_ topic: DiscussionTopic) -> String {
        return """
        <style>\(css)</style>
        \(entryHeader(author: topic.author, date: topic.postedAt, attachment: topic.attachments?.first, isTopic: true))
        \(topic.message ?? "")
        """
    }

    static func entryHeader(author: DiscussionParticipant?, date: Date?, attachment: File?, isTopic: Bool) -> String {
        guard author != nil || date != nil || attachment != nil else { return "" }
        return """
        <div class="\(Styles.entryHeader)\(isTopic ? " \(Styles.topicHeader)" : "")">
            \(avatarLink(for: author, isTopic: isTopic))
            <div style="flex:1">
                \(author.map { """
                    <div class="\(Styles.authorName)" aria-hidden="true">
                        \(t($0.displayName))
                    </div>
                """ } ?? "")
                \(date.map { """
                    <div class="\(Styles.date)">\(t($0.dateTimeString))</div>
                """ } ?? "")
            </div>
            \(attachment.map { """
                <a class="\(Styles.blockLink)" href="\(t($0.url?.absoluteString))" aria-label="\(t($0.displayName))">
                    \(paperclipIcon)
                </a>
            """ } ?? "")
        </div>
        """
    }

    static func avatarLink(for author: DiscussionParticipant?, isTopic: Bool) -> String {
        guard let author = author else { return "" }
        var classes = "\(Styles.avatar)"
        if isTopic { classes += " \(Styles.avatarTopic)" }
        var style = ""
        var content = ""
        if let url = AvatarView.scrubbedURL(author.avatarURL)?.absoluteString {
            style += "style=\"background-image:url(\(t(url)))\""
        } else {
            content = t(AvatarView.initials(for: author.name))
            classes += " \(Styles.avatarInitials)"
        }
        return """
        <a class="\(Styles.blockLink)" href="../users/\(author.id)" aria-label="\(t(author.displayName))">
            <div aria-hidden="true" class="\(classes)" \(style)>\(content)</div>
        </a>
        """
    }

    var topicReplyButton: String {
        guard topic.first?.lockedForUser == false, permissions.first?.postToForum == true else { return "" }
        return """
        <div style="display:flex; margin:24px 0 16px 0;">
            <a style="\(Styles.font(.semibold, 16))text-decoration:none" href="\(t(topicID))/reply">
                \(t(NSLocalizedString("Reply", bundle: .core, comment: "")))
            </a>
        </div>
        """
    }

    func groupTopicChildrenList(_ topic: DiscussionTopic) -> String {
        guard let children = topic.groupTopicChildren, !children.isEmpty, let color = color?.hexString else { return "" }
        return """
        <div class="\(Styles.divider)"></div>
        <div class="\(Styles.groupTopicChildren)" style="background:\(color)33">
            <p>\(t(NSLocalizedString(
                "Since this is a group discussion, each group has its own conversation for this topic. Here are the discussions you have access to.",
                bundle: .core, comment: ""
            )))</p>
            \(groups?.map { (group: Group) -> String in
                guard let topicID = children[group.id] else { return "" }
                return """
                <a href="/groups/\(t(group.id))/discussion_topics/\(t(topicID))" class="\(Styles.groupTopicChild)">
                    <span style="flex:1">\(t(group.name))</span>
                    \(Self.disclosureIcon)
                </a>
                """
            } .joined(separator: "\n") ?? "")
        </div>
        """
    }

    static func singleEntryHTML(_ entry: DiscussionEntry) -> String {
        return """
        <style>\(css)</style>
        <div class="\(Styles.entry)">
            \(entryHeader(author: entry.author, date: entry.updatedAt, attachment: entry.isRemoved ? nil : entry.attachment, isTopic: true))
            \(messageHTML(entry))
        </div>
        """
    }

    func entryHTML(_ entry: DiscussionEntry, depth: UInt) -> String {
        return """
        <div id="entry-\(t(entry.id))" class="\(Styles.entry)">
            \(entry.isRead ? "" : """
            <div class="\(Styles.unread)" style="
            ">
                \(t(NSLocalizedString("Unread", bundle: .core, comment: "")))
            </div>
            """)
            \(Self.entryHeader(author: entry.author, date: entry.updatedAt, attachment: entry.isRemoved ? nil : entry.attachment, isTopic: false))
            <div class="\(Styles.entryContent)">
                \(Self.messageHTML(entry))
                \(entryButtonsHTML(entry))
                \(viewMoreRepliesLink(entry, depth: depth))
                \((!entry.replies.isEmpty && depth < maxDepth) ? entry.replies.map {
                    entryHTML($0, depth: depth + 1)
                } .joined(separator: "\n") : "")
            </div>
        </div>
        """
    }

    static func messageHTML(_ entry: DiscussionEntry) -> String {
        if !entry.isRemoved { return entry.message ?? "" }
        return """
        <p class="\(Styles.deleted)">
            \(t(NSLocalizedString("Deleted this reply.", bundle: .core, comment: "")))
        </p>
        """
    }

    func entryButtonsHTML(_ entry: DiscussionEntry, overrideLiked: Bool? = nil) -> String {
        guard !entry.isRemoved else { return "" }
        var actions = ""
        if topic.first?.lockedForUser == false, permissions.first?.postToForum == true {
            actions = """
            <a href="\(t(topicID))/entries/\(t(entry.id))/replies" class="\(Styles.reply)">
                \(t(NSLocalizedString("Reply", bundle: .core, comment: "")))
            </a>
            <div class="\(Styles.replyPipe)"></div>
            """
        }
        actions += """
        <button
            data-entry="\(t(entry.id))"
            class="\(Styles.moreOptions)"
            aria-label="\(t(NSLocalizedString("Show more options", bundle: .core, comment: "")))"
        >
            <svg xmlns="http://www.w3.org/2000/svg" class="\(Styles.icon)" aria-hidden="true">
                <circle r="2" cx="2" cy="10" />
                <circle r="2" cx="10" cy="10" />
                <circle r="2" cx="18" cy="10" />
            </svg>
        </button>
        """

        let rating: String
        if topic.first?.allowRating != true {
            rating = ""
        } else if canRate {
            let isLiked = overrideLiked ?? entry.isLikedByMe
            let count = entry.likeCount <= 0 ? "" : String.localizedStringWithFormat(
                NSLocalizedString("(%d)", bundle: .core, comment: "number of likes next to the like button"),
                entry.likeCount
            )
            rating = """
            <div class="\(Styles.like)\(isLiked ? " \(Styles.liked)" : "")">
                <span class="\(Styles.screenreader)">
                    \(t(entry.likeCount > 0 ? entry.likeCountText : ""))
                </span>
                <span aria-hidden="true">\(t(count))</span>
                <label class="\(Styles.likeIcon)">
                    <input
                        type="checkbox"
                        data-entry="\(t(entry.id))"
                        class="\(Styles.hiddenCheck)"
                        aria-label="\(t(NSLocalizedString("Like", bundle: .core, comment: "like action")))"
                        \(isLiked ? "checked" : "")
                    />
                    \(isLiked ? Self.likeSolidIcon : Self.likeLineIcon)
                </label>
            </div>
            """
        } else {
            rating = "<div>\(t(entry.likeCount > 0 ? entry.likeCountText : ""))</div>"
        }

        return """
        <div id="actions-\(entry.id)" class="\(Styles.actions)">
            \(actions)
            <span style="flex:1"></span>
            \(rating)
        </div>
        """
    }

    func viewMoreRepliesLink(_ entry: DiscussionEntry, depth: UInt) -> String {
        guard depth >= maxDepth, !entry.replies.isEmpty else { return "" }
        return """
        <a href="\(t(topicID))/replies/\(t(entry.id))" class="\(Styles.moreReplies)">
            \(t(NSLocalizedString("View more replies", bundle: .core, comment: "")))
        </a>
        """
    }

    static let js = """
    document.addEventListener('input', event => {
        const input = event.target.closest(".\(Styles.hiddenCheck)")
        const entryID = input && input.dataset.entry
        if (!entryID) { return }
        window.webkit.messageHandlers.like.postMessage({ entryID, isLiked: input.checked })
    })
    document.addEventListener('click', event => {
        const button = event.target.closest(".\(Styles.moreOptions)")
        const entryID = button && button.dataset.entry
        if (!entryID) { return }
        const { x, y, width, height } = button.getBoundingClientRect()
        const rect = { x: x + scrollX, y: y + scrollY, width, height }
        window.webkit.messageHandlers.moreOptions.postMessage({ entryID, rect })
    })
    """

    static let paperclipIcon = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" class="\(Styles.icon)" aria-hidden="true">
    <path d="
        M1752.77 221.1C1532.65 1 1174.28 1 954.17 221.1l-838.6 838.6c-154.05 154.16-154.05 404.9 0 558.94
        149.54 149.42 409.98 149.31 559.06 0l758.74-758.62c87.98-88.1 87.98-231.42 0-319.51-88.32-88.21
        -231.64-87.98-319.51 0l-638.8 638.9 79.85 79.85 638.8-638.9c43.93-43.83 115.54-43.94 159.81 0
        43.93 44.04 43.93 115.87 0 159.8L594.78 1538.8c-110.23 110.12-289.35 110-399.36 0-110.12-110.11-110
        -289.24 0-399.24l838.59-838.6c175.96-175.95 462.38-176.18 638.9 0 176.08 176.2 176.08 462.84 0
        638.92l-798.6 798.72 79.85 79.85 798.6-798.72c220.02-220.13 220.02-578.49 0-798.61"/>
    </svg>
    """

    static let likeLineIcon = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" class="\(Styles.icon)" aria-hidden="true">
    <path d="
        M1637.176 1129.412h-112.94v112.94c62.23 0 112.94 50.599 112.94 112.942 0 62.344-50.71
        112.941-112.94 112.941h-112.942v112.941c62.23 0 112.941 50.598 112.941 112.942 0
        62.343-50.71 112.94-112.94 112.94h-960c-155.634 0-282.354-126.606-282.354-282.352
        V903.529h106.617c140.16 0 274.334-57.6 368.3-157.778C778.486 602.089 937.28 379.256
        957.385 112.94h36.367c50.484 0 98.033 22.363 130.334 61.44 32.64 39.53 45.854 91.144
        36.14 141.515-22.7 118.589-60.197 236.048-111.246 349.102-23.83 52.517-19.313 112.602
        11.746 160.94 31.397 48.566 84.706 77.591 142.644 77.591h433.807c62.231 0 112.942 50.598
        112.942 112.942 0 62.343-50.71 112.94-112.942 112.94m225.883-112.94c0-124.575-101.308
        -225.883-225.883-225.883H1203.37c-19.651 0-37.044-9.374-47.66-25.863-10.391-16.15-11.86
        -35.577-3.84-53.196 54.663-121.073 94.87-247.115 119.378-374.513 15.925-83.576-5.873
        -169.072-60.085-234.578C1157.29 37.384 1078.005 0 993.751 0H846.588v56.47c0 254.457
        -155.068 473.224-285.063 612.029-72.734 77.477-176.98 122.09-285.967 122.09H56v734.117
        C56 1742.682 233.318 1920 451.294 1920h960c124.574 0 225.882-101.308 225.882-225.882
        0-46.42-14.117-89.676-38.174-125.59 87.869-30.947 151.116-114.862 151.116-213.234 0-46.419
        -14.118-89.675-38.174-125.59 87.868-30.946 151.115-114.862 151.115-213.233"/>
    </svg>
    """

    static let likeSolidIcon = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" class="\(Styles.icon)" aria-hidden="true">
    <path d="
        M1863.059 1016.47c0-124.574-101.308-225.882-225.883-225.882H1203.37c-19.651 0-37.044-9.374
        -47.66-25.863-10.391-16.15-11.86-35.577-3.84-53.196 54.776-121.073 94.87-247.115 119.378
        -374.513 15.925-83.576-5.873-169.072-60.085-234.578C1157.29 37.384 1078.005 0 993.751 0
        H846.588v56.47c0 254.457-155.068 473.224-285.063 612.029-72.734 77.477-176.98 122.09
        -285.967 122.09H56v734.117C56 1742.682 233.318 1920 451.294 1920h960c124.574 0 225.882
        -101.308 225.882-225.882 0-46.42-14.117-89.676-38.174-125.59 87.869-30.947 151.116-114.862
        151.116-213.234 0-46.419-14.118-89.675-38.174-125.59 87.868-30.946 151.115-114.862 151.115
        -213.233"/>
    </svg>
    """

    static let disclosureIcon = """
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" aria-hidden="true">
    <path fill="currentColor" d="M8 7L9.5 5.5L16 12L9.5 18.5L8 17L13 12L8 7Z"/>
    </svg>
    """

    enum Styles: Int, CustomStringConvertible {
        case authorName, date, entryHeader, topicHeader
        case avatar, avatarInitials, avatarTopic
        case groupTopicChild, groupTopicChildren
        case deleted, entry, entryContent, moreReplies, unread
        case actions, like, liked, likeIcon, moreOptions, reply, replyPipe
        case blockLink, divider, heading, hiddenCheck, icon, mirrorRTL, screenreader

        var description: String { "-i\(String(rawValue, radix: 36))" }

        static func color(_ path: KeyPath<Brand, UIColor>) -> String {
            Brand.shared[keyPath: path].hexString
        }
        static func color(_ name: InstColorName) -> String {
            UIColor.named(name).hexString
        }

        enum Weight: String {
            case regular = "400"
            case medium = "500"
            case semibold = "600"
            case bold = "700"
        }
        static func font(_ weight: Weight, _ size: CGFloat) -> String {
            "font-weight:\(weight.rawValue);font-size:\(size / 16)rem;"
        }
    }

    static let css = """
    body {
        \(Styles.font(.medium, 14))
        --max-lines: none;
    }

    .\(Styles.authorName) {
        color: \(Styles.color(.textDarkest));
        \(Styles.font(.semibold, 14))
        --max-lines: 2;
    }
    .\(Styles.date) {
        color: \(Styles.color(.textDark));
        \(Styles.font(.semibold, 12))
        margin-top: 2px;
        --max-lines: 2;
    }
    \(""/* 2 lines then ellipsis */)
    .\(Styles.authorName),
    .\(Styles.date) {
        overflow: hidden;
        word-break: break-all;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        -webkit-line-clamp: var(--max-lines);
    }
    .\(Styles.entryHeader) {
        align-items: center;
        display: flex;
        margin: 12px 0;
    }
    .\(Styles.topicHeader) {
        margin: 16px 0;
    }

    .\(Styles.avatar) {
        background: \(Styles.color(.backgroundLightest));
        background-size: cover;
        border-radius: 50%;
        box-sizing: border-box;
        color: \(Styles.color(.textDark));
        font-size: 14px;
        font-weight: 600;
        height: 32px;
        line-height: 32px;
        -webkit-margin-end: 8px;
        text-align: center;
        width: 32px;
    }
    .\(Styles.avatarInitials) {
        border: 1px solid \(Styles.color(.borderMedium));
        overflow: hidden;
    }
    .\(Styles.avatarTopic) {
        font-size: 18px;
        height: 40px;
        line-height: 40px;
        -webkit-margin-end: 12px;
        -webkit-margin-start: -2px;
        width: 40px;
    }

    .\(Styles.groupTopicChildren) {
        border-radius: 8px;
        display: flex;
        flex-flow: column;
        margin: 12px 0;
        padding-bottom: 12px;
    }
    .\(Styles.groupTopicChildren) > p {
        \(Styles.font(.medium, 14))
        margin: 12px;
    }
    .\(Styles.groupTopicChild) {
        color: \(Styles.color(.textDarkest));
        \(Styles.font(.semibold, 16))
        display: flex;
        margin: 12px 8px 12px 12px;
        text-decoration: none;
    }

    .\(Styles.deleted) {
        color: \(Styles.color(.textDark));
        font-style: italic;
    }
    .\(Styles.entry) {
        margin: 12px 0;
        position: relative;
    }
    .\(Styles.entry)::before {
        bottom: -8px;
        border-left: 1px solid \(Styles.color(.borderMedium));
        content: "";
        display: block;
        margin: 0 16px;
        position: absolute;
        top: 40px;
    }
    .\(Styles.entry):last-child::before {
        content: none;
    }
    .\(Styles.entryContent) {
        -webkit-margin-start: 40px;
    }
    .\(Styles.moreReplies) {
        background: none;
        border: 0.5px solid \(Styles.color(.borderMedium));
        border-radius: 4px;
        color: \(Styles.color(.textDark));
        display: block;
        font-size: 12px;
        margin: 12px 0;
        padding: 6px;
        text-align: center;
        text-decoration: none;
    }
    .\(Styles.unread) {
        background: \(Styles.color(.backgroundInfo));
        border-radius: 3px;
        color: \(Styles.color(.backgroundInfo));
        height: 6px;
        -webkit-margin-start: -8px;
        overflow: hidden;
        position: absolute;
        width: 6px;
    }

    .\(Styles.actions) {
        align-items: center;
        color: \(Styles.color(.textDark));
        display: flex;
        margin: 12px 0;
    }
    .\(Styles.like) {
        align-items: center;
        display: flex;
        margin: -2px 0;
    }
    .\(Styles.liked) {
        color: \(Styles.color(\.linkColor));
    }
    .\(Styles.likeIcon) {
        display: flex;
        -webkit-margin-start: 6px;
        position: relative;
    }
    .\(Styles.moreOptions) {
        background: none;
        border: 0 none;
        color: inherit;
        display: flex;
        margin: -2px 0;
        padding: 0;
    }
    .\(Styles.reply) {
        color: \(Styles.color(.textDark));
        text-decoration: none;
    }
    .\(Styles.replyPipe) {
        border-left: 1px solid \(Styles.color(.borderMedium));
        height: 16px;
        margin: 0 12px;
        width: 0;
    }

    .\(Styles.blockLink) {
        color: \(Styles.color(.textDark));
        display: flex;
        text-decoration: none;
    }
    .\(Styles.divider) {
        border-top: 0.3px solid \(Styles.color(.borderMedium));
        margin: 16px -16px;
    }
    .\(Styles.heading) {
        border-top: 0.3px solid \(Styles.color(.borderMedium));
        border-bottom: 0.3px solid \(Styles.color(.borderMedium));
        \(Styles.font(.bold, 20))
        margin: 16px -16px;
        padding: 16px 16px 8px 16px;
    }
    .\(Styles.hiddenCheck) {
        height: 100%;
        left: 0;
        margin: 0;
        opacity: 0.001;
        position: absolute;
        top: 0;
        width: 100%;
    }
    .\(Styles.icon) {
        fill: currentcolor;
        height: 20px;
        padding: 2px;
        width: 20px;
    }
    [dir=rtl] .\(Styles.mirrorRTL) {
        transform: scaleX(-1);
    }
    .\(Styles.screenreader) {
        clip-path: inset(50%);
        height: 1px;
        overflow: hidden;
        width: 1px;
    }
    """
        .replacingOccurrences(of: "\\s*([{}:;,])\\s*", with: "$1", options: .regularExpression)
}
