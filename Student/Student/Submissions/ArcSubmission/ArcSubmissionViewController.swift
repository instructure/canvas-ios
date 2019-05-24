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
    var webView: WKWebView!
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

        spinner.startAnimating()

        let config = WKWebViewConfiguration()
        config.processPool = CoreWebView.processPool
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.addScript(js)
        webView.handle("submit") { [weak self] message in
            self?.presenter?.submit(form: message.body) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.webView.reload()
                        self?.showError(error)
                        return
                    }
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        view.addSubview(webView)
        webView.pin(inside: view)
        presenter?.viewIsReady()
    }

    func load(_ url: URL) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.webView.load(URLRequest(url: url))
        }
    }

    var js: String {
        return """
            HTMLFormElement.prototype.submit = function() {
                let formData = {}
                for (const [ name, value ] of new FormData(this)) {
                    formData[name] = value
                }
                window.webkit.messageHandlers.submit.postMessage(formData)
            }
        """
    }
}

extension ArcSubmissionViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.contains("success/external_tool_dialog") == true {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
