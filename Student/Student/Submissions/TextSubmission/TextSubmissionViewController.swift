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

class TextSubmissionViewController: UIViewController, ErrorViewController, RichContentEditorDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!

    var assignmentID: String!
    var courseID: String!
    var editor: RichContentEditorViewController!
    var keyboard: KeyboardTransitioning?
    var userID: String!

    private var env: AppEnvironment = .defaultValue

    static func create(env: AppEnvironment, courseID: String, assignmentID: String, userID: String) -> TextSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.courseID = courseID
        controller.userID = userID
        controller.env = env
        controller.editor = RichContentEditorViewController
            .create(env: env, context: .course(courseID), uploadTo: .myFiles)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = String(localized: "Text Entry", bundle: .student)

        navigationController?.navigationBar.useModalStyle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Submit", bundle: .student), style: .plain, target: self, action: #selector(submit))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "TextSubmission.submitButton"
        navigationItem.rightBarButtonItem?.isEnabled = false
        addCancelButton(side: .left)

        editor.delegate = self
        editor.placeholder = String(localized: "Write...", bundle: .student, comment: "Text submission editor placeholder")
        editor.a11yLabel = String(localized: "Submission text", bundle: .student, comment: "Text submission editor accessibility label")
        editor.webView.scrollView.layer.masksToBounds = false
        embed(editor, in: contentView)
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

    @objc func submit() {
        editor.getHTML { [weak self] (html: String) in
            guard let self else { return }

            CreateSubmission(
                context: .course(self.courseID),
                assignmentID: self.assignmentID,
                userID: self.userID,
                submissionType: .online_text_entry,
                body: html
            )
            .fetch(environment: self.env, { (_, _, error) in

                performUIUpdate {
                    if let error = error {
                        self.showError(error)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
}
