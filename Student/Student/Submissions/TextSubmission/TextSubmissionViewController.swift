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
import Core

class TextSubmissionViewController: UIViewController, ErrorViewController, RichContentEditorDelegate, TextSubmissionViewProtocol {
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint?

    var editor: RichContentEditorViewController?
    var keyboard: KeyboardTransitioning?
    var presenter: TextSubmissionPresenter?

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String) -> TextSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.editor = RichContentEditorViewController.create(env: env, uploadTo: .myFiles)
        controller.presenter = TextSubmissionPresenter(env: env, view: controller, courseID: courseID, assignmentID: assignmentID, userID: userID)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Text Entry", bundle: .student, comment: "")

        navigationController?.navigationBar.useModalStyle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Submit", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(submit))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "TextSubmission.submitButton"
        navigationItem.rightBarButtonItem?.isEnabled = false
        addCancelButton(side: .left)

        if let contentView = contentView, let editor = editor {
            editor.delegate = self
            editor.placeholder = NSLocalizedString("Enter submission", bundle: .student, comment: "")
            editor.webView.scrollView.layer.masksToBounds = false
            embed(editor, in: contentView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = canSubmit
    }

    func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        showError(error)
    }

    @objc func submit(_ sender: Any? = nil) {
        editor?.getHTML { (html: String) in
            self.presenter?.submit(html) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError(error)
                    } else {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
