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

public class DiscussionReplyViewController: UIViewController, CoreWebViewLinkDelegate, ErrorViewController, RichContentEditorDelegate {
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
        button.setImage(.icon(.paperclip), for: .normal)
        button.addTarget(self, action: #selector(attach), for: .primaryActionTriggered)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.addSubview(attachBadge)
        attachBadge.isHidden = true
        attachBadge.isUserInteractionEnabled = false
        attachBadge.translatesAutoresizingMaskIntoConstraints = false
        attachBadge.backgroundColor = .named(.backgroundLightest)
        attachBadge.layer.cornerRadius = 8
        NSLayoutConstraint.activate([
            attachBadge.centerXAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            attachBadge.centerYAnchor.constraint(equalTo: button.topAnchor, constant: 2),
            attachBadge.widthAnchor.constraint(equalToConstant: 16),
            attachBadge.heightAnchor.constraint(equalToConstant: 16),
        ])

        let label = UILabel()
        label.backgroundColor = .named(.electric)
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .named(.white)
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
    lazy var editor = RichContentEditorViewController.create(context: context, uploadTo: env.app == .teacher ? .context(context) : .myFiles)
    let env = AppEnvironment.shared
    lazy var filePicker = FilePicker(delegate: self)
    var isExpanded = false
    var keyboard: KeyboardTransitioning?
    var replyToEntryID: String?
    var rceCanSubmit = false
    var topicID = ""

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
        view.backgroundColor = .named(.backgroundLightest)
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = editEntryID != nil
            ? NSLocalizedString("Edit", bundle: .core, comment: "")
            : NSLocalizedString("Reply", bundle: .core, comment: "")

        addCancelButton(side: .left)
        attachButton.accessibilityLabel = NSLocalizedString("Attachment", bundle: .core, comment: "")
        attachButton.accessibilityIdentifier = "DiscussionEditReply.attachmentButton"
        sendButton.accessibilityIdentifier = "DiscussionEditReply.sendButton"
        sendButton.isEnabled = false
        navigationItem.rightBarButtonItem = sendButton

        editor.delegate = self
        editor.placeholder = NSLocalizedString("Message", bundle: .core, comment: "")
        editor.webView.autoresizesHeight = true
        editor.webView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        editor.webView.scrollView.alwaysBounceVertical = false
        embed(editor, in: editorContainer)

        viewMoreButton.isHidden = true
        viewMoreButton.setTitle(NSLocalizedString("View More", bundle: .core, comment: ""), for: .normal)
        viewMoreButton.layer.borderColor = UIColor.named(.borderMedium).cgColor
        viewMoreButton.layer.borderWidth = 1 / UIScreen.main.scale

        webViewContainer.addSubview(webView)
        webView.autoresizesHeight = true
        webView.backgroundColor = .named(.backgroundLightest)
        webView.linkDelegate = self
        webView.scrollView.isScrollEnabled = false
        contentHeight.priority = .defaultHigh // webViewHeight will win
        contentHeight.isActive = true
        contentHeightObs = contentHeight.observe(\.constant) { [weak self] _, _ in
            self?.heightChanged()
        }
        webView.pin(inside: webViewContainer)

        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        replyToEntry?.refresh()
        topic.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    func heightChanged() {
        let contentHeight = self.contentHeight.constant
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

    func updateSendButton() {
        sendButton.isEnabled = (
            sendButton.customView == nil &&
            (rceCanSubmit || attachmentURL != nil)
        )
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
        updateSendButton()
    }

    public func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        showError(error)
    }

    @objc func sendReply() {
        let spinner = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        spinner.color = nil
        sendButton.customView = spinner
        updateSendButton()
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
            updateSendButton()
            showError(error)
            return
        }
        env.router.dismiss(self)
    }
}

extension DiscussionReplyViewController: FilePickerDelegate, QLPreviewControllerDataSource {
    @objc func attach() {
        guard attachmentURL != nil else { return filePicker.pick(from: self) }

        let sheet = BottomSheetPickerViewController.create()
        sheet.addAction(image: .icon(.eye), title: NSLocalizedString("View", bundle: .core, comment: "")) { [weak self] in
            guard let self = self else { return }
            let controller = QLPreviewController()
            controller.dataSource = self
            self.env.router.show(controller, from: self, options: .modal())
        }
        sheet.addAction(image: .icon(.trash), title: NSLocalizedString("Delete", bundle: .core, comment: "")) { [weak self] in
            guard let self = self, let url = self.attachmentURL else { return }
            self.attachmentURL = nil
            self.attachBadge.isHidden = true
            self.updateSendButton()
            try? FileManager.default.removeItem(at: url)
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    public func filePicker(didPick url: URL) {
        attachmentURL = url
        attachBadge.isHidden = false
        updateSendButton()
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
