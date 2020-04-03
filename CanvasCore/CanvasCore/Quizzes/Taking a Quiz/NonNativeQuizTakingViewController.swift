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
import WebKit
import Core

class NonNativeQuizTakingViewController: UIViewController {
    @objc let session: Session
    let contextID: ContextID
    let quiz: Quiz
    @objc let baseURL: URL

    let env = AppEnvironment.shared
    private let webView = CoreWebView()

    init(session: Session, contextID: ContextID, quiz: Quiz, baseURL: URL) {
        self.session = session
        self.contextID = contextID
        self.quiz = quiz
        self.baseURL = baseURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.linkDelegate = self
        webView.uiDelegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Exit", bundle: .core, comment: "Exit button to leave the quiz"),
            style: .plain, target: self, action: #selector(NonNativeQuizTakingViewController.exitQuiz(_:))
        )

        let url = quiz.mobileURL.appendingQueryItems(URLQueryItem(name: "platform", value: "ios"))
        AppEnvironment.shared.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] response, _, _ in
            DispatchQueue.main.async { self?.webView.load(URLRequest(url: response?.session_url ?? url)) }
        }
    }

    @objc func exitQuiz(_ button: UIBarButtonItem?) {
        if webView.url?.path.contains("/take") == true {
            let areYouSure = NSLocalizedString("Are you sure you want to leave this quiz?", bundle: .core, comment: "Question to confirm user wants to navigate away from a quiz.")
            let stay = NSLocalizedString("Stay", bundle: .core, comment: "Stay on the quiz view")
            let leave = NSLocalizedString("Leave", bundle: .core, comment: "Leave the quiz")
            
            let alert = UIAlertController(title: nil, message: areYouSure, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: stay, style: .cancel))
            alert.addAction(UIAlertAction(title: leave, style: .default) { _ in
                self.refreshCoreQuiz()
                self.dismiss(animated: true, completion: nil)
            })
            present(alert, animated: true, completion: nil)
        } else {
            refreshCoreQuiz()
            dismiss(animated: true, completion: nil)
        }
        session.progressDispatcher.dispatch(Progress(kind: .submitted, contextID: contextID, itemType: .quiz, itemID: quiz.id))
        session.progressDispatcher.dispatch(Progress(kind: .viewed, contextID: contextID, itemType: .quiz, itemID: quiz.id))
        session.progressDispatcher.dispatch(Progress(kind: .minimumScore, contextID: contextID, itemType: .quiz, itemID: quiz.id))
    }

    func refreshCoreQuiz() {
        NotificationCenter.default.post(name: .quizRefresh, object: nil, userInfo: [
            "quizID": quiz.id,
        ])
    }
}

extension NonNativeQuizTakingViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completionHandler(true)
        })
        present(alert, animated: true, completion: nil)
    }
}

extension NonNativeQuizTakingViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        if let take = env.currentSession?.baseURL
            .appendingPathComponent("\(contextID.htmlPath)/quizzes/\(quiz.id)/take"),
            url.absoluteString.hasPrefix(take.absoluteString) {
            return false
        }
        env.router.route(to: url, from: self)
        return true
    }
}
