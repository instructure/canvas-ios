//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import PSPDFKit

class CommentListViewController: UIViewController {
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint?
    @IBOutlet weak var replyBorderView: UIView?
    @IBOutlet weak var replyButton: DynamicButton?
    @IBOutlet weak var replyPlaceholder: DynamicLabel?
    @IBOutlet weak var replyTextView: UITextView?
    @IBOutlet weak var replyView: UIView?
    @IBOutlet weak var replyViewHeight: NSLayoutConstraint?
    @IBOutlet weak var tableView: UITableView?

    var annotation = PSPDFAnnotation()
    var comments = [DocViewerCommentReplyAnnotation]()
    var document: PSPDFDocument?
    var metadata: APIDocViewerAnnotationsMetadata?

    static func create(
        comments: [DocViewerCommentReplyAnnotation],
        inReplyTo annotation: PSPDFAnnotation,
        document: PSPDFDocument,
        metadata: APIDocViewerAnnotationsMetadata
    ) -> CommentListViewController {
        let controller = Bundle.loadController(self)
        controller.annotation = annotation
        controller.comments = comments
        controller.document = document
        controller.metadata = metadata
        return controller
    }

    override func viewDidLoad() {
        navigationItem.title = NSLocalizedString("Comments", bundle: .core, comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(_:)))

        replyBorderView?.backgroundColor = .named(.backgroundLightest)
        replyBorderView?.layer.borderWidth = 1 / UIScreen.main.scale
        replyBorderView?.layer.borderColor = UIColor.named(.borderMedium).cgColor
        replyTextView?.font = .scaledNamedFont(.bodySmall)
        replyTextView?.adjustsFontForContentSizeCategory = true
        replyTextView?.accessibilityLabel = NSLocalizedString("Reply to the annotation or previous comments", bundle: .core, comment: "")
        replyButton?.accessibilityLabel = NSLocalizedString("Send comment", bundle: .core, comment: "")

        if (metadata?.permissions ?? .none) == .none {
            replyView?.isHidden = true
            replyViewHeight?.isActive = true
        }

        setInsets()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if replyView?.isHidden == false {
            replyTextView?.becomeFirstResponder()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setInsets() {
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: replyView?.frame.height ?? 0, right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: replyView?.frame.height ?? 0, right: 0)
    }

    @objc func donePressed(_ sender: UIBarButtonItem) {
        let deleted = comments.filter({ $0.isDeleted })
        if !deleted.isEmpty { document?.remove(deleted, options: nil) }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func replyButtonPressed(_ sender: UIButton) {
        guard let textView = replyTextView, let contents = replyTextView?.text.trimmingCharacters(in: .whitespacesAndNewlines), !contents.isEmpty else { return }
        let reply = DocViewerCommentReplyAnnotation(contents: contents)
        reply.pageIndex = annotation.pageIndex
        reply.inReplyToName = annotation.name
        reply.user = metadata?.user_id
        reply.userName = metadata?.user_name
        comments.append(reply)
        document?.add([reply], options: nil)
        textView.text = ""
        textViewDidChange(textView)
        tableView?.insertRows(at: [ IndexPath(row: comments.count - 1, section: 0) ], with: .automatic)
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
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", bundle: .core, comment: ""), style: .destructive, handler: { _ in
            guard let index = self.comments.index(of: comment) else { return }
            self.document?.remove([comment], options: nil)
            self.comments.remove(at: index)
            self.tableView?.deleteRows(at: [ IndexPath(row: index, section: 0) ], with: .automatic)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension CommentListViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        replyButton?.isEnabled = !(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        replyPlaceholder?.isHidden = !textView.text.isEmpty
        setInsets()
    }
}

extension CommentListViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let keyboardHeight = (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height,
            let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        // We do this before the animation and again during the animation, which forces the tableView to first figure out how big it is (cuz esimatedRowHeight)
        // and then again to do the animation once it actually knows
        if !comments.isEmpty {
            tableView?.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: .bottom, animated: false)
        }

        keyboardSpace?.constant = keyboardHeight
        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: {
            self.view.layoutIfNeeded()
            if !self.comments.isEmpty {
                self.tableView?.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: false)
            }
        }, completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        keyboardSpace?.constant = 0
        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
