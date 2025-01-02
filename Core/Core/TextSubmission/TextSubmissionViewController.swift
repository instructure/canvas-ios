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

public final class TextSubmissionViewController: UIViewController, ErrorViewController, RichContentEditorDelegate {
    // MARK: - Outlets

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var keyboardSpace: NSLayoutConstraint!

    // MARK: - Properties
    public var editor: RichContentEditorViewController!
    public var keyboard: KeyboardTransitioning?
    private var assignmentID: String?
    private var courseID: String?
    private var env = AppEnvironment.shared
    private var userID: String?
    private var htmlContent = ""
    private var isHorizonApp: Bool {
        env.app != .student
    }

    // MARK: - Public Properties
    public var didSetHtmlContent: ((String) -> Void) = { _ in}

    public static func create(env: AppEnvironment, courseID: String, assignmentID: String, userID: String) -> TextSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.courseID = courseID
        controller.userID = userID
        controller.env = env
        controller.editor = RichContentEditorViewController
            .create(env: env, context: .course(courseID), uploadTo: .myFiles)
        return controller
    }

    public static func create(htmlContent: String, courseID: String) -> TextSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.editor = RichContentEditorViewController.create(env: .shared, context: .course(courseID), uploadTo: .myFiles)
        controller.htmlContent = htmlContent
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = String(localized: "Text Entry", bundle: .core)

        navigationController?.navigationBar.useModalStyle()
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "TextSubmission.submitButton"
        navigationItem.rightBarButtonItem?.isEnabled = false
        addNavBarButtons()
        editor.delegate = self
        editor.placeholder = String(localized: "Write...", bundle: .core, comment: "Text submission editor placeholder")
        editor.a11yLabel = String(localized: "Submission text", bundle: .core, comment: "Text submission editor accessibility label")
        editor.webView.scrollView.layer.masksToBounds = false
        embed(editor, in: contentView)

        if htmlContent.isNotEmpty, isHorizonApp {
            editor.setHTML(htmlContent)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
    }

    public func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = canSubmit
    }

    public func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        showError(error)
    }

    private func addNavBarButtons() {
        if isHorizonApp {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: String(localized: "Done", bundle: .core),
                style: .plain,
                target: self,
                action: #selector(sendHTMLContent)
            )
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: String(localized: "Cancel", bundle: .core),
                style: .plain,
                target: self,
                action: #selector(horizonCancel)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: String(localized: "Submit", bundle: .core),
                style: .plain,
                target: self,
                action: #selector(submit)
            )
            addCancelButton(side: .left)
        }
    }

    @objc private func sendHTMLContent() {
        editor.getHTML { [weak self] html in
            guard let self else {
                return
            }
            didSetHtmlContent(html)
            env.router.dismiss(self)
        }
    }

    @objc private func horizonCancel() {
        didSetHtmlContent(htmlContent)
        env.router.dismiss(self)
    }

    @objc func submit() {
        guard let courseID, let assignmentID, let userID else {
            return
        }
        editor.getHTML { [weak self] (html: String) in
            guard let self else { return }
            CreateSubmission(
                context: .course(courseID),
                assignmentID: assignmentID,
                userID: userID,
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
