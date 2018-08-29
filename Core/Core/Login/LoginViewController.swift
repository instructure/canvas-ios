//
//  LoginViewController.swift
//  CanvasCore
//
//  Created by Garrett Richards on 8/3/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit
import WebKit

protocol LoginViewControllerDelegate {
    func userDidLogin(authToken: String)
}

public class LoginViewController: UIViewController {
    var request: URLRequest?
    let method: AuthenticationMethod
    var webView: WKWebView!
    let presenter: LoginPresenter

    public init(host: String, method: AuthenticationMethod = .defaultMethod) {
        presenter = LoginPresenter(host: host)
        self.method = method
        super.init(nibName: "", bundle: nil)
        presenter.view = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        webView = WKWebView(frame: UIScreen.main.bounds)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor.white
        view = webView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default

        presenter.constructAuthenticationRequest(method: method)
    }
}

extension LoginViewController: LoginViewProtocol {
    func didConstructAuthenticationRequest(_ request: URLRequest) {
        self.request = request
        let req = LoginPresenter.prepLoginRequest(request, method: method)
        title = request.url?.host
        webView.load(req)
    }

    func userDidLogin(auth: APIOAuthToken) {
        print("auth token: \(auth.access_token)")
        navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController: ErrorViewController {
    func showError(_ error: NSError) {
        //  we're not really going to show errors here since it's kind of managed by the web
        print("error: \(error.localizedDescription)")
    }
}

extension LoginViewController: URLSessionTaskDelegate {
}

extension LoginViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let action = presenter.navigationActionPolicyForUrl(url: url)
        decisionHandler(action)
    }
}

extension LoginViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let newTab = !(navigationAction.targetFrame?.isMainFrame ?? false)
        if (newTab) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
