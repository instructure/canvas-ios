
//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import UIKit
import TooLegit
import SoPretty
import CFNetwork

class WebBrowserViewController: UIViewController {

    // MARK: Important stuffs
    var request: NSURLRequest?
    var url: NSURL? {
        didSet {
            if let url = url {
                self.request = NSURLRequest.requestWithDefaultHTTPHeaders(url)
            }
        }
    }

    let useAPISafeLinks: Bool
    let isModal: Bool

    // MARK: Private stuffs
    // MARK: Outlets
    private var webView = UIWebView()
    private var titleField = UITextField()

    private var doneButton: UIBarButtonItem!
    private var reloadButton: UIBarButtonItem!
    private var activityItem: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var actionButton: UIBarButtonItem!

    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    private var networkOps: UInt = 0
    private var fullURLString: String?
    private var hostURLString: String?
    private var fileURLString: String?
    private var isTitleAbreviated: Bool = true
    private var isAnimatingTitle: Bool = false

    init(useAPISafeLinks: Bool = true, isModal: Bool = true) {
        self.useAPISafeLinks = useAPISafeLinks
        self.isModal = isModal
        super.init(nibName: nil, bundle: nil)

        self.doneButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Close Button Title"), style: .Plain, target: self, action: #selector(WebBrowserViewController.doneButtonTapped(_:)))
        self.reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(WebBrowserViewController.reloadButtonTapped(_:)))
        self.activityItem = UIBarButtonItem(customView: activityIndicator)
        self.stopButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(WebBrowserViewController.stopButtonTapped(_:)))
        self.backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(WebBrowserViewController.backButtonTapped(_:)))
        self.forwardButton = UIBarButtonItem(image: UIImage(named: "forward"), style: .Plain, target: self, action: #selector(WebBrowserViewController.forwardButtonTapped(_:)))
        self.actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(WebBrowserViewController.actionButtonTapped(_:)))

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpace.width = 20
        self.toolbarItems = [backButton, fixedSpace, forwardButton, UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), actionButton]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let fileURLString = fileURLString {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(fileURLString)
            } catch {
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.toolbarHidden = false
        if isModal {
            navigationItem.leftBarButtonItem = doneButton
        }
        navigationItem.rightBarButtonItems = [reloadButton]
        navigationItem.title = ""
        navigationItem.titleView = titleField

        webView.delegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scalesPageToFit = true
        view.addSubview(webView)

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView": webView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView": webView]))

        if let request = self.request {
            webView.loadRequest(request)
        }
        edgesForExtendedLayout = .None

        view.backgroundColor = UIColor.prettyBlack()
        titleField.textColor = self.navigationController?.navigationBar.barStyle == .Black ? UIColor.whiteColor() : UIColor.darkTextColor()
        titleField.backgroundColor = UIColor.clearColor()
        titleField.borderStyle = .None
        titleField.tintColor = Brand.current().tintColor
        titleField.returnKeyType = .Go
        titleField.delegate = self

        var frame = titleField.frame
        frame.size.height = 30
        titleField.frame = frame

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebBrowserViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WebBrowserViewController.webViewTapped(_:)))
        webView.addGestureRecognizer(tapGesture)
    }

    // MARK: Handlers
    func doneButtonTapped(doneButton: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true) { [weak self] in
            self?.webView.loadHTMLString("", baseURL: nil)
        }
    }

    func backButtonTapped(backButton: UIBarButtonItem) {
        guard webView.canGoBack else { return }

        networkOps = 0
        webView.goBack()
    }

    func forwardButtonTapped(forwardButton: UIBarButtonItem) {
        guard webView.canGoForward else { return }

        networkOps = 0
        webView.goForward()
    }

    func reloadButtonTapped(refreshButton: UIBarButtonItem) {
        networkOps = 0
        if let request = webView.request where request.URL?.absoluteString?.characters.count > 0 && request.URL?.absoluteString != "about:blank" {
            webView.reload()
        } else {
            if let request = self.request {
                webView.loadRequest(request)
            }
        }
    }

    func actionButtonTapped(actionButton: UIBarButtonItem) {
        let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        if let fullURLString = fullURLString, url = NSURL(string: fullURLString) where request?.URL?.fileURL == false {
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment: "Open a url in the application Safari"), style: .Default) { action in
                UIApplication.sharedApplication().openURL(url)
            })
        }

        if let fileURLString = fileURLString, fileURL = NSURL(string: fileURLString) {
            let dic = UIDocumentInteractionController(URL: fileURL)
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Open in...", comment: "Open file in another application"), style: .Default) { [weak dic, weak self] action in
                let presentedOpenInMenu = dic?.presentOpenInMenuFromBarButtonItem(actionButton, animated: true)
                if presentedOpenInMenu == false {
                    let errorSheet = UIAlertController(title: NSLocalizedString("No installed apps support opening this file", comment: "Error message"), message: nil, preferredStyle: .ActionSheet)
                    errorSheet.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .Default) { _ in })
                    self?.presentViewController(errorSheet, animated: true, completion: nil)
                }
            })
        }

        if actionSheet.actions.count == 0  {
            actionSheet.title = NSLocalizedString("There are no actions for this item", comment: "Error message")
        }

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .Cancel) { _ in })

        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.barButtonItem = actionButton
        presentViewController(actionSheet, animated: true, completion: nil)
    }

    func stopButtonTapped(stopButton: UIBarButtonItem) {
        networkOps = 0
        webView.stopLoading()
    }

    func webViewTapped(tapGesture: UITapGestureRecognizer) {
        if !isTitleAbreviated {
            toggleTitleDisplayState()
            titleField.resignFirstResponder()
        }
    }
}

