//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
@preconcurrency import WebKit

public class StudentQuizWebViewController: UIViewController {
    var courseID = ""
    var quizID = ""

    let env = AppEnvironment.shared
    let webView = CoreWebView(features: [.invertColorsInDarkMode, .skipJSInjection(CoreWebView.mathJaxJS)])

    public static func create(courseID: String, quizID: String) -> StudentQuizWebViewController {
        let controller = StudentQuizWebViewController()
        controller.courseID = courseID
        controller.quizID = quizID
        return controller
    }

    public override func loadView() {
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        webView.linkDelegate = self
        webView.uiDelegate = self

        title = String(localized: "Take Quiz", bundle: .core)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: String(localized: "Exit", bundle: .core, comment: "Exit button to leave the quiz"),
            style: .plain, target: self, action: #selector(exitQuiz)
        )

        let url = env.api.baseURL
            .appendingPathComponent("courses/\(courseID)/quizzes/\(quizID)")
            .appendingQueryItems(
                URLQueryItem(name: "force_user", value: "1"),
                URLQueryItem(name: "persist_headless", value: "1"),
                URLQueryItem(name: "platform", value: "ios")
            )
        env.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] response, _, _ in
            performUIUpdate { self?.webView.load(URLRequest(url: response?.session_url ?? url)) }
        }
    }

    @objc func exitQuiz() {
        if webView.url?.path.contains("/take") == true {
            let areYouSure = String(localized: "Are you sure you want to leave this quiz?", bundle: .core)
            let stay = String(localized: "Stay", bundle: .core, comment: "Stay on the quiz view")
            let leave = String(localized: "Leave", bundle: .core, comment: "Leave the quiz")

            let alert = UIAlertController(title: nil, message: areYouSure, preferredStyle: .alert)
            alert.addAction(AlertAction(stay, style: .cancel))
            alert.addAction(AlertAction(leave, style: .default) { _ in
                self.refreshQuiz()
                self.env.router.dismiss(self)
            })
            env.router.show(alert, from: self, options: .modal())
        } else {
            refreshQuiz()
            env.router.dismiss(self)
        }
    }

    func refreshQuiz() {
        NotificationCenter.default.post(name: .quizRefresh, object: nil, userInfo: [
            "quizID": quizID
        ])
    }
}

extension StudentQuizWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .default) { _ in
            completionHandler(true)
        })
        env.router.show(alert, from: self, options: .modal())
    }
}

extension StudentQuizWebViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        if let take = env.currentSession?.baseURL
            .appendingPathComponent("courses/\(courseID)/quizzes/\(quizID)/take"),
            url.absoluteString.hasPrefix(take.absoluteString) {
            return false
        }
        env.router.route(to: url, from: self)
        return true
    }
}
