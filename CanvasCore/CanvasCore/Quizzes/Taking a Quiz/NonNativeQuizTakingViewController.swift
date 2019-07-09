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
import Cartography

class NonNativeQuizTakingViewController: UIViewController {
    
    @objc let session: Session
    let contextID: ContextID
    let quiz: Quiz
    @objc let baseURL: URL
    
    fileprivate let webView: UIWebView = UIWebView()
    fileprivate var quizHostName = ""
    fileprivate var loggingIn: Bool = false
    fileprivate var urlForTakingQuiz: URL {
        return quiz.mobileURL.appending(URLQueryItem(name: "platform", value: "ios")) ?? quiz.mobileURL
    }
    fileprivate var requestForTakingQuiz: URLRequest {
        return URLRequest(url: urlForTakingQuiz)
    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        constrain(webView) { webView in
            webView.edges == webView.superview!.edges; return
        }

        prepareNavigationBar()
        webView.scalesPageToFit = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.scalePageToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        beginTakingQuiz()
    }
    
    fileprivate func prepareNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Exit", tableName: "Localizable", bundle: .core, value: "", comment: "Exit button to leave the quiz"), style: .plain, target: self, action: #selector(NonNativeQuizTakingViewController.exitQuiz(_:)))
    }
    
    @objc func beginTakingQuiz() {
        if let host = urlForTakingQuiz.host {
            quizHostName = host
        }
        APIBridge.shared().call("getAuthenticatedSessionURL", args: [urlForTakingQuiz.absoluteString]) { [weak self] response, error in
            if let data = response as? [String: Any],
                let sessionURL = data["session_url"] as? String,
                let url = URL(string: sessionURL) {
                self?.webView.loadRequest(URLRequest(url: url))
            } else if let url = self?.urlForTakingQuiz {
                self?.webView.loadRequest(URLRequest(url: url))
            }
        }
    }
    
    @objc func exitQuiz(_ button: UIBarButtonItem?) {
        if webView.request?.url?.path.range(of: "/take") != nil {
            let areYouSure = NSLocalizedString("Are you sure you want to leave this quiz?", tableName: "Localizable", bundle: .core, value: "", comment: "Question to confirm user wants to navigate away from a quiz.")
            let stay = NSLocalizedString("Stay", tableName: "Localizable", bundle: .core, value: "", comment: "Stay on the quiz view")
            let leave = NSLocalizedString("Leave", tableName: "Localizable", bundle: .core, value: "", comment: "Leave the quiz")
            
            let alert = UIAlertController(title: nil, message: areYouSure, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: stay, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: leave, style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
        session.progressDispatcher.dispatch(Progress(kind: .submitted, contextID: contextID, itemType: .quiz, itemID: quiz.id))
        session.progressDispatcher.dispatch(Progress(kind: .viewed, contextID: contextID, itemType: .quiz, itemID: quiz.id))
        session.progressDispatcher.dispatch(Progress(kind: .minimumScore, contextID: contextID, itemType: .quiz, itemID: quiz.id))
    }
    
    fileprivate func beginLoggingIn() {
        loggingIn = true
        let url = baseURL.appendingPathComponent("/login?headless=1")
        webView.loadRequest(URLRequest(url: url))
    }
    
    fileprivate func finishedLoggingIn() {
        loggingIn = false
        webView.loadRequest(requestForTakingQuiz)
    }
    
    fileprivate func dispatchHeadlessVersionOfRequest(_ request: URLRequest) {
        if let queryString = request.url?.query {
            if let urlAsAString = request.url?.absoluteString.appendingFormat("%@%@", queryString.count > 0 ? "&" : "?", "persist_headless=1") {
                let updatedRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
                if let newURL =  URL(string: urlAsAString) {
                    updatedRequest.url = newURL
                    webView.loadRequest(updatedRequest as URLRequest)
                }
            }
        }
    }
}

extension NonNativeQuizTakingViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // TODO: post 3 module item updates: MustView, MustSubmit, MinimumScore
        
        if !webView.isLoading {
            if let currentUserID = webView.stringByEvaluatingJavaScript(from: "ENV.current_user_id") {
                let isValidUserID = currentUserID.count > 0 && (currentUserID as NSString).longLongValue > 0
                
                if loggingIn {
                    if isValidUserID {
                        let path = webView.request?.url?.path
                        
                        if path != nil && path!.range(of: "/login") == nil {
                            finishedLoggingIn()
                        }
                        return
                    }
                } else {
                    if let query = webView.request?.url?.query {
                        if !isValidUserID && (query.count == 0 || query.range(of: "cross_domain_login") == nil) {
                            beginLoggingIn()
                            return
                        }
                    }
                }
                
                webView.stringByEvaluatingJavaScript(from: "window.onbeforeunload = function(){ }; $('a').addClass('no-warning');")
                webView.scalePageToFit()
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let currentRequestHost = request.url?.host
        let currentRequestPath = request.url?.path
        let queryString = request.url?.query
        
        // about:blank
        if currentRequestHost == nil {
            return true
        }
        
        // if the requested URL is internal to the quiz
        if currentRequestPath?.range(of: "/quizzes/") != nil {
            // we are grabbing this as the quizHostName because there are cases where the host changes from
            // the current logged-in host provided by the canvasAPI and this particular quiz. I have observed
            // this when a single account is associated with multiple domains.
            quizHostName = currentRequestHost!
        } else if navigationType == .linkClicked {
            // TODO: maybe open a native in app browser?
            if let URL = request.url {
                UIApplication.shared.open(URL)
            }
            return false
        }
        
        // if the user just finished logging in
        if queryString?.range(of: "login_success=1") != nil {
            finishedLoggingIn()
            return false
        }
        
        let isIframedOrOtherInternalContent = navigationType == UIWebView.NavigationType.other && quizHostName != currentRequestHost!
        if loggingIn || queryString?.range(of: "persist_headless=1") != nil || isIframedOrOtherInternalContent {
            return true
        }
        
        // replace with the headless version of the same request.
        dispatchHeadlessVersionOfRequest(request)
        
        return false
    }
}
