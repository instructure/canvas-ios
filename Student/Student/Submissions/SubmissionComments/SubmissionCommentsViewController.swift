//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreServices
import Core
import UniformTypeIdentifiers

class SubmissionCommentsViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var addCommentBorderView: UIView!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var addCommentTextView: UITextView!
    @IBOutlet weak var addCommentTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var addMediaHeight: NSLayoutConstraint!
    @IBOutlet weak var addMediaView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyContainer: UIView!

    var currentUserID: String?
    var keyboard: KeyboardTransitioning?
    var presenter: SubmissionCommentsPresenter?
    var submissionPresenter: SubmissionDetailsPresenter?

    static func create(
        env: AppEnvironment = .shared,
        context: Context,
        assignmentID: String,
        userID: String,
        submissionID: String,
        submissionPresenter: SubmissionDetailsPresenter
    ) -> SubmissionCommentsViewController {
        let controller = loadFromStoryboard()
        controller.presenter = SubmissionCommentsPresenter(env: env, view: controller, context: context, assignmentID: assignmentID, userID: userID, submissionID: submissionID)
        controller.submissionPresenter = submissionPresenter
        controller.currentUserID = env.currentSession?.userID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
        addCommentBorderView.backgroundColor = .backgroundLightest
        addCommentBorderView.layer.borderColor = UIColor.borderMedium.cgColor
        addCommentBorderView.layer.borderWidth = 1 / UIScreen.main.scale
        addCommentButton.accessibilityLabel = NSLocalizedString("Send comment", bundle: .student, comment: "")
        addCommentTextView.accessibilityLabel = NSLocalizedString("Add a comment or reply to previous comments", bundle: .student, comment: "")
        addCommentTextView.placeholder = NSLocalizedString("Comment", bundle: .student, comment: "")
        addCommentTextView.placeholderColor = .textDark
        addCommentTextView.font(.scaledNamedFont(.regular16), lineHeight: .body)
        addCommentTextView.adjustsFontForContentSizeCategory = true
        addCommentTextView.textColor = .textDarkest
        addCommentView.backgroundColor = .backgroundLight
        emptyContainer.isHidden = true
        emptyLabel.text = NSLocalizedString("Have questions about your assignment?\nMessage your instructor.", bundle: .student, comment: "")
        emptyImageView.image = UIImage(named: Panda.NoComments.name, in: .core, compatibleWith: nil)
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.keyboardDismissMode = .onDrag
        addMediaButton.accessibilityLabel = NSLocalizedString("Add media attachment", bundle: .student, comment: "")

        presenter?.viewIsReady()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    @IBAction func addCommentButtonPressed(_ sender: UIButton) {
        guard let text = addCommentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        presenter?.addComment(text: text)
        addCommentTextView.text = ""
        textViewDidChange(addCommentTextView)
    }

    @IBAction func addMediaButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(AlertAction(NSLocalizedString("Record Audio", bundle: .student, comment: ""), style: .default) { _ in
            AudioRecorderViewController.requestPermission { [weak self] allowed in
                guard let self = self else { return }
                guard allowed else {
                    self.showPermissionError(.microphone)
                    return
                }
                let controller = AudioRecorderViewController.create()
                controller.delegate = self
                self.showMediaController(controller)
            }
        })
        alert.addAction(AlertAction(NSLocalizedString("Record Video", bundle: .student, comment: ""), style: .default) { _ in
            VideoRecorder.requestPermission { [weak self] allowed in
                guard let self = self else { return }
                guard allowed else {
                    self.showPermissionError(.camera)
                    return
                }
                AudioRecorderViewController.requestPermission { allowed in
                    guard allowed else {
                        self.showPermissionError(.microphone)
                        return
                    }
                    let picker = UIImagePickerController()
                    picker.allowsEditing = true
                    picker.delegate = self
                    picker.mediaTypes = [ UTType.movie.identifier ]
                    picker.sourceType = .camera
                    picker.cameraDevice = .front
                    self.present(picker, animated: true)
                }
            }
        })
        alert.addAction(AlertAction(NSLocalizedString("Choose File", bundle: .student, comment: ""), style: .default) { [weak self] _ in
            let picker = FilePickerViewController.create()
            picker.delegate = self
            picker.title = NSLocalizedString("Attachments", bundle: .student, comment: "")
            picker.submitButtonTitle = NSLocalizedString("Send", bundle: .student, comment: "")
            let nav = UINavigationController(rootViewController: picker)
            self?.present(nav, animated: true, completion: nil)
        })
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .cancel))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        present(alert, animated: true)
    }

    func showMediaController(_ controller: UIViewController) {
        guard let container = addMediaView else { return }
        addCommentTextView.resignFirstResponder()
        controller.view.alpha = 0
        embed(controller, in: container)
        UIView.animate(withDuration: 0.275, animations: {
            controller.view.alpha = 1
            self.addCommentBorderView.alpha = 0
            self.addMediaButton.alpha = 0
            self.addMediaHeight.constant = 240
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.addCommentBorderView.isHidden = true
            self.addMediaButton.isHidden = true
        })
    }

    func hideMediaController(_ controller: UIViewController) {
        addCommentBorderView.isHidden = false
        addMediaButton.isHidden = false
        UIView.animate(withDuration: 0.275, animations: {
            controller.view.alpha = 0
            self.addCommentBorderView.alpha = 1
            self.addMediaButton.alpha = 1
            self.addMediaHeight.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            controller.unembed()
        })
    }
}

