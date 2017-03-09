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
import TooLegit
import SoPersistent
import CoreData
import ReactiveSwift
import Marshal
import SoLazy

extension Page {
    public static func detailCacheKey(context: NSManagedObjectContext, contextID: ContextID, url: String) -> String {
        return cacheKey(context, [contextID.canvasContextID, url])
    }

    public static func invalidateDetailCache(session: Session, contextID: ContextID, url: String) throws {
        let context = try session.pagesManagedObjectContext()
        let key = detailCacheKey(context: context, contextID: contextID, url: url)
        session.refreshScope.invalidateCache(key)
    }

    public static func predicate(_ contextID: ContextID, url: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "contextID", contextID.canvasContextID, "url", url)
    }

    public static func frontPagePredicate(_ contextID: ContextID) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "contextID", contextID.canvasContextID, "frontPage", NSNumber(value: true))
    }

    public static func frontPageRefresher(_ session: Session, contextID: ContextID) throws -> Refresher {
        let context = try session.pagesManagedObjectContext()
        let remote = try Page.getFrontPage(session, contextID: contextID).map { [$0] }
        let pred = frontPagePredicate(contextID)
        let key = cacheKey(context, [contextID.canvasContextID, "&front_page"])
        let sync = Page.syncSignalProducer(pred, inContext: context, fetchRemote: remote) { page, json in
            page.contextID = contextID
            try page.updateValues(json, inContext: context)
        }

        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func refresher(_ session: Session, contextID: ContextID, url: String) throws -> Refresher {
        let context = try session.pagesManagedObjectContext()
        let remote = try Page.getPage(session, contextID: contextID, url: url).map { [$0] }
        let pred = predicate(contextID, url: url)
        let key = cacheKey(context, [contextID.canvasContextID, url])
        let sync = Page.syncSignalProducer(pred, inContext: context, fetchRemote: remote) { page, json in
            page.contextID = contextID
            try page.updateValues(json, inContext: context)
        }

        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func frontPageObserver(_ session: Session, contextID: ContextID) throws -> ManagedObjectObserver <Page> {
        let pred = Page.frontPagePredicate(contextID)
        let context = try session.pagesManagedObjectContext()
        return try ManagedObjectObserver<Page>(predicate: pred, inContext: context)
    }

    public static func observer(_ session: Session, contextID: ContextID, url: String) throws -> ManagedObjectObserver<Page> {
        let pred = Page.predicate(contextID, url: url)
        let context = try session.pagesManagedObjectContext()
        return try ManagedObjectObserver<Page>(predicate: pred, inContext: context)
    }


    open class FrontPageDetailViewController: DetailViewController {

        public init(session: Session, contextID: ContextID, route: @escaping (UIViewController, URL) -> ()) throws {
            try super.init(session: session, contextID: contextID, url: "", route: route)

            self.observer = try Page.frontPageObserver(session, contextID: contextID)
            self.refresher = try Page.frontPageRefresher(session, contextID: contextID)
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

    open class DetailViewController: UIViewController, UIWebViewDelegate {

        // MARK: - Properties

        open let webView = UIWebView(frame: CGRect.zero)

        open var refresher: Refresher
        open var observer: ManagedObjectObserver<Page>
        open let route: (UIViewController, URL) -> Void
        open let url: String
        open let contextID: ContextID
        open let session: Session

        // MARK: - Initializers

        public init(session: Session, contextID: ContextID, url: String, route: @escaping (UIViewController, URL) -> Void) throws {
            self.refresher = try Page.refresher(session, contextID: contextID, url: url)
            self.observer = try Page.observer(session, contextID: contextID, url: url)
            self.url = url
            self.contextID = contextID
            self.session = session
            self.route = route

            super.init(nibName: nil, bundle: nil)
        }


        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Lifecycle

        override open func viewDidLoad() {
            super.viewDidLoad()
            webView.delegate = self

            view.backgroundColor = .white

            configureObserver()
            configureRefresher()

            self.view.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["webView": webView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["webView": webView]))

            // Ensure that view doesn't hider under navbar
            self.automaticallyAdjustsScrollViewInsets = false
            self.edgesForExtendedLayout = UIRectEdge()

            if let page = observer.object {
                renderBodyForPage(page: page)
            }
        }

        open override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            refresher.refresh(false)
        }

        // MARK: - Helpers

        func showLockExplanation(lockExplanation: String?) {
            // Strip HTML tags from lock explanation
            var explanation = NSLocalizedString("This page is currently locked and not viewable.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.PageKit")!, value: "", comment: "The HTML page is currently not viewable by the user because it has been locked by the teacher.")
            if let encodedData = lockExplanation?.data(using: .utf8) {
                do {
                    explanation = try NSAttributedString(data: encodedData, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute:String.Encoding.utf8], documentAttributes: nil).string
                    explanation = explanation.replacingOccurrences(of: "\n", with: "")
                } catch { print("Error stripping HTML from lockedExplanation") }
            }

            webView.loadHTMLString("<i>\(explanation)</i>", baseURL: nil)
        }

        func configureObserver() {
            observer.signal.observe(on: UIScheduler()).observeValues { [weak self] change, page in
                switch change {
                case .insert, .update:
                    if let page = page, let me = self {
                        me.renderBodyForPage(page: page)
                    }
                case .delete: break
                }
            }
        }

        func configureRefresher() {
            refresher.refreshControl.addTarget(self, action: #selector(DetailViewController.refresh), for: UIControlEvents.valueChanged)
            webView.scrollView.addSubview(refresher.refreshControl)

            refresher.refreshingCompleted.observeValues { [weak self] error in
                ErrorReporter.reportError(error, from: self)
            }
        }

        func renderBodyForPage(page: Page) {
            guard !page.lockedForUser else {
                showLockExplanation(lockExplanation: page.lockExplanation)
                return
            }
            webView.loadHTMLString(PageTemplateRenderer.htmlStringForPage(page), baseURL: session.baseURL)
        }

        open func refresh() {
            refresher.refresh(true)
        }

        // MARK: - Web View Delegate

        open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            guard let requestURL = request.url else {
                print("No url provided in request")
                return false
            }
            
            if navigationType != .linkClicked {
                return true
            }

            if requestURL.scheme == "mailto" {
                return true
            }
            
            if requestURL.absoluteString.localizedCaseInsensitiveContains("slideshare.net") {
                var requestWithReferer = request
                requestWithReferer.url = requestURL
                requestWithReferer.setValue(session.baseURL.description, forHTTPHeaderField: "Referer")
                requestWithReferer.cachePolicy = .useProtocolCachePolicy
                self.relaunchRequest(requestWithReferer, webView: self.webView)
                return false
            }
            
            if requestURL.absoluteString.contains("external_tools/retrieve?") {
                return true
            }
            
            let components = requestURL.pathComponents
            if let component = components.last, let fragment = requestURL.fragment, components.count > 0 {
                let selfReferencingFragment = String(format: "%@#%@", session.baseURL.absoluteString, fragment)
                let jsScrollToAnchor = jsScrollToHashTag(fragment)
                
                if requestURL.absoluteString == selfReferencingFragment {
                    self.webView.stringByEvaluatingJavaScript(from: jsScrollToAnchor)
                    return false
                }
                
                let requestBaseURL = requestURL.deletingPathExtension().absoluteString
                if let currentBaseURL = URL(string: session.baseURL.absoluteString + self.contextID.htmlPath)?.absoluteString,
                    let currentAPIBaseURL = URL(string: session.baseURL.absoluteString + self.contextID.apiPath)?.absoluteString {
                    
                    if requestBaseURL.localizedCaseInsensitiveContains(currentBaseURL) || requestBaseURL.localizedCaseInsensitiveContains(currentAPIBaseURL) {
                        let pageIdentifierWithFragmentSymbol = self.url + "#"
                        if component.caseInsensitiveCompare(self.url) == .orderedSame || component.localizedCaseInsensitiveContains(pageIdentifierWithFragmentSymbol) {
                            webView.stringByEvaluatingJavaScript(from: jsScrollToAnchor)
                            return false
                        }
                    }
                }
            } else if let fragment = requestURL.fragment {
                let components = requestURL.pathComponents
                if (components.count == 0 && requestURL.scheme == "applewebdata") {
                    self.webView.stringByEvaluatingJavaScript(from: jsScrollToHashTag(fragment))
                    return false
                }
            }
            
            route(self, requestURL)
            return false
        }
        
        func jsScrollToHashTag(_ fragment: String) -> String {
            return String(format: "window.location.href='#%@';", fragment)
        }

        func relaunchRequest(_ request: URLRequest, webView: UIWebView) {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    self.webView.loadRequest(request as URLRequest)
                }
            }
        }
        
    }
    
}
