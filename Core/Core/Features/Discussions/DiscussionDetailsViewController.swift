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

public class DiscussionDetailsViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol, ErrorViewController {
    @IBOutlet weak var courseSectionsView: UIView!
    @IBOutlet weak var courseSectionsLabel: UILabel!
    @IBOutlet weak var dueSection: UIView!
    lazy var optionsButton = UIBarButtonItem(image: .moreLine, style: .plain, target: self, action: #selector(showTopicOptions))
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
    var context = Context.currentUser
    private(set) var env = AppEnvironment.shared
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
    private var newReplyIDFromCurrentUser: String?
    private var isContentLargerThanView: Bool { webView.scrollView.contentSize.height > view.frame.size.height }
    private var offlineModeInteractor: OfflineModeInteractor?
    private var offlineLoaded = false

    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/\(isAnnouncement ? "announcements" : "discussion_topics")/\(topicID)"
    )

    var assignment: Store<GetAssignment>?

    public var hideQuantitativeData: Bool {
        return assignment?.first?.hideQuantitativeData ?? false
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var entries = env.subscribe(GetDiscussionView(context: context, topicID: topicID)) { [weak self] in
        self?.newReplyIDFromCurrentUser = self?.findNewReplyIDFromCurrentUser()
        self?.update()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var groups = env.subscribe(GetGroups(context: groupsContext)) { [weak self] in
        self?.update()
    }
    lazy var permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .postToForum ])) { [weak self] in
        self?.update()
    }
    lazy var topic = env.subscribe(GetDiscussionTopic(context: context, topicID: topicID)) { [weak self] in
        self?.updateNavBar()
        self?.update()
    }
    var groupsContext: Context {
        if env.app == .teacher && context.contextType == .course {
            return .course(context.id)
        }
        return .currentUser
    }
    func entry(_ entryID: String) -> DiscussionEntry? {
        env.database.viewContext.first(where: #keyPath(DiscussionEntry.id), equals: entryID)
    }

    public static func create(
        context: Context,
        topicID: String,
        isAnnouncement: Bool = false,
        showEntryID: String? = nil,
        showRepliesToEntryID: String? = nil,
        offlineModeInteractor: OfflineModeInteractor? = OfflineModeAssembly.make(),
        env: AppEnvironment
    ) -> DiscussionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.isAnnouncementRoute = isAnnouncement
        controller.showEntryID = showEntryID
        controller.showRepliesToEntryID = showRepliesToEntryID
        controller.topicID = topicID
        controller.offlineModeInteractor = offlineModeInteractor
        // needs to be set early for helm to correctly place done button
        controller.navigationItem.rightBarButtonItem = controller.optionsButton
        controller.env = env
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: isAnnouncement
            ? String(localized: "Announcement Details", bundle: .core)
            : String(localized: "Discussion Details", bundle: .core)
        )
        courseSectionsView.isHidden = true

        optionsButton.accessibilityLabel = String(localized: "Options", bundle: .core)
        optionsButton.accessibilityIdentifier = "DiscussionDetails.options"

        pointsView.isHidden = true
        publishedView.isHidden = true

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        titleLabel.text = nil
        titleLabel.accessibilityIdentifier = "DiscussionDetails.title"

        // Can't put in storyboard because that breaks cookie sharing
        // & discussion view is cached without verifiers on images
        webViewPlaceholder.addSubview(webView)
        webView.accessibilityIdentifier = "DiscussionDetails.body"
        webView.pinWithThemeSwitchButton(inside: webViewPlaceholder)
        webView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        webView.autoresizesHeight = true // will update the height constraint
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceVertical = false
        webView.backgroundColor = .backgroundLightest
        webView.linkDelegate = self
        webView.errorDelegate = self
        webView.addScript(DiscussionHTML.preact)
        webView.addScript(DiscussionHTML.js)
        webView.handle("like") { [weak self] message in self?.handleLike(message) }
        webView.handle("moreOptions") { [weak self] message in self?.handleMoreOptions(message) }
        webView.handle("ready") { [weak self] _ in self?.ready() }

        if showRepliesToEntryID != nil {
            titleSubtitleView.title = isAnnouncement
                ? String(localized: "Announcement Replies", bundle: .core)
                : String(localized: "Discussion Replies", bundle: .core)
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
        groups.exhaust(force: true)

        let rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: env.currentSession?.uniqueID ?? "",
            courseId: course.first?.id ?? "",
            sectionName: isAnnouncement ? OfflineFolderPrefix.announcements.rawValue : OfflineFolderPrefix.discussions.rawValue,
            resourceId: topicID
        )
        webView.loadFileURL(
            URL.Directories.documents,
            allowingReadAccessTo: URL.Directories.documents
        ) { [weak self] _ in
            guard let self else { return }

            webView.loadHTMLString(
                "<style>\(DiscussionHTML.css)</style>",
                baseURL: offlineModeInteractor?.isOfflineModeEnabled() == true ?
                    rootURL :
                    env.api.baseURL.appendingPathComponent("\(context.pathComponent)/discussion_topics/\(topicID)")
            )
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
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
                ? String(localized: "Announcement Replies", bundle: .core)
                : String(localized: "Discussion Replies", bundle: .core)
        ) : (
            isAnnouncement
                ? String(localized: "Announcement Details", bundle: .core)
                : String(localized: "Discussion Details", bundle: .core)
        )
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        guard fixStudentGroupTopic() else { return }

        let courseID = context.contextType == .group ? group.first?.courseID : context.id
        if assignment?.useCase.assignmentID != topic.first?.assignmentID, let courseID = courseID {
            assignment = topic.first?.assignmentID.map {
                env.subscribe(GetAssignment(courseID: courseID, assignmentID: $0, include: [ .overrides ])) { [weak self] in
                    self?.update()
                }
            }
            assignment?.refresh()
        }

        if let sections = topic.first?.sections, topic.first?.isSectionSpecific == true {
            courseSectionsLabel.text = String.localizedStringWithFormat(
                String(localized: "Sections: %@", bundle: .core),
                ListFormatter.localizedString(from: sections.map { $0.name })
            )
            courseSectionsView.isHidden = false
        } else {
            courseSectionsView.isHidden = true
        }

        let pending = topic.pending || entries.pending
        let error = topic.error ?? entries.error
        spinnerView.isHidden = !pending || (!topic.isEmpty && !entries.isEmpty) || error != nil || refreshControl.isRefreshing

        titleLabel.text = topic.first?.title
        pointsLabel.text = assignment?.first?.pointsPossibleText
        pointsView.isHidden = assignment?.first?.pointsPossible == nil || showRepliesToEntryID != nil ||
        hideQuantitativeData

        let isPublished = topic.first?.published == true
        publishedIcon.image = isPublished ? .publishSolid : .noSolid
        publishedIcon.tintColor = isPublished ? .textSuccess : .textDark
        publishedLabel.text = isPublished
            ? String(localized: "Published", bundle: .core)
            : String(localized: "Unpublished", bundle: .core)
        publishedLabel.textColor = isPublished ? .textSuccess : .textDark
        publishedView.isHidden = env.app != .teacher || isAnnouncement || showRepliesToEntryID != nil

        if env.app == .teacher, let courseID = courseID, let assignmentID = topic.first?.assignmentID {
            if dueSection.isHidden, let assignment = topic.first?.assignment {
                let controller = CoreHostingController(DateSection(viewModel: AssignmentDateSectionViewModel(assignment: assignment)))
                controller.view.backgroundColor = nil
                embed(controller, in: dueSection)
                dueSection.isHidden = false
            }

            if topic.first?.groupTopicChildren == nil, submissionsSection.isHidden {
                let viewModel = AssignmentSubmissionBreakdownViewModel(courseID: courseID, assignmentID: assignmentID, submissionTypes: [.discussion_topic], env: env)
                let controller = CoreHostingController(SubmissionBreakdown(viewModel: viewModel), env: env)
                controller.view.backgroundColor = nil
                embed(controller, in: submissionsSection)
                submissionsSection.isHidden = false
            }
        }

        render()
    }

    @objc func refresh() {
        spinnerView.isHidden = true
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
        groups.exhaust(force: true)
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
        guard groups.requested && !groups.pending else { return false }
        guard
            env.app == .student, context.contextType == .course,
            let topic = topic.first, topic.groupCategoryID != nil,
            let subs = topic.groupTopicChildren,
            let groupID = groups.first(where: { subs[$0.id] != nil })?.id,
            let childID = subs[groupID]
        else { return true }
        context = Context(.group, id: groupID)
        topicID = childID
        isReady = false
        isRendered = false

        entries = env.subscribe(GetDiscussionView(context: context, topicID: topicID)) { [weak self] in
            self?.update()
        }
        group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
            self?.updateNavBar()
        }
        permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .postToForum ])) { [weak self] in
            self?.update()
        }
        self.topic = env.subscribe(GetDiscussionTopic(context: context, topicID: topicID)) { [weak self] in
            self?.update()
        }
        entries.refresh()
        group.refresh()
        permissions.refresh()
        self.topic.refresh(force: true)

        let rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: env.currentSession?.uniqueID ?? "",
            courseId: course.first?.id ?? "",
            sectionName: isAnnouncement ? OfflineFolderPrefix.announcements.rawValue : OfflineFolderPrefix.discussions.rawValue,
            resourceId: topic.id
        )
        webView.loadFileURL(
            URL.Directories.documents,
            allowingReadAccessTo: URL.Directories.documents
        ) { [weak self] _ in
            guard let self else { return }

            webView.loadHTMLString(
                "<style>\(DiscussionHTML.css)</style>",
                baseURL: offlineModeInteractor?.isOfflineModeEnabled() == true ?
                    rootURL :
                    env.api.baseURL.appendingPathComponent("\(context.pathComponent)/discussion_topics/\(topicID)")
            )
        }
        return false
    }

    func ready() {
        isReady = true
        render()
    }

    func render() {
        guard isReady, let topic = topic.first, !entries.pending || !entries.isEmpty else { return }
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            guard !offlineLoaded else { return }
        }
        var script: String
        if let root = showRepliesToEntryID.flatMap({ entry($0) }) {
            let newRoot = replaceContentForOfflineMode(for: root)
            script = DiscussionHTML.render(
                entry: newRoot,
                in: topic,
                maxDepth: maxDepth,
                canLike: canLike
            )
        } else {
            let isFutureDiscussion: Bool = {
                // Discussions in the future might not have an assignment,
                // but their posted at date can still be in the future.
                guard let assignment = topic.assignment else {
                    return topic.postedAt ?? Date.distantPast > Date()
                }
                guard let unlockDate = assignment.unlockAt else {
                    return false
                }
                return unlockDate > Date()
            }()
            let entries: [DiscussionEntry] = {
                if env.app == .student && isFutureDiscussion {
                    return []
                }
                var entries = self.entries.filter { $0.parentID == nil}
                if topic.sortByRating {
                    entries.sort { $0.likeCount > $1.likeCount }
                }
                return entries
            }()

            let newtopic = replaceContentForOfflineMode(for: topic)
            let newEntries = entries.map { entry in
                return replaceContentForOfflineMode(for: entry)
            }

            script = DiscussionHTML.render(
                topic: newtopic,
                entries: newEntries,
                maxDepth: maxDepth,
                canLike: canLike,
                groups: groups.all,
                contextColor: color
            )
        }
        script += "\nloadMathJaxIfNecessary()"

        webView.evaluateJavaScript(script) { [weak self] _, error in
            guard let self else { return }

            if error != nil {
                self.showFallbackWebView()
                RemoteLogger.shared.logError(name: "Javascript evaluation failed", reason: error?.localizedDescription)
                return
            }

            self.rendered()
            self.focusOnNewReplyIfNecessary()
        }
    }

    private func replaceContentForOfflineMode(for originalTopic: DiscussionTopic) -> DiscussionTopic {

        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            let rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
                sessionId: env.currentSession?.uniqueID ?? "",
                courseId: course.first?.id ?? "",
                sectionName: isAnnouncement ? OfflineFolderPrefix.announcements.rawValue : OfflineFolderPrefix.discussions.rawValue,
                resourceId: originalTopic.id
            )
            let offlinePath = rootURL.appendingPathComponent("body.html")

            let newTopic = originalTopic

            let rawHtmlValue = try? String(contentsOf: offlinePath, encoding: .utf8)
            offlineLoaded = true
            newTopic.message = rawHtmlValue

            return newTopic
        } else {
            return originalTopic
        }
    }

    private func replaceContentForOfflineMode(for originalEntry: DiscussionEntry) -> DiscussionEntry {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            let rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
                sessionId: env.currentSession?.uniqueID ?? "",
                courseId: course.first?.id ?? "",
                sectionName: isAnnouncement ? OfflineFolderPrefix.announcements.rawValue : OfflineFolderPrefix.discussions.rawValue,
                resourceId: originalEntry.id
            )
            let offlinePath = rootURL.appendingPathComponent("body.html")

            let newEntry = originalEntry

            let rawHtmlValue = try? String(contentsOf: offlinePath, encoding: .utf8)
            offlineLoaded = true
            newEntry.message = rawHtmlValue

            newEntry.replies = newEntry.replies.map { reply in
                return replaceContentForOfflineMode(for: reply)
            }

            return newEntry
        }

        return originalEntry
    }

    private func showFallbackWebView() {
        guard let embedURL = webView.url?.appendingQueryItems(.init(name: "embed", value: "true")) else {
            return
        }

        // This is to break the infinite render-error-render-error cycle.
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "ready")
        webView.load(URLRequest(url: embedURL))
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
                    showRepliesToEntryID: entryID,
                    env: self.env
                )
                self.env.router.show(controller, from: self)
            }
        }
        if showRepliesToEntryID == nil {
            AppStoreReview.handleNavigateToAssignment()
        }
        scrollViewDidScroll(scrollView) // read initial
        UIAccessibility.post(notification: .screenChanged, argument: titleSubtitleView)
    }

    func findNewReplyIDFromCurrentUser() -> String? {
        let firstInsertedMessageIndex: Int? = {
            let currentDate = Date()
            for change in entries.changes {
                if case .insertRow(let insertIndex) = change,
                   let entryDate = entries[insertIndex]?.createdAt,
                   currentDate.timeIntervalSince(entryDate) < 5 { // We check the date because pull-to-refresh and TTL expiration also cause insert type context changes.
                    return insertIndex.row
                }
            }

            return nil
        }()

        if let firstInsertedMessageIndex = firstInsertedMessageIndex,
           let currentUserID = env.currentSession?.actAsUserID ?? env.currentSession?.userID,
           entries.all[firstInsertedMessageIndex].userID == currentUserID {
            return entries.all[firstInsertedMessageIndex].id
        }

        return nil
    }

    private func focusOnNewReplyIfNecessary() {
        if let newReplyIDFromCurrentUser,
           // if the webview content is smaller than the screen then scrolling will trigger the pull to refresh icon
           isContentLargerThanView {
            webView.scrollIntoView(fragment: "entry-\(newReplyIDFromCurrentUser)")
        }

        self.newReplyIDFromCurrentUser = nil
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
            if url.pathComponents.contains("files") && url.host == env.currentSession?.baseURL.host {
                if offlineModeInteractor?.isOfflineModeEnabled() == true && !url.pathComponents.contains("offline") {
                    let fileId = url.pathComponents[(url.pathComponents.firstIndex(of: "files") ?? 0) + 1]
                    let offlineURL = "/courses/\(context.id)/files/\(isAnnouncement ? OfflineFolderPrefix.announcements : OfflineFolderPrefix.discussions)/\(topicID)/\(fileId)/offline"
                    env.router.route(to: offlineURL, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
                } else {
                    env.router.route(to: url, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
                }
            } else {
                env.router.route(to: url, from: self)
            }
            return true
        }
        let path = Array(url.pathComponents.dropFirst(5))
        // Reply to main discussion
        if path.count == 1, path[0] == "reply" {
            if offlineModeInteractor?.isOfflineModeEnabled() == true {
                UIAlertController.showItemNotAvailableInOfflineAlert()
                return true
            }

            Analytics.shared.logEvent(isAnnouncement ? "announcement_replied" : "discussion_topic_replied")
            env.router.route(to: url, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            return true
        }
        // Reply to thread
        if path.count == 3, path[0] == "entries", !path[1].isEmpty, path[2] == "replies" {
            if offlineModeInteractor?.isOfflineModeEnabled() == true {
                UIAlertController.showItemNotAvailableInOfflineAlert()
                return true
            }

            env.router.route(to: url, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            return true
        }
        if path.count == 2, path[0] == "replies" {
            let controller = DiscussionDetailsViewController.create(
                context: context,
                topicID: topicID,
                isAnnouncement: isAnnouncement,
                showRepliesToEntryID: path[1],
                env: env
            )
            env.router.show(controller, from: self)
            return true
        }
        env.router.route(to: url, from: self)
        return true
    }
}

// MARK: - User Actions From Nav Bar

extension DiscussionDetailsViewController {

    @objc
    func showTopicOptions() {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            return UIAlertController.showItemNotAvailableInOfflineAlert()
        }

        guard let topic = topic.first else { return }

        let sheet = BottomSheetPickerViewController.create()
        if entries.contains(where: { $0.isRead == false }) {
            sheet.addAction(
                image: .checkSolid,
                title: String(localized: "Mark All as Read", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.markAllRead"
            ) { [weak self] in
                self?.markAllRead(isRead: true)
            }
        }
        if entries.contains(where: { $0.isRead == true }) {
            sheet.addAction(
                image: .noSolid,
                title: String(localized: "Mark All as Unread", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.markAllUnread"
            ) { [weak self] in
                self?.markAllRead(isRead: false)
            }
        }
        if topic.subscribed {
            sheet.addAction(
                image: .noSolid,
                title: String(localized: "Unsubscribe", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.unsubscribe"
            ) { [weak self] in
                self?.subscribe(false)
            }
        } else {
            sheet.addAction(
                image: .checkSolid,
                title: String(localized: "Subscribe", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.subscribe"
            ) { [weak self] in
                self?.subscribe(true)
            }
        }
        if topic.canUpdate {
            sheet.addAction(
                image: .editLine,
                title: String(localized: "Edit", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.edit"
            ) { [weak self] in
                self?.editTopic()
            }
        }
        if topic.canDelete {
            sheet.addAction(
                image: .trashLine,
                title: String(localized: "Delete", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.delete"
            ) { [weak self] in
                self?.deleteTopic()
            }
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func editTopic() {
        let path = "\(context.pathComponent)/\(isAnnouncement ? "announcements" : "discussion_topics")/\(topicID)/edit"
        env.router.route(to: path, from: self, options: .modal(isDismissable: false, embedInNav: true, addDoneButton: true))
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

    func subscribe(_ subscribed: Bool) {
        SubscribeDiscussionTopic(context: context, topicID: topicID, subscribed: subscribed).fetch()
    }

    func deleteTopic() {
        DeleteDiscussionTopic(context: context, topicID: topicID).fetch { [weak self] _, _, error in performUIUpdate {
            guard let self = self else { return }
            if let error = error { return self.showError(error) }
            self.env.router.dismiss(self)
        } }
    }
}

// MARK: - User Actions From HTML

extension DiscussionDetailsViewController {

    private func handleLike(_ message: WKScriptMessage) {
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            return UIAlertController.showItemNotAvailableInOfflineAlert()
        }

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
        if offlineModeInteractor?.isOfflineModeEnabled() == true {
            return UIAlertController.showItemNotAvailableInOfflineAlert()
        }

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
            entry.author?.id == env.currentSession?.userID &&
            topic.canUpdate
        )
        let canDelete = env.app == .teacher || (
            !topic.lockedForUser &&
            entry.author?.id == env.currentSession?.userID &&
            topic.canDelete
        )

        let sheet = BottomSheetPickerViewController.create()
        if entry.isRead == false {
            sheet.addAction(
                image: .checkSolid,
                title: String(localized: "Mark as Read", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.markAsRead"
            ) { [weak self] in
                self?.markRead(entryID, isRead: true)
            }
        } else {
            sheet.addAction(
                image: .noSolid,
                title: String(localized: "Mark as Unread", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.markAsUnread"
            ) { [weak self] in
                self?.markRead(entryID, isRead: false)
            }
        }
        if canEdit {
            sheet.addAction(
                image: .editLine,
                title: String(localized: "Edit", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.edit"
            ) { [weak self] in
                self?.editEntry(entryID)
            }
        }
        if canDelete {
            sheet.addAction(
                image: .trashLine,
                title: String(localized: "Delete", bundle: .core),
                accessibilityIdentifier: "DiscussionDetails.delete"
            ) { [weak self] in
                self?.deleteEntry(entryID)
            }
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func editEntry(_ entryID: String) {
        let entry = self.entry(entryID)
        let controller = DiscussionReplyViewController
            .create(
                env: env,
                context: context,
                topicID: topicID,
                replyToEntryID: entry?.parentID,
                editEntryID: entryID
            )
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

extension DiscussionDetailsViewController: CoreWebViewErrorDelegate {

    public func containerForContentErrorView() -> UIView {
        view
    }

    public func urlForExternalBrowser() -> URL? {
        webView.url
    }
}
