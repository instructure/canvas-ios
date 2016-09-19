//
//  NonNativeQuizTakingViewController.swift
//  Quizzes
//
//  Created by Ben Kraus on 4/30/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import WebKit
import Cartography
import SoPretty
import SoLazy
import SoProgressive
import TooLegit

class NonNativeQuizTakingViewController: UIViewController {
    
    let session: Session
    let contextID: ContextID
    let quiz: Quiz
    let baseURL: NSURL
    
    private let webView: UIWebView = UIWebView()
    private var quizHostName = ""
    private var loggingIn: Bool = false
    private var requestForTakingQuiz: NSURLRequest {
        return NSURLRequest(URL: quiz.mobileURL)
    }
    
    init(session: Session, contextID: ContextID, quiz: Quiz, baseURL: NSURL) {
        self.session = session
        self.contextID = contextID
        self.quiz = quiz
        self.baseURL = baseURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
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
    
    override func viewWillAppear(animated: Bool) {
        beginTakingQuiz()
    }
    
    private func prepareNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Exit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Exit button to leave the quiz"), style: .Plain, target: self, action: Selector("exitQuiz:"))
    }
    
    func beginTakingQuiz() {
        if let host = requestForTakingQuiz.URL?.host {
            quizHostName = host
        }
        webView.loadRequest(requestForTakingQuiz)
    }
    
    func exitQuiz(button: UIBarButtonItem?) {
        if webView.request?.URL?.path?.rangeOfString("/take") != nil {
            let areYouSure = NSLocalizedString("Are you sure you want to leave this quiz?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Question to confirm user wants to navigate away from a quiz.")
            let stay = NSLocalizedString("Stay", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Stay on the quiz view")
            let leave = NSLocalizedString("Leave", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Leave the quiz")
            
            let alert = UIAlertController(title: nil, message: areYouSure, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: stay, style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: leave, style: .Default, handler: { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
        session.progressDispatcher.dispatch(Progress(kind: .Submitted, contextID: contextID, itemType: .Quiz, itemID: quiz.id))
        session.progressDispatcher.dispatch(Progress(kind: .Viewed, contextID: contextID, itemType: .Quiz, itemID: quiz.id))
        session.progressDispatcher.dispatch(Progress(kind: .MinimumScore, contextID: contextID, itemType: .Quiz, itemID: quiz.id))
    }
    
    private func beginLoggingIn() {
        loggingIn = true
        let url = baseURL.URLByAppendingPathComponent("/login?headless=1")
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    private func finishedLoggingIn() {
        loggingIn = false
        webView.loadRequest(requestForTakingQuiz)
    }
    
    private func dispatchHeadlessVersionOfRequest(request: NSURLRequest) {
        if let queryString = request.URL?.query {
            if let urlAsAString = request.URL?.absoluteString.stringByAppendingFormat("%@%@", queryString.characters.count > 0 ? "&" : "?", "persist_headless=1") {
                let updatedRequest = request.mutableCopy() as! NSMutableURLRequest
                if let newURL =  NSURL(string: urlAsAString) {
                    updatedRequest.URL = newURL
                    webView.loadRequest(updatedRequest)
                }
            }
        }
    }
}

extension NonNativeQuizTakingViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        // TODO: post 3 module item updates: MustView, MustSubmit, MinimumScore
        
        if !webView.loading {
            if let currentUserID = webView.stringByEvaluatingJavaScriptFromString("ENV.current_user_id") {
                let isValidUserID = currentUserID.characters.count > 0 && (currentUserID as NSString).longLongValue > 0
                
                if loggingIn {
                    if isValidUserID {
                        let path = webView.request?.URL?.path
                        
                        if path != nil && path!.rangeOfString("/login") == nil {
                            finishedLoggingIn()
                        }
                        return
                    }
                } else {
                    if let query = webView.request?.URL?.query {
                        if !isValidUserID && (query.characters.count == 0 || query.rangeOfString("cross_domain_login") == nil) {
                            beginLoggingIn()
                            return
                        }
                    }
                }
                
                webView.stringByEvaluatingJavaScriptFromString("window.onbeforeunload = function(){ }; $('a').addClass('no-warning');")
                webView.scalePageToFit()
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let currentRequestHost = request.URL?.host
        let currentRequestPath = request.URL?.path
        let queryString = request.URL?.query
        
        // about:blank
        if currentRequestHost == nil {
            return true
        }
        
        // if the requested URL is internal to the quiz
        if currentRequestPath?.rangeOfString("/quizzes/") != nil {
            // we are grabbing this as the quizHostName because there are cases where the host changes from
            // the current logged-in host provided by the canvasAPI and this particular quiz. I have observed
            // this when a single account is associated with multiple domains.
            quizHostName = currentRequestHost!
        } else if navigationType == .LinkClicked {
            // TODO: maybe open a native in app browser?
            if let URL = request.URL {
                UIApplication.sharedApplication().openURL(URL)
            }
            return false
        }
        
        // if the user just finished logging in
        if queryString?.rangeOfString("login_success=1") != nil {
            finishedLoggingIn()
            return false
        }
        
        let isIframedOrOtherInternalContent = navigationType == UIWebViewNavigationType.Other && quizHostName != currentRequestHost!
        if loggingIn || queryString?.rangeOfString("persist_headless=1") != nil || isIframedOrOtherInternalContent {
            return true
        }
        
        // replace with the headless version of the same request.
        dispatchHeadlessVersionOfRequest(request)
        
        return false
    }
}
