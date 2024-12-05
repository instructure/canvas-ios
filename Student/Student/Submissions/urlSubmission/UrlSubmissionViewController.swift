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
import Core

class UrlSubmissionViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var webView: CoreWebView!
    @IBOutlet weak var loadingView: UIView!
    var presenter: UrlSubmissionPresenter!
    var assignmentID: String!
    var courseID: String!

    static func create(env: AppEnvironment, courseID: String, assignmentID: String, userID: String) -> UrlSubmissionViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.assignmentID = assignmentID
        controller.presenter = UrlSubmissionPresenter(env: env, view: controller, courseID: courseID, assignmentID: assignmentID, userID: userID)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        loadingView?.backgroundColor = .backgroundLightest
        title = String(localized: "Website Address", bundle: .student)
        textField.accessibilityLabel = title

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Submit", bundle: .student), style: .plain, target: self, action: #selector(submit))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "URLSubmission.submit"
        addCancelButton(side: .left)
    }

    @objc
    func submit() {
        loadingView.alpha = 0.85
        presenter.submit(textField.text)
    }
}

extension UrlSubmissionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrubUrl), object: textField)
        perform(#selector(scrubUrl), with: textField, afterDelay: 0.75)
        return true
    }

    @objc
    func scrubUrl() {
        presenter.scrubAndLoadUrl(text: textField.text)
    }

    func showError(_ error: Error) {
        loadingView.alpha = 0.0
        showAlert(title: nil, message: error.localizedDescription)
    }
}

extension UrlSubmissionViewController: UrlSubmissionViewProtocol {
    func loadUrl(url: URL) {
        webView.load(URLRequest(url: url))
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
