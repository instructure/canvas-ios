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

import Foundation
import WebKit
@testable import Core

/// This classes uses a WKWebView to complete the oauth2 code flow
/// in order to obtain an access token.
class TokenProvider: NSObject {
    var presenter: LoginWebPresenter?
    let loginID: String
    let password: String
    let callback: (String) -> Void

    var webView: WKWebView {
        // Uniquely identify this web view
        let tag = 42
        guard let webView = UIApplication.shared.keyWindow!.viewWithTag(tag) as? WKWebView else {
            let view = WKWebView(frame: UIScreen.main.bounds)
            view.tag = tag
            view.navigationDelegate = self

            // The web view must be on screen in order for it to make requests.
            UIApplication.shared.keyWindow!.addSubview(view)
            return view
        }
        return webView
    }

    init(host: String, loginID: String, password: String, callback: @escaping (String) -> Void) {
        self.loginID = loginID
        self.password = password
        self.callback = callback

        super.init()

        self.presenter = LoginWebPresenter(authenticationProvider: nil, host: host, loginDelegate: self, method: .canvasLogin, view: self)
        presenter?.viewIsReady()
    }
}

extension TokenProvider: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.allow)
        }

        let action = presenter?.navigationActionPolicyForUrl(url: url) ?? .cancel
        decisionHandler(action)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Inject loginID and password
        webView.evaluateJavaScript("document.querySelector('input[name=\"pseudonym_session[unique_id]\"]').value = '\(loginID)'", completionHandler: nil)
        webView.evaluateJavaScript("document.querySelector('input[name=\"pseudonym_session[password]\"]').value = '\(password)'", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('login_form').submit()", completionHandler: nil)
    }
}

extension TokenProvider: LoginWebViewProtocol, ErrorViewController {
    func show(_ vc: UIViewController, sender: Any?) {
        // loading view will be passed in
    }

    var navigationController: UINavigationController? {
        return nil
    }

    func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
}

extension TokenProvider: LoginDelegate {
    var loginLogo: UIImage { return UIImage(named: "CanvasStudent")! }

    func openExternalURL(_ url: URL) {}

    func userDidLogin(keychainEntry: KeychainEntry) {
        // Remove the web view from the view hierarchy now that it is no longer needed
        webView.removeFromSuperview()

        callback(keychainEntry.accessToken)
    }

    func userDidLogout(keychainEntry: KeychainEntry) {}
}
