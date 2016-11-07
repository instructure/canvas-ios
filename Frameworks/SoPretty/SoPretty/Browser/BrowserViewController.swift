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
public class BrowserViewController: UIViewController {
    public static func presentFromViewController(viewController: UIViewController, completion: (()->())? = nil) -> BrowserViewController {
        let browser = BrowserViewController(nibName: nil, bundle: nil)
        let nav = UINavigationController(rootViewController: browser)
        
        viewController.presentViewController(nav, animated: true, completion: completion)
        return browser
    }
    
    public var url: NSURL? {
        didSet {
            if isViewLoaded() {
                if let url = url {
                    webView.loadRequest(NSURLRequest(URL: url))
                }
            }
        }
    }
    
    public var didSelectURLForSubmission: NSURL->() = { _ in }
    public var didCancel: ()->() = { }
    
    private var webView: WKWebView! {
        get {
            return view as! WKWebView
        }
    }
    
    private var tapoutView: UIView?
    private var editingURL: Bool = false {
        didSet {
            if editingURL {
                beginEditing()
            } else {
                endEditing()
            }
        }
    }
    
    private func endEditing() {
        titleView.resignFirstResponder()
        tapoutView?.removeFromSuperview()
        webView.scrollView.scrollEnabled = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Turn In", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Turn in this url button"), style: .Done, target: self, action: #selector(BrowserViewController.submit(_:)))
        navigationItem.rightBarButtonItem?.enabled = parseURLForInput(titleView.text) != nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(BrowserViewController.cancelTurnIn(_:)))
    }
    
    private func beginEditing() {
        installTapoutView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Go", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "navigate"), style: .Done, target: self, action: #selector(BrowserViewController.go(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(BrowserViewController.cancelEditingURL(_:)))
    }
    
    func go(sender: AnyObject?) {
        if let url: NSURL = parseURLForInput(titleView.text) {
            self.url = url
            titleView.resignFirstResponder()
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("The text you entered is not a valid URL", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "bad url message"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "dismiss error dialog"), style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func cancelEditingURL(sender: AnyObject?) {
        titleView.resignFirstResponder()
        titleView.text = currentWebviewURL?.absoluteString ?? url?.absoluteString ?? ""
    }
    
    private var currentWebviewURL: NSURL? {
        let url = webView.URL
        if url == NSURL(string: "about:blank") {
            return nil
        }
        return url
    }
    
    func submit(sender: AnyObject?) {
        let urlForSubmission = currentWebviewURL ?? parseURLForInput(titleView.text)
        if let url = urlForSubmission {
            dismissViewControllerAnimated(true) {
                self.didSelectURLForSubmission(url)
            }
        }
    }
    
    func cancelTurnIn(sender: AnyObject?) {
        dismissViewControllerAnimated(true) {
            self.didCancel()
        }
    }
    
    func installTapoutView() {
        tapoutView?.removeFromSuperview()
        
        // add a tap-out view
        let tapout = UIView()
        tapout.backgroundColor = UIColor.clearColor()
        tapout.frame = self.view.bounds
        
        webView.scrollView.scrollEnabled = false
        view.addSubview(tapout)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BrowserViewController.cancelEditingURL(_:)))
        tapout.addGestureRecognizer(tap)
        tapoutView = tapout
    }

    
    private lazy var titleView: UITextField = {
        let titleView = UITextField()
        titleView.borderStyle = .RoundedRect
        titleView.bounds = CGRectMake(0, 0, 160, 32)
        titleView.clearButtonMode = .Always
        // TODO: after merging into develop. white cursor is no bueno.
        // titleView.tintColor = Brand.current().tintColor
        titleView.tintColor = UIColor(red: 227/255.0, green:60/255.0, blue:41/255.0, alpha:1.0)
        titleView.returnKeyType = .Go
        titleView.delegate = self
        titleView.keyboardType = .URL
        titleView.autocapitalizationType = .None
        titleView.autocorrectionType = .No
        titleView.placeholder = NSLocalizedString("Enter URL...", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Placeholder for URL")
        
        return titleView
    }()
    
    public override func loadView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        if let url = url {
            webView.loadRequest(NSURLRequest(URL: url))
        } else {
            webView.loadHTMLString("<html><body></body></html>", baseURL: nil) // go nowhere to start
        }
        
        navigationItem.titleView = titleView
        view = webView
    }
    
    private func layoutNavBar(newViewWidth: CGFloat) {
        let viewWidth = newViewWidth - 200
        titleView.bounds = CGRectMake(0, 0, viewWidth, 32)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutNavBar(view.bounds.size.width)
        titleView.becomeFirstResponder()
    }

    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ _ in
            self.layoutNavBar(size.width)
        }, completion: nil)
    }
}


// MARK: text field delegate
extension BrowserViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(textField: UITextField) {
        editingURL = true
    }
    public func textFieldDidEndEditing(textField: UITextField) {
        editingURL = false
    }
    
    private func parseURLForInput(input: String?) -> NSURL? {
        guard let trimmed = input?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else { return nil }
        
        if let components = NSURLComponents(string: trimmed) {
            if components.scheme == nil {
                components.scheme = "http"
            }
            
            return components.URL
        }
        return nil
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        go(nil)
        return true
    }
}


// MARK: webview delegate

extension BrowserViewController: WKNavigationDelegate {
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        titleView.text = currentWebviewURL?.absoluteString ?? ""
    }
}


