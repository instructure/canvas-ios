//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import CanvasKeymaster

typealias ErrorHandler = (Error?) -> Void

@objc(PageViewEventController)
open class PageViewEventController: NSObject {
    open static let instance = PageViewEventController()
    private var requestManager = PageViewEventRequestManager()
    private let session = PageViewSession()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        enableAppLifeCycleNotifications(true)
    }
    
    //  MARK: - Public
    func logPageView(_ eventNameOrPath: String, attributes: [String: Any]? = nil, eventDurationInSeconds: TimeInterval = 0) {
        if(!appCanLogEvents()) { return }
        guard let userID = CanvasKeymaster.the().currentClient?.currentUser.id else { return }
        
        var mutableAttributes = attributes?.convertToPageViewEventDictionary() ?? PageViewEventDictionary()
        mutableAttributes["session_id"] = try? CodableValue(session.ID)
        mutableAttributes["app_name"] = try? CodableValue("Canvas Student for iOS")
        mutableAttributes["user_id"] = try? CodableValue(userID)
        mutableAttributes["agent"] = try? CodableValue(CanvasCore.defaultHTTPHeaders["User-Agent"] ?? "Unknown")
        if let masqueradeID = CanvasKeymaster.the().currentClient?.actAsUserID, let originalUserID = CanvasKeymaster.the().currentClient?.originalIDOfMasqueradingUser {
            mutableAttributes["user_id"] = try? CodableValue(masqueradeID)
            mutableAttributes["real_user_id"] = try? CodableValue(originalUserID)
        }
        if let url = cleanupUrl(url: eventNameOrPath, attributes: mutableAttributes), let codableUrl = try? CodableValue(url) {
            mutableAttributes["url"] = codableUrl
            if let parsedUrlPieces = parsePageViewParts(url) {
                mutableAttributes["domain"] = try? CodableValue(parsedUrlPieces.domain)
                mutableAttributes["context_type"] = try? CodableValue(parsedUrlPieces.context)
                mutableAttributes["context_id"] = try? CodableValue(parsedUrlPieces.contextID)
            }
        }
        
        let event = PageViewEvent(eventName: eventNameOrPath, attributes: mutableAttributes, userID: userID, eventDuration: eventDurationInSeconds)
        Persistency.instance.addToQueue(event)
    }

    public func userDidChange() {
        sync({ [weak self] in
            self?.requestManager.cleanup()
            self?.session.resetSessionInfo()
        })
    }

    //  MARK: - App Lifecycle
    
    @objc private func didEnterBackground(_ notification: Notification) {
        sync()
    }
    
    @objc private func willEnterForeground(_ notification: Notification) {
        Persistency.instance.restoreQueuedEventsFromFile()
    }
    
    @objc private func appWillTerminate(_ notification: Notification) {
        sync()
    }
    
    //  MARK: - Helpers
    
    fileprivate func appCanLogEvents() -> Bool {
        let isNotTest = NSClassFromString("EarlGreyImpl") == nil
        let isStudent = NativeLoginManager.shared().app == CanvasApp.student
        return isNotTest && isStudent
    }
    
    fileprivate func enableAppLifeCycleNotifications(_ enable: Bool) {
        if enable {
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.didEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.appWillTerminate(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    fileprivate func sync(_ handler: EmptyHandler? = nil) {
        if(!appCanLogEvents()) { handler?(); return }
        requestManager.sendEvents { error in
            handler?()
        }
    }
    
    private func cleanupUrl(url: String, attributes: PageViewEventDictionary?) -> String? {
        var path: String? = clipRnSpecialCaseSuffix(path: url)
        path = populatePlaceholderUrl(urlWithPlaceholders: path, params: attributes)
        path = path?.pruneApiVersionFromPath()
        return path
    }
    
    func clipRnSpecialCaseSuffix(path: String) -> String {
        guard let url = URL(string: path) else { return path }
        if(url.pathComponents.last == "rn") {
            return (path as NSString).deletingLastPathComponent
        }
        return path
    }
    
    private func populatePlaceholderUrl(urlWithPlaceholders: String?, params: PageViewEventDictionary?) -> String? {
        guard let baseURL = CanvasKeymaster.the().currentClient?.baseURL,
            let urlWithPlaceholders = urlWithPlaceholders
            else { return nil }
        var path = urlWithPlaceholders
        if let customPageViewPath = params?[PropKeys.customPageViewPath]?.description { path = customPageViewPath }
        if let paramterizedUrl = path.populatePathWithParams(params) {
            path = paramterizedUrl
        }
        if (path.hasPrefix("/")) {
            path = String(path.dropFirst())
        }
        //  return url if it's already a full url
        if let isFullyQualifiedUrl = URL(string: urlWithPlaceholders), isFullyQualifiedUrl.scheme == "http" || isFullyQualifiedUrl.scheme == "https" {
            return urlWithPlaceholders
        }
        
        return baseURL.appendingPathComponent(path).absoluteString
    }
    
    private enum Context: String {
        case courses = "courses"
        case groups = "groups"
        case users = "users"
        case accounts = "accounts"
        
        func properName() -> String {
            switch(self) {
            case .courses:
                return "Course"
            case .groups:
                return "Group"
            case .users:
                return "User"
            case .accounts:
                return "Account"
            }
         }
    }
    
    private func parsePageViewParts(_ url: String) -> (domain: String?, context: String?, contextID: String?)? {
        guard let urlObj = URL(string: url) else { return nil }
        let comps = urlObj.pathComponents
        let host = urlObj.host
        var context: String? = nil
        var contextID: String? = nil
        for i in 0..<comps.count {
            if let c = Context(rawValue: comps[i]) {
                context = c.properName()
                if(i + 1 < comps.count) {
                    contextID = comps[i+1]
                }
                break
            }
        }
        return (host, context, contextID)
    }
}

// MARK: - RN Logger methods
extension PageViewEventController {
    open func allEvents() -> String {
        let count = Persistency.instance.queueCount
        let events = Persistency.instance.batchOfEvents(count)
        let defaultReturnValue = "[]"
        guard let encodedData = try? JSONEncoder().encode(events) else {
            return defaultReturnValue
        }
        return String(data: encodedData, encoding: .utf8) ?? defaultReturnValue
    }

    //  MARK: - Dev menu
    open func clearAllEvents(handler: (() -> Void)?) {
        Persistency.instance.dequeue(Persistency.instance.queueCount) {
            handler?()
        }
    }
}



