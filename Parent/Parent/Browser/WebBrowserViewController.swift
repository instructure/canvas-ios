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
import CFNetwork
import CanvasCore

class WebBrowserViewController: UIViewController {

    // MARK: Important stuffs
    var request: URLRequest?
    var url: URL? {
        didSet {
            if let url = url {
                self.request = URLRequest.requestWithDefaultHTTPHeaders(url)
            }
        }
    }

    let useAPISafeLinks: Bool
    let isModal: Bool

    // MARK: Private stuffs
    // MARK: Outlets
    fileprivate var webView = UIWebView()
    fileprivate var titleField = UITextField()

    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var reloadButton: UIBarButtonItem!
    fileprivate var activityItem: UIBarButtonItem!
    fileprivate var stopButton: UIBarButtonItem!
    fileprivate var backButton: UIBarButtonItem!
    fileprivate var forwardButton: UIBarButtonItem!
    fileprivate var actionButton: UIBarButtonItem!

    fileprivate var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    fileprivate var networkOps: UInt = 0
    fileprivate var fullURLString: String?
    fileprivate var hostURLString: String?
    fileprivate var fileURLString: String?
    fileprivate var isTitleAbreviated: Bool = true
    fileprivate var isAnimatingTitle: Bool = false

    init(useAPISafeLinks: Bool = true, isModal: Bool = true) {
        self.useAPISafeLinks = useAPISafeLinks
        self.isModal = isModal
        super.init(nibName: nil, bundle: nil)

        self.doneButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Close Button Title"), style: .plain, target: self, action: #selector(WebBrowserViewController.doneButtonTapped(_:)))
        self.reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(WebBrowserViewController.reloadButtonTapped(_:)))
        self.activityItem = UIBarButtonItem(customView: activityIndicator)
        self.stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(WebBrowserViewController.stopButtonTapped(_:)))
        self.backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(WebBrowserViewController.backButtonTapped(_:)))
        self.forwardButton = UIBarButtonItem(image: UIImage(named: "forward"), style: .plain, target: self, action: #selector(WebBrowserViewController.forwardButtonTapped(_:)))
        self.actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WebBrowserViewController.actionButtonTapped(_:)))

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 20
        self.toolbarItems = [backButton, fixedSpace, forwardButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), actionButton]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let fileURLString = fileURLString {
            do {
                try FileManager.default.removeItem(atPath: fileURLString)
            } catch {
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isToolbarHidden = false
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

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView": webView]))

        if let request = self.request {
            webView.loadRequest(request)
        }
        edgesForExtendedLayout = UIRectEdge()

        view.backgroundColor = UIColor.prettyBlack()
        titleField.textColor = self.navigationController?.navigationBar.barStyle == .black ? UIColor.white : UIColor.darkText
        titleField.backgroundColor = UIColor.clear
        titleField.borderStyle = .none
        titleField.tintColor = Brand.current.tintColor
        titleField.returnKeyType = .go
        titleField.delegate = self

        var frame = titleField.frame
        frame.size.height = 30
        titleField.frame = frame

        NotificationCenter.default.addObserver(self, selector: #selector(WebBrowserViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WebBrowserViewController.webViewTapped(_:)))
        webView.addGestureRecognizer(tapGesture)
    }

    // MARK: Handlers
    func doneButtonTapped(_ doneButton: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.webView.loadHTMLString("", baseURL: nil)
        }
    }

    func backButtonTapped(_ backButton: UIBarButtonItem) {
        guard webView.canGoBack else { return }

        networkOps = 0
        webView.goBack()
    }

    func forwardButtonTapped(_ forwardButton: UIBarButtonItem) {
        guard webView.canGoForward else { return }

        networkOps = 0
        webView.goForward()
    }

    func reloadButtonTapped(_ refreshButton: UIBarButtonItem) {
        networkOps = 0
        if let request = webView.request, (request.url?.absoluteString.characters.count)! > 0 && request.url?.absoluteString != "about:blank" {
            webView.reload()
        } else {
            if let request = self.request {
                webView.loadRequest(request)
            }
        }
    }

    func actionButtonTapped(_ actionButton: UIBarButtonItem) {
        let title = webView.stringByEvaluatingJavaScript(from: "document.title")
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        if let fullURLString = fullURLString, let url = URL(string: fullURLString), request?.url?.isFileURL == false {
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment: "Open a url in the application Safari"), style: .default) { action in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }

        if let fileURLString = fileURLString, let fileURL = URL(string: fileURLString) {
            let dic = UIDocumentInteractionController(url: fileURL)
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Open in...", comment: "Open file in another application"), style: .default) { [weak dic, weak self] action in
                let presentedOpenInMenu = dic?.presentOpenInMenu(from: actionButton, animated: true)
                if presentedOpenInMenu == false {
                    let errorSheet = UIAlertController(title: NSLocalizedString("No installed apps support opening this file", comment: "Error message"), message: nil, preferredStyle: .actionSheet)
                    errorSheet.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default) { _ in })
                    self?.present(errorSheet, animated: true, completion: nil)
                }
            })
        }

        if actionSheet.actions.count == 0  {
            actionSheet.title = NSLocalizedString("There are no actions for this item", comment: "Error message")
        }

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel) { _ in })

        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.barButtonItem = actionButton
        present(actionSheet, animated: true, completion: nil)
    }

    func stopButtonTapped(_ stopButton: UIBarButtonItem) {
        networkOps = 0
        webView.stopLoading()
    }

    func webViewTapped(_ tapGesture: UITapGestureRecognizer) {
        if !isTitleAbreviated {
            toggleTitleDisplayState()
            titleField.resignFirstResponder()
        }
    }
}

