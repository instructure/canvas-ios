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
import QuickLook
import UIKit
import Combine
import CombineExt

public class DiscussionReplyViewController: ScreenViewTrackableViewController, ErrorViewController, RichContentEditorDelegate {
    lazy var contentHeight = webView.heightAnchor.constraint(equalToConstant: 0)
    var contentHeightObs: NSKeyValueObservation?
    @IBOutlet weak var editorContainer: UIView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    let titleSubtitleView = TitleSubtitleView.create()
    @IBOutlet weak var viewMoreButton: UIButton!
    var webView = CoreWebView()
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet var webViewHeight: NSLayoutConstraint!

    lazy var attachButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.setImage(.paperclipLine, for: .normal)
        button.addTarget(self, action: #selector(attach), for: .primaryActionTriggered)
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        button.addSubview(attachBadge)
        attachBadge.isHidden = true
        attachBadge.isUserInteractionEnabled = false
        attachBadge.translatesAutoresizingMaskIntoConstraints = false
        attachBadge.backgroundColor = .backgroundLightest
        attachBadge.layer.cornerRadius = 8
        NSLayoutConstraint.activate([
            attachBadge.centerXAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            attachBadge.centerYAnchor.constraint(equalTo: button.topAnchor, constant: 2),
            attachBadge.widthAnchor.constraint(equalToConstant: 16),
            attachBadge.heightAnchor.constraint(equalToConstant: 16),
        ])

        let label = UILabel()
        label.backgroundColor = .electric
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = NumberFormatter.localizedString(from: 1, number: .none)
        attachBadge.addSubview(label)
        label.pin(inside: attachBadge, leading: 2, trailing: 2, top: 2, bottom: 2)

        return UIBarButtonItem(customView: button)
    }()
    let attachBadge = UIView()
    lazy var sendButton = UIBarButtonItem(
        title: NSLocalizedString("Send", bundle: .core, comment: ""), style: .done,
        target: self, action: #selector(sendReply)
    )

