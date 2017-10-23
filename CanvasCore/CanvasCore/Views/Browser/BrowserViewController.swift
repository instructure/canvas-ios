//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import WebKit

/** This was built specifically for choosing a URL for assignment submission, but could be general purpose with a little love.
 */
open class BrowserViewController: UIViewController {
    open static func presentFromViewController(_ viewController: UIViewController, completion: (()->())? = nil) -> BrowserViewController {
        let browser = BrowserViewController(nibName: nil, bundle: nil)
        let nav = UINavigationController(rootViewController: browser)
        
        viewController.present(nav, animated: true, completion: completion)
        return browser
    }
    
    open var url: URL? {
        didSet {
            if isViewLoaded {
                if let url = url {
                    webView.load(URLRequest(url: url))
                }
            }
        }
    }
    
    open var didSelectURLForSubmission: (URL)->() = { _ in }
    open var didCancel: ()->() = { }
    
    fileprivate var webView: WKWebView! {
        get {
            return view as! WKWebView
        }
    }
    
    fileprivate var tapoutView: UIView?
    fileprivate var editingURL: Bool = false {
        didSet {
            if editingURL {
                beginEditing()
            } else {
                endEditing()
            }
        }
    }
    
    fileprivate func endEditing() {
        titleView.resignFirstResponder()
        tapoutView?.removeFromSuperview()
        webView.scrollView.isScrollEnabled = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Submit", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Turn in this url button"), style: .done, target: self, action: #selector(BrowserViewController.submit(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = parseURLForInput(titleView.text) != nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BrowserViewController.cancelTurnIn(_:)))
    }
    
    fileprivate func beginEditing() {
        installTapoutView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Go", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "navigate"), style: .done, target: self, action: #selector(BrowserViewController.go(_:)))
    }
    
    func go(_ sender: AnyObject?) {
        if let url: URL = parseURLForInput(titleView.text) {
            self.url = url
            titleView.resignFirstResponder()
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("The text you entered is not a valid URL", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "bad url message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Dismiss button for error alert"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func cancelEditingURL(_ sender: AnyObject?) {
        titleView.resignFirstResponder()
        titleView.text = currentWebviewURL?.absoluteString ?? url?.absoluteString ?? ""
    }
    
    fileprivate var currentWebviewURL: URL? {
        let url = webView.url
        if url == URL(string: "about:blank") {
            return nil
        }
        return url
    }
    
    func submit(_ sender: AnyObject?) {
        let urlForSubmission = currentWebviewURL ?? parseURLForInput(titleView.text)
        if let url = urlForSubmission {
            dismiss(animated: true) {
                self.didSelectURLForSubmission(url)
            }
        }
    }
    
    func cancelTurnIn(_ sender: AnyObject?) {
        dismiss(animated: true) {
            self.didCancel()
        }
    }
    
    func installTapoutView() {
        tapoutView?.removeFromSuperview()
        
        // add a tap-out view
        let tapout = UIView()
        tapout.backgroundColor = UIColor.clear
        tapout.frame = self.view.bounds
        
        webView.scrollView.isScrollEnabled = false
        view.addSubview(tapout)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BrowserViewController.cancelEditingURL(_:)))
        tapout.addGestureRecognizer(tap)
        tapoutView = tapout
    }

    
    fileprivate lazy var titleView: UITextField = {
        let titleView = UITextField()
        titleView.borderStyle = .roundedRect
        titleView.bounds = CGRect(x: 0, y: 0, width: 160, height: 32)
        titleView.clearButtonMode = .always
        // TODO: after merging into develop. white cursor is no bueno.
        // titleView.tintColor = Brand.current.tintColor
        titleView.tintColor = UIColor(red: 227/255.0, green:60/255.0, blue:41/255.0, alpha:1.0)
        titleView.returnKeyType = .go
        titleView.delegate = self
        titleView.keyboardType = .URL
        titleView.autocapitalizationType = .none
        titleView.autocorrectionType = .no
        titleView.placeholder = NSLocalizedString("Enter URL...", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Placeholder for URL")
        
        return titleView
    }()
    
    open override func loadView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            webView.loadHTMLString("<html><body></body></html>", baseURL: nil) // go nowhere to start
        }
        
        navigationItem.titleView = titleView
        view = webView
    }
    
    fileprivate func layoutNavBar(_ newViewWidth: CGFloat) {
        let viewWidth = newViewWidth - 200
        titleView.bounds = CGRect(x: 0, y: 0, width: viewWidth, height: 32)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutNavBar(view.bounds.size.width)
        titleView.becomeFirstResponder()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.layoutNavBar(size.width)
        }, completion: nil)
    }
}


// MARK: text field delegate
extension BrowserViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        editingURL = true
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        editingURL = false
    }
    
    fileprivate func parseURLForInput(_ input: String?) -> URL? {
        guard let trimmed = input?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return nil }
        
        if var components = URLComponents(string: trimmed) {
            if components.scheme == nil {
                components.scheme = "http"
            }
            
            return components.url
        }
        return nil
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        go(nil)
        return true
    }
}


// MARK: webview delegate

extension BrowserViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        titleView.text = currentWebviewURL?.absoluteString ?? ""
    }
}