extension SubmissionCommentsViewController: AudioRecorderDelegate {
    func cancel(_ controller: AudioRecorderViewController) {
        hideMediaController(controller)
    }

    func send(_ controller: AudioRecorderViewController, url: URL) {
        presenter?.addMediaComment(type: .audio, url: url)
        hideMediaController(controller)
    }
}

extension SubmissionCommentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let url = info[.mediaURL] as? URL else { return }
        presenter?.addMediaComment(type: .video, url: url)
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension SubmissionCommentsViewController: SubmissionCommentsViewProtocol {
    func reload() {
        emptyContainer.isHidden = presenter?.comments.isEmpty == false
        guard let changes = presenter?.comments.changes, changes.count == 1 else {
            tableView.reloadData()
            return
        }
        switch changes[0] {
        case .insertRow(let row):
            tableView.insertRows(at: [
                IndexPath(row: row.row * 2, section: row.section),
                IndexPath(row: row.row * 2 + 1, section: row.section),
            ], with: .automatic)
        case .updateRow(let row):
            tableView.reloadRows(at: [
                IndexPath(row: row.row * 2, section: row.section),
                IndexPath(row: row.row * 2 + 1, section: row.section),
            ], with: .automatic)
        default:
            tableView.reloadData()
        }
    }
}

extension SubmissionCommentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (presenter?.comments.count ?? 0) * 2 // header + content
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comment = presenter?.comments[indexPath.row / 2] else { return UITableViewCell() }

        if indexPath.row % 2 == 1 {
            let reuseID = currentUserID == comment.authorID ? "myHeader" : "theirHeader"
            let cell: SubmissionCommentHeaderCell = tableView.dequeue(withID: reuseID, for: indexPath)
            cell.update(comment: comment)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }

        if let attempt = comment.attempt {
            let submission = submissionPresenter?.submissions.first { $0.attempt == attempt }
            let cell: SubmissionCommentAttemptCell = tableView.dequeue(for: indexPath)
            cell.stackView?.alignment = currentUserID == comment.authorID ? .trailing : .leading
            cell.update(comment: comment, submission: submission) { [weak self] (submission: Submission?, file: File?) in
                guard let attempt = submission?.attempt else { return }
                self?.submissionPresenter?.select(attempt: attempt, fileID: file?.id)
            }
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }

        if comment.mediaURL != nil, comment.mediaType == .some(.audio) {
            let cell: SubmissionCommentAudioCell = tableView.dequeue(for: indexPath)
            cell.update(comment: comment, parent: self)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }

        if comment.mediaURL != nil, comment.mediaType == .some(.video) {
            let cell: SubmissionCommentVideoCell = tableView.dequeue(for: indexPath)
            cell.update(comment: comment, parent: self)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }

        let reuseID = currentUserID == comment.authorID ? "myComment" : "theirComment"
        let cell: SubmissionCommentTextCell = tableView.dequeue(withID: reuseID, for: indexPath)
        cell.update(comment: comment)
        cell.onTapAttachment = { [weak self] file in
            guard let self = self else { return }
            self.presenter?.showAttachment(file, from: self)
        }
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
}

extension SubmissionCommentsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        addCommentButton.isEnabled = !(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        addCommentButton.alpha = addCommentButton.isEnabled ? 1 : 0.5
        textView.adjustHeight(to: 10, heightConstraints: addCommentTextViewHeightConstraint)
    }
}

extension SubmissionCommentsViewController: FilePickerControllerDelegate {
    func retry(_ controller: FilePickerViewController) {
    }

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return controller.files.isEmpty == false
    }

    func cancel(_ controller: FilePickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func submit(_ controller: FilePickerViewController) {
        controller.dismiss(animated: true) {
            self.presenter?.addFileComment(batchID: controller.batchID)
        }
    }
}