// MARK: - UIWebViewDelegate
extension WebBrowserViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        fullURLString = request.url?.absoluteString
        hostURLString = request.url?.host

        if isTitleAbreviated {
            titleField.text = hostURLString
        } else {
            titleField.text = fullURLString
            toggleTitleDisplayState()
        }

        // TODO: URLConnection???

        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        networkOps += 1

        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward

        if networkOps == 1 {
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItems = [stopButton, activityItem]
            actionButton.isEnabled = false
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        backButton.isEnabled = webView.canGoBack
        fullURLString = webView.request?.url?.absoluteString
        // Show the title of the document.
        if let url = webView.request?.url, url.isFileURL == true {
            navigationItem.title = webView.request?.url?.lastPathComponent
        } else {
            let title = webView.stringByEvaluatingJavaScript(from: "document.title")
            titleField.text = title
            hostURLString = title
        }

        if networkOps > 0 { networkOps -= 1 }
        if networkOps == 0 {
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItems = [reloadButton]
            actionButton.isEnabled = true
        }

        UIView.animate(withDuration: 0.3, animations: {
            if let text = self.titleField.text, let font = self.titleField.font, text.characters.count > 0 {
                let size = (text as NSString).size(attributes: [NSFontAttributeName: font])
                let x: CGFloat = (self.view.frame.size.width - CGFloat(roundf(Float(size.width))) * 0.5)
                let width: CGFloat = CGFloat(roundf(Float(size.width)))
                self.titleField.frame = CGRect(x: x, y: self.titleField.frame.origin.y, width: width, height: self.titleField.frame.size.height)
            }
        }) 

        let html = webView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")
        if html == "Could not find download URL" {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("There was an error loading your content. If it  is an audio or video upload it may still be processing.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        if useAPISafeLinks {
            webView.replaceHREFsWithAPISafeURLs()
        }
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let error = error as NSError
        if networkOps > 0 { networkOps -= 1 }
        if networkOps == 0 {
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItems = [reloadButton]
            actionButton.isEnabled = true
        }

        if error.code != Int(CFNetworkErrors.cfurlErrorCancelled.rawValue) {
            if error.code == 204 && error.userInfo[NSURLErrorFailingURLErrorKey] != nil {
                // Handle Kaltura media
                // 204 is "Plug-in handled load", meaning it was handled outside the webview. Just let it be.
                return
            } else {
                webView.loadHTMLString("<html><body style=\"font-family:sans-serif;font-size:30px;text-align:center;color:#555;padding:5px;\">There was an error loading the document.</body></html>", baseURL: nil)
            }
        }
    }

    func downloadFile(atURL url: URL) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let downloadTask = session.dataTask(with: url) { data, response, error in
            let filename = response?.suggestedFilename ?? "file"
            let url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(filename)
            let _ = try? data?.write(to: url, options: .atomic)
            self.fileURLString = url.absoluteString
        }
        downloadTask.resume()
    }
}

// MARK: - UITextFieldDelegate
extension WebBrowserViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleTitleDisplayState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = titleField.text, let url = URL(string: text) {
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
            titleField.borderStyle = .roundedRect
            UIView.animate(withDuration: 0.3, animations: {
                self.titleField.frame = CGRect(x: 0, y: self.titleField.frame.origin.y, width: self.view.frame.size.width, height: self.titleField.frame.size.height)
                self.titleField.backgroundColor = UIColor.white
                self.titleField.textColor = UIColor.darkText
            }, completion: { _ in
                self.isAnimatingTitle = false
            })
        } else {
            titleField.text = hostURLString
            UIView.animate(withDuration: 0.3, animations: {
                if let hostURLString = self.hostURLString, let font = self.titleField.font {
                    let size = (hostURLString as NSString).size(attributes: [NSFontAttributeName: font])
                    let x: CGFloat = (self.view.frame.size.width - CGFloat(roundf(Float(size.width))) * 0.5)
                    let width: CGFloat = CGFloat(roundf(Float(size.width)))
                    self.titleField.frame = CGRect(x: x, y: self.titleField.frame.origin.y, width: width, height: self.titleField.frame.size.height)
                    self.titleField.backgroundColor = UIColor.clear
                    self.titleField.textColor = self.navigationController?.navigationBar.barStyle == .black ? UIColor.white : UIColor.darkText
                }
            }, completion: { _ in
                self.isAnimatingTitle = false
                self.titleField.borderStyle = .none
            })

            self.titleField.resignFirstResponder()
        }
    }
}

// MARK: - Keyboard Notifications
extension WebBrowserViewController {
    func keyboardWillHide(_ note: Notification) {
        if !isTitleAbreviated {
            toggleTitleDisplayState()
        }
    }
}
