//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import PSPDFKit

class CommentListViewController: UIViewController {
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var replyBorderView: UIView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    var annotation = Annotation()
    var comments = [DocViewerCommentReplyAnnotation]()
    var document: Document?
    var keyboard: KeyboardTransitioning?
    var metadata: APIDocViewerAnnotationsMetadata?

    static func create(
        comments: [DocViewerCommentReplyAnnotation],
        inReplyTo annotation: Annotation,
        document: Document,
        metadata: APIDocViewerAnnotationsMetadata
    ) -> CommentListViewController {
        let controller = loadFromStoryboard()
        controller.annotation = annotation
        controller.comments = comments
        controller.document = document
        controller.metadata = metadata
        return controller
    }

    override func viewDidLoad() {
        navigationItem.title = NSLocalizedString("Comments", bundle: .core, comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(_:)))

        replyBorderView.backgroundColor = .backgroundLightest
        replyBorderView.layer.borderWidth = 1 / UIScreen.main.scale
        replyBorderView.layer.borderColor = UIColor.borderMedium.cgColor
        replyTextView.placeholderColor = .textDark
        replyTextView.placeholder = NSLocalizedString("Reply", bundle: .core, comment: "")
        replyTextView.font(.scaledNamedFont(.regular16), lineHeight: .body)
        replyTextView.adjustsFontForContentSizeCategory = true
        replyTextView.accessibilityLabel = NSLocalizedString("Reply to the annotation or previous comments", bundle: .core, comment: "")
        replyTextView.textColor = .textDarkest
        replyButton.accessibilityLabel = NSLocalizedString("Send comment", bundle: .core, comment: "")
        replyView.backgroundColor = .backgroundLight

        if (metadata?.permissions ?? APIDocViewerPermissions.none) == APIDocViewerPermissions.none {
            replyView.isHidden = true
            replyViewHeight.isActive = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace) { [weak self] in
            if let self = self, !self.comments.isEmpty {
                self.tableView?.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: false)
            }
        }

        if replyView.isHidden == false {
            replyTextView.becomeFirstResponder()
        }
    }

    @objc func donePressed(_ sender: UIBarButtonItem) {
        let deleted = comments.filter({ $0.isDeleted })
        if !deleted.isEmpty { document?.remove(annotations: deleted, options: nil) }
        dismiss(animated: true)
    }

    @IBAction func replyButtonPressed(_ sender: UIButton) {
        guard let contents = replyTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !contents.isEmpty else { return }
        let reply = DocViewerCommentReplyAnnotation(contents: contents)
        reply.pageIndex = annotation.pageIndex
        reply.inReplyToName = annotation.name
        reply.user = metadata?.user_id
        reply.userName = metadata?.user_name
        annotation.hasReplies = true
        comments.append(reply)
        document?.add(annotations: [reply], options: nil)
        replyTextView.text = ""
        textViewDidChange(replyTextView)
        tableView.insertRows(at: [ IndexPath(row: comments.count - 1, section: 0) ], with: .automatic)
    }
}

extension CommentListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CommentListCell.self, for: indexPath)
        cell.update(comment: comments[indexPath.row], delegate: self, metadata: metadata)
        return cell
    }
}

extension CommentListViewController: CommentListCellDelegate {
    func deletePressed(on comment: DocViewerCommentReplyAnnotation) {
        let alert = UIAlertController(
            title: NSLocalizedString("Delete Comment", bundle: .core, comment: ""),
            message: NSLocalizedString("Are you sure you would like to delete this comment?", bundle: .core, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("Delete", bundle: .core, comment: ""), style: .destructive) { _ in
            guard let index = self.comments.firstIndex(of: comment) else { return }
            self.document?.remove(annotations: [comment], options: nil)
            self.comments.remove(at: index)
            self.tableView.deleteRows(at: [ IndexPath(row: index, section: 0) ], with: .automatic)
        })
        present(alert, animated: true, completion: nil)
    }
}

extension CommentListViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        replyButton.isEnabled = !(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        replyButton.alpha = replyButton.isEnabled ? 1 : 0.5
    }
}
