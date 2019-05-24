//
// Copyright (C) 2019-present Instructure, Inc.
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

import Core
import WebKit

protocol ArcSubmissionDelegate: class {
    func arcSubmission(_ controller: ArcSubmissionViewController, didFinishWithURL url: URL)
    func arcSubmission(_ controller: ArcSubmissionViewController, didFinishWithError error: Error)
}

class ArcSubmissionViewController: UIViewController, ArcSubmissionView {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    weak var delegate: ArcSubmissionDelegate?
    var presenter: ArcSubmissionPresenter?

    static func create(environment: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String, arcID: String) -> ArcSubmissionViewController {
        let controller = loadFromStoryboard()
        let presenter = ArcSubmissionPresenter(
            environment: environment,
            view: controller,
            courseID: courseID,
            assignmentID: assignmentID,
            userID: userID,
            arcID: arcID
        )
        controller.presenter = presenter
        presenter.view = controller
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addCancelButton(side: .left)

        webView.navigationDelegate = self
        spinner.startAnimating()
        presenter?.viewIsReady()
    }

    func load(_ url: URL) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.webView.load(URLRequest(url: url))
        }
    }
}

extension ArcSubmissionViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.contains("success/external_tool_dialog") == true {
            // TODO: intercept post body here
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