// MARK: - UIWebViewDelegate
extension WebBrowserViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        fullURLString = request.URL?.absoluteString
        hostURLString = request.URL?.host

        if isTitleAbreviated {
            titleField.text = hostURLString
        } else {
            titleField.text = fullURLString
            toggleTitleDisplayState()
        }

        // TODO: NSURLConnection???

        return true
    }

    func webViewDidStartLoad(webView: UIWebView) {
        networkOps += 1

        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward

        if networkOps == 1 {
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItems = [stopButton, activityItem]
            actionButton.enabled = false
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        backButton.enabled = webView.canGoBack
        fullURLString = webView.request?.URL?.absoluteString
        // Show the title of the document.
        if let url = webView.request?.URL where url.fileURL == true {
            navigationItem.title = webView.request?.URL?.lastPathComponent
        } else {
            let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
            titleField.text = title
            hostURLString = title
        }

        if networkOps > 0 { networkOps -= 1 }
        if networkOps == 0 {
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItems = [reloadButton]
            actionButton.enabled = true
        }

        UIView.animateWithDuration(0.3) {
            if let text = self.titleField.text, font = self.titleField.font where text.characters.count > 0 {
                let size = (text as NSString).sizeWithAttributes([NSFontAttributeName: font])
                let x: CGFloat = (self.view.frame.size.width - CGFloat(roundf(Float(size.width))) * 0.5)
                let width: CGFloat = CGFloat(roundf(Float(size.width)))
                self.titleField.frame = CGRect(x: x, y: self.titleField.frame.origin.y, width: width, height: self.titleField.frame.size.height)
            }
        }

        let html = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")
        if html == "Could not find download URL" {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("There was an error loading your content. If it  is an audio or video upload it may still be processing.", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }

        if useAPISafeLinks {
            webView.replaceHREFsWithAPISafeURLs()
        }
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if networkOps > 0 { networkOps -= 1 }
        if networkOps == 0 {
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItems = [reloadButton]
            actionButton.enabled = true
        }

        if let error = error where error.code != Int(CFNetworkErrors.CFURLErrorCancelled.rawValue) {
            if error.code == 204 && error.userInfo[NSURLErrorFailingURLStringErrorKey] != nil {
                // Handle Kaltura media
                // 204 is "Plug-in handled load", meaning it was handled outside the webview. Just let it be.
                return
            } else {
                webView.loadHTMLString("<html><body style=\"font-family:sans-serif;font-size:30px;text-align:center;color:#555;padding:5px;\">There was an error loading the document.</body></html>", baseURL: nil)
            }
        }
    }

    func downloadFile(atURL url: NSURL) {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let downloadTask = session.dataTaskWithURL(url) { data, response, error in
            let filename = response?.suggestedFilename ?? "file"
            guard let url = NSURL.fileURLWithPath(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]).URLByAppendingPathComponent(filename) else { return }
            let _ = try? data?.writeToURL(url, options: NSDataWritingOptions.DataWritingAtomic)
            self.fileURLString = url.absoluteString
        }
        downloadTask.resume()
    }
}

// MARK: - UITextFieldDelegate
extension WebBrowserViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        toggleTitleDisplayState()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = titleField.text, url = NSURL(string: text) {
            self.url = url
            if let request = self.request {
                webView.loadRequest(request)
            }
        }
        titleField.resignFirstResponder()
        return true
    }

    func toggleTitleDisplayState() {
        guard !isAnimatingTitle else { return }
        defer { isTitleAbreviated = !isTitleAbreviated }

        isAnimatingTitle = true

        if isTitleAbreviated {
            titleField.text = fullURLString
            titleField.borderStyle = .RoundedRect
            UIView.animateWithDuration(0.3, animations: {
                self.titleField.frame = CGRect(x: 0, y: self.titleField.frame.origin.y, width: self.view.frame.size.width, height: self.titleField.frame.size.height)
                self.titleField.backgroundColor = UIColor.whiteColor()
                self.titleField.textColor = UIColor.darkTextColor()
            }, completion: { _ in
                self.isAnimatingTitle = false
            })
        } else {
            titleField.text = hostURLString
            UIView.animateWithDuration(0.3, animations: {
                if let hostURLString = self.hostURLString, font = self.titleField.font {
                    let size = (hostURLString as NSString).sizeWithAttributes([NSFontAttributeName: font])
                    let x: CGFloat = (self.view.frame.size.width - CGFloat(roundf(Float(size.width))) * 0.5)
                    let width: CGFloat = CGFloat(roundf(Float(size.width)))
                    self.titleField.frame = CGRect(x: x, y: self.titleField.frame.origin.y, width: width, height: self.titleField.frame.size.height)
                    self.titleField.backgroundColor = UIColor.clearColor()
                    self.titleField.textColor = self.navigationController?.navigationBar.barStyle == .Black ? UIColor.whiteColor() : UIColor.darkTextColor()
                }
            }, completion: { _ in
                self.isAnimatingTitle = false
                self.titleField.borderStyle = .None
            })

            self.titleField.resignFirstResponder()
        }
    }
}

// MARK: - Keyboard Notifications
extension WebBrowserViewController {
    func keyboardWillHide(note: NSNotification) {
        if !isTitleAbreviated {
            toggleTitleDisplayState()
        }
    }
}
