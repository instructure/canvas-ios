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
import Core

class UrlSubmissionViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var webView: CoreWebView!
    @IBOutlet weak var borderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var loadingView: UIView!
    var presenter: UrlSubmissionPresenter!
    var assignmentID: String!
    var courseID: String!

    static func create(courseID: String, assignmentID: String, userID: String) -> UrlSubmissionViewController {
        let controller = Bundle.loadController(self)
        controller.courseID = courseID
        controller.assignmentID = assignmentID
        controller.presenter = UrlSubmissionPresenter(view: controller, courseID: courseID, assignmentID: assignmentID, userID: userID)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Website Address", comment: "")

        borderHeightConstraint.constant = 1.0 / UIScreen.main.scale
        borderView.backgroundColor = .named(.ash)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Submit", comment: ""), style: .plain, target: self, action: #selector(submit))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "UrlSubmissionPage.submit"
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
