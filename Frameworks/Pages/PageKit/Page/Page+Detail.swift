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
import ReactiveCocoa
import Marshal

extension Page {

    public static func predicate(contextID: ContextID, url: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "contextID", contextID.canvasContextID, "url", url)
    }

    public static func frontPagePredicate(contextID: ContextID) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "contextID", contextID.canvasContextID, "frontPage", true)
    }

    public static func frontPageRefresher(session: Session, contextID: ContextID) throws -> Refresher {
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

    public static func refresher(session: Session, contextID: ContextID, url: String) throws -> Refresher {
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

    public static func frontPageObserver(session: Session, contextID: ContextID) throws -> ManagedObjectObserver <Page> {
        let pred = Page.frontPagePredicate(contextID)
        let context = try session.pagesManagedObjectContext()
        return try ManagedObjectObserver<Page>(predicate: pred, inContext: context)
    }

    public static func observer(session: Session, contextID: ContextID, url: String) throws -> ManagedObjectObserver<Page> {
        let pred = Page.predicate(contextID, url: url)
        let context = try session.pagesManagedObjectContext()
        return try ManagedObjectObserver<Page>(predicate: pred, inContext: context)
    }


    public class FrontPageDetailViewController: DetailViewController {

        public init(session: Session, contextID: ContextID, route: (UIViewController, NSURL) -> ()) throws {
            try super.init(session: session, contextID: contextID, url: "", route: route)

            self.observer = try Page.frontPageObserver(session, contextID: contextID)
            self.refresher = try Page.frontPageRefresher(session, contextID: contextID)
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

    public class DetailViewController: UIViewController, UIWebViewDelegate {

        // MARK: - Properties

        public let webView = UIWebView(frame: CGRectZero)

        public var refresher: Refresher
        public var observer: ManagedObjectObserver<Page>
        public let route: (UIViewController, NSURL) -> Void
        public let url: String
        public let contextID: ContextID
        public let session: Session

        // MARK: - Initializers

        public init(session: Session, contextID: ContextID, url: String, route: (UIViewController, NSURL) -> Void) throws {
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

        override public func viewDidLoad() {
            super.viewDidLoad()
            webView.delegate = self

            view.backgroundColor = .whiteColor()

            configureObserver()
            configureRefresher()

            refresher.refresh(false)

            self.view.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["webView": webView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["webView": webView]))

            // Ensure that view doesn't hider under navbar
            self.automaticallyAdjustsScrollViewInsets = false
            self.edgesForExtendedLayout = .None

            if let page = observer.object {
                renderBodyForPage(page)
                alertIfLocked(page)
            }
        }

        // MARK: - Helpers

        func alertIfLocked(page: Page) {
            if page.lockedForUser {
                // Strip HTML tags from lock explanation
                var explanation = NSLocalizedString("This page is currently locked and not viewable.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.PageKit")!, value: "", comment: "The HTML page is currently not viewable by the user because it has been locked by the teacher.")
                if let encodedData = page.lockExplanation?.dataUsingEncoding(NSUTF8StringEncoding) {
                    do {
                        explanation = try NSAttributedString(data: encodedData, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil).string
                        explanation = explanation.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions(), range: nil)
                    } catch { print("Error stripping HTML from lockedExplanation") }
                }

                UIAlertView(title: NSLocalizedString("Page Locked", comment: "The page is locked by the teacher"), message: explanation, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.PageKit")!, value: "", comment: "OK Button Title")).show()
            }
        }

        func configureObserver() {
            observer.signal.observeOn(UIScheduler()).observeNext { [weak self] change, page in
                switch change {
                case .Insert, .Update:
                    if let page = page, let me = self {
                        me.renderBodyForPage(page)
                    }
                case .Delete: break
                }
            }
        }

        func configureRefresher() {
            refresher.refreshControl.addTarget(self, action: #selector(DetailViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
            webView.scrollView.addSubview(refresher.refreshControl)

            refresher.refreshingCompleted.observeNext { [weak self] error in
                if let me = self, let error = error {
                    error.presentAlertFromViewController(me)
                }
            }
        }

        func renderBodyForPage(page: Page) {
            webView.loadHTMLString(PageTemplateRenderer.htmlStringForPage(page), baseURL: session.baseURL)
        }

        public func refresh() {
            refresher.refresh(true)
        }

        // MARK: - Web View Delegate

        public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            guard let requestURL = request.URL else {
                print("No url provided in request")
                return false
            }
            
            if navigationType != .LinkClicked {
                return true
            }

            if requestURL.scheme == "mailto" {
                return true
            }
            
            if requestURL.absoluteString!.localizedCaseInsensitiveContainsString("slideshare.net") {
                let requestWithReferer = request.mutableCopy() as! NSMutableURLRequest
                requestWithReferer.URL = requestURL
                requestWithReferer.setValue(session.baseURL.description, forHTTPHeaderField: "Referer")
                self.relaunchRequest(requestWithReferer, webView: self.webView)
                return false
            }
            
            if requestURL.absoluteString!.containsString("external_tools/retrieve?") {
                return true
            }
            
            if let components = requestURL.pathComponents, let component = components.last, fragment = requestURL.fragment where components.count > 0 {
                let selfReferencingFragment = String(format: "%@#%@", session.baseURL.absoluteString!, fragment)
                let jsScrollToAnchor = jsScrollToHashTag(fragment)
                
                if requestURL.absoluteString == selfReferencingFragment {
                    self.webView.stringByEvaluatingJavaScriptFromString(jsScrollToAnchor)
                    return false
                }
                
                if let requestBaseURL = requestURL.URLByDeletingPathExtension?.absoluteString,
                    let currentBaseURL = NSURL(string: session.baseURL.absoluteString! + self.contextID.htmlPath)?.absoluteString,
                    let currentAPIBaseURL = NSURL(string: session.baseURL.absoluteString! + self.contextID.apiPath)?.absoluteString {
                    
                    if requestBaseURL.localizedCaseInsensitiveContainsString(currentBaseURL) || requestBaseURL.localizedCaseInsensitiveContainsString(currentAPIBaseURL) {
                        let pageIdentifierWithFragmentSymbol = self.url.stringByAppendingString("#")
                        if component.caseInsensitiveCompare(self.url) == .OrderedSame || component.localizedCaseInsensitiveContainsString(pageIdentifierWithFragmentSymbol) {
                            webView.stringByEvaluatingJavaScriptFromString(jsScrollToAnchor)
                            return false
                        }
                    }
                }
            } else if let fragment = requestURL.fragment, let components = requestURL.pathComponents {
                if (components.count == 0 && requestURL.scheme == "applewebdata") {
                    self.webView.stringByEvaluatingJavaScriptFromString(jsScrollToHashTag(fragment))
                    return false
                }
            }
            
            route(self, requestURL)
            return false
        }
        
        func jsScrollToHashTag(fragment: String) -> String {
            return String(format: "window.location.href='#%@';", fragment)
        }

        func relaunchRequest(request: NSMutableURLRequest, webView: UIWebView) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    request.cachePolicy = .UseProtocolCachePolicy
                    self.webView.loadRequest(request)
                }
            }
        }
        
    }
    
}