    var attachmentURL: URL?
    let collapsedHeight: CGFloat = 120
    var context = Context.currentUser
    var editEntryID: String?
    var editHTML: String?
    lazy var editor = RichContentEditorViewController.create(context: context,
                                                             uploadTo: fileUploadContext)
    private var fileUploadContext: FileUploadContext {
        .makeForRCEUploads(app: env.app,
                           context: context,
                           session: env.currentSession)
    }
    let env = AppEnvironment.shared
    lazy var filePicker = FilePicker(delegate: self)
    var isExpanded = false
    var keyboard: KeyboardTransitioning?
    var replyToEntryID: String?
    var rceCanSubmit = false
    var topicID = ""
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/discussion_topics/\(topicID)/reply"
    )
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var editEntry = editEntryID.map {
        env.subscribe(GetDiscussionEntry(context: context, topicID: topicID, entryID: $0)) { [weak self] in
            self?.update()
        }
    }
    lazy var replyToEntry = replyToEntryID.map {
        env.subscribe(GetDiscussionEntry(context: context, topicID: topicID, entryID: $0)) { [weak self] in
            self?.update()
        }
    }
    lazy var topic = env.subscribe(GetDiscussionTopic(context: context, topicID: topicID)) { [weak self] in
        self?.update()
    }
    private var subscriptions = Set<AnyCancellable>()

    public static func create(context: Context, topicID: String, replyToEntryID: String? = nil, editEntryID: String? = nil) -> DiscussionReplyViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.editEntryID = editEntryID
        controller.replyToEntryID = replyToEntryID
        controller.topicID = topicID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = editEntryID != nil
            ? NSLocalizedString("Edit", bundle: .core, comment: "")
            : NSLocalizedString("Reply", bundle: .core, comment: "")

        addCancelButton(side: .left)
        attachButton.accessibilityIdentifier = "DiscussionEditReply.attachmentButton"
        sendButton.accessibilityIdentifier = "DiscussionEditReply.sendButton"
        sendButton.isEnabled = false
        navigationItem.rightBarButtonItem = sendButton

        editor.delegate = self
        editor.placeholder = NSLocalizedString("Add message", bundle: .core, comment: "")
        editor.a11yLabel = NSLocalizedString("Message", bundle: .core, comment: "")
        editor.webView.autoresizesHeight = true
        editor.webView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        editor.webView.scrollView.alwaysBounceVertical = false
        embed(editor, in: editorContainer)

        viewMoreButton.isHidden = true
        viewMoreButton.setTitle(NSLocalizedString("View More", bundle: .core, comment: ""), for: .normal)
        viewMoreButton.layer.borderColor = UIColor.borderMedium.cgColor
        viewMoreButton.layer.borderWidth = 1 / UIScreen.main.scale

        webViewContainer.addSubview(webView)
        webView.autoresizesHeight = true
        webView.backgroundColor = .backgroundLightest
        webView.linkDelegate = self
        webView.scrollView.isScrollEnabled = false
        contentHeight.priority = .defaultHigh // webViewHeight will win
        contentHeight.isActive = true
        contentHeightObs = contentHeight.observe(\.constant) { [weak self] _, _ in
            self?.heightChanged()
        }
        webView.pinWithThemeSwitchButton(inside: webViewContainer)

        updateButtons()

        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        replyToEntry?.refresh()
        topic.refresh()

        if context.id.hasShardID {
            ContextBaseURLInteractor(api: env.api)
                .getBaseURL(context: context)
                .map { $0 as URL? }
                .replaceError(with: nil)
                .assign(to: \.fileUploadBaseURL, on: editor, ownership: .weak)
                .store(in: &subscriptions)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        heightChanged()
    }

    func heightChanged() {
        let contentHeight = self.contentHeight.constant + webView.themeSwitcherHeight
        webViewHeight.constant = isExpanded || contentHeight <= collapsedHeight ? contentHeight : collapsedHeight
        viewMoreButton.isHidden = contentHeight <= collapsedHeight
    }

    func update() {
        loadViewIfNeeded()
        guard let topic = topic.first else { return }
        loadingView.isHidden = replyToEntry?.pending != true || replyToEntry?.isEmpty != false
        navigationItem.rightBarButtonItems = topic.canAttach && editEntryID == nil
            ? [ sendButton, attachButton ]
            : [ sendButton ]

        var html: String?
        if replyToEntryID != nil, let replyTo = replyToEntry?.first {
            html = DiscussionHTML.string(for: replyTo)
        } else if replyToEntryID == nil {
            html = DiscussionHTML.string(for: topic)
        }
        if let html = html, webView.url != topic.htmlURL {
            webView.loadHTMLString(html, baseURL: topic.htmlURL)
        }

        if let entry = editEntry?.first, editHTML != entry.message {
            editHTML = entry.message
            editor.setHTML(entry.message ?? "")
        }
    }

    func updateNavBar() {
        titleSubtitleView.subtitle = context.contextType == .course ? course.first?.name : group.first?.name
    }

    func updateButtons() {
        sendButton.isEnabled = (
            sendButton.customView == nil &&
            (rceCanSubmit || attachmentURL != nil)
        )

        if attachmentURL == nil {
            attachButton.accessibilityLabel = NSLocalizedString("Edit attachment (none)", bundle: .core, comment: "")
            attachBadge.isHidden = true
        } else {
            attachButton.accessibilityLabel = NSLocalizedString("Edit attachment (1)", bundle: .core, comment: "")
            attachBadge.isHidden = false
        }
    }

    @IBAction func toggleViewMore() {
        isExpanded = !isExpanded
        UIView.animate(withDuration: 0.3) {
            self.heightChanged()
            self.view.layoutIfNeeded()
        }
        viewMoreButton.setTitle(isExpanded
            ? NSLocalizedString("View Less", bundle: .core, comment: "")
            : NSLocalizedString("View More", bundle: .core, comment: ""),
        for: .normal)
        webView.scrollView.isScrollEnabled = isExpanded
    }

    public func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
        rceCanSubmit = canSubmit
        updateButtons()
    }

    public func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        showError(error)
    }

    @objc func sendReply() {
        let spinner = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        spinner.color = nil
        sendButton.customView = spinner
        updateButtons()
        editor.getHTML { (html: String) in
            self.saveReply(html)
        }
    }

    func saveReply(_ message: String) {
        if let entryID = editEntryID {
            UpdateDiscussionReply(
                context: context,
                topicID: topicID,
                entryID: entryID,
                message: message
            ).fetch { [weak self] _, _, error in performUIUpdate {
                self?.saveReplyComplete(error: error)
            } }
        } else {
            CreateDiscussionReply(
                context: context,
                topicID: topicID,
                entryID: replyToEntryID,
                message: message,
                attachment: attachmentURL
            ).fetch { [weak self] _, _, error in performUIUpdate {
                self?.saveReplyComplete(error: error)
            } }
            return
        }
    }

    func saveReplyComplete(error: Error?) {
        if let error = error {
            sendButton.customView = nil
            updateButtons()
            showError(error)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            UIAccessibility.announce(NSLocalizedString("Reply sent", bundle: .core, comment: "VoiceOver announcement after a reply was successfully posted."))
        }
        env.router.dismiss(self)
    }
}

extension DiscussionReplyViewController: FilePickerDelegate, QLPreviewControllerDataSource {
    @objc func attach() {
        guard attachmentURL != nil else { return filePicker.pick(from: self) }

        let sheet = BottomSheetPickerViewController.create()
        sheet.addAction(
            image: .eyeLine,
            title: NSLocalizedString("View", bundle: .core, comment: ""),
            accessibilityIdentifier: "DiscussionEditReply.viewMenuAction"
        ) { [weak self] in
            guard let self = self else { return }
            let controller = QLPreviewController()
            controller.dataSource = self
            self.env.router.show(controller, from: self, options: .modal())
        }
        sheet.addAction(
            image: .trashLine,
            title: NSLocalizedString("Delete", bundle: .core, comment: ""),
            accessibilityIdentifier: "DiscussionEditReply.deleteMenuAction"
        ) { [weak self] in
            guard let self = self, let url = self.attachmentURL else { return }
            self.attachmentURL = nil
            self.updateButtons()
            try? FileManager.default.removeItem(at: url)
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    public func filePicker(didPick url: URL) {
        attachmentURL = url
        updateButtons()
    }

    // Should not be needed since we don't filePicker.showOptions.
    public func filePicker(didRetry file: File) {}

    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return attachmentURL != nil ? 1 : 0
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return attachmentURL! as NSURL
    }
}

extension DiscussionReplyViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        if url.pathComponents.count > 1, url.pathComponents[1] == "files" {
            env.router.route(to: url, from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
        } else {
            env.router.route(to: url, from: self)
        }
        return true
    }
}
