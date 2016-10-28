//
//  CanvasObserverLoginViewController.swift
//  Parent
//
//  Created by Derrick Hathaway on 10/19/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoPretty
import SoLazy
import ReactiveCocoa
import Airwolf
import TooLegit
import Marshal

class CanvasObserverLoginViewController: WebLoginViewController, UIWebViewDelegate {
    let loginSuccess: (Session)->()
    
    init(domain: String, loginSuccess: (Session)->()) {
        self.loginSuccess = loginSuccess
        super.init(request: AirwolfAPI.authenticateAsCanvasObserver(domain), useBackButton: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Just can't do it. sorry."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prompt = NSLocalizedString("Enter your Canvas Observer credentials", comment: "prompt for canvas observer login page")
        webView.delegate = self
    }
    
    func somethingWentWrong(error: NSError) {
        error.report(false, alertUserFrom: self)
        startLoginRequest()
    }
    
    var jsonBodyData: NSData? {
        return webView.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('pre')[0].innerHTML")?.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    // MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let url = request.URL where url.path == "/canvas/tokenReady" else { return true }
        guard let host = request.URL?.host, baseURL = NSURL(string: "https://\(host)") else { return true }
        guard let token = url.queryItemForKey("token")?.value else { return true }
        guard let parentID = url.queryItemForKey("parent_id")?.value else { return true }
        
        let sessionUser = SessionUser(id: parentID, name: "")
        let session = Session(baseURL: baseURL, user: sessionUser, token: token)
        webView.hidden = true
        loginSuccess(session)
        
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        somethingWentWrong(error)
    }
}
