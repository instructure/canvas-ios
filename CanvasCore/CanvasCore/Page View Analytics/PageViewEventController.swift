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
        guard NSClassFromString("EarlGreyImpl") == nil else { return }
        guard FeatureFlags.featureFlagEnabled(.pageViewLogging) else { return }
        guard let userID = CanvasKeymaster.the().currentClient?.currentUser.id else { return }
        
        var mutableAttributes = attributes?.convertToPageViewEventDictionary() ?? PageViewEventDictionary()
        if let url = cleanupUrl(url: eventNameOrPath, attributes: mutableAttributes), let codableUrl = try? CodableValue(url) {
            mutableAttributes["url"] = codableUrl
        }
        
        let event = PageViewEvent(eventName: eventNameOrPath, attributes: mutableAttributes, userID: userID, eventDuration: eventDurationInSeconds)
        Persistency.instance.addToQueue(event)
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
    
    fileprivate func enableAppLifeCycleNotifications(_ enable: Bool) {
        if enable {
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.didEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.appWillTerminate(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
            CanvasKeymaster.the().signalForLogout.subscribeNext({ [weak self] (_) in
                self?.sync()
            })
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    fileprivate func sync(_ handler: EmptyHandler? = nil) {
        sendEvents { error in
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
}

extension PageViewEventController {
    // TODO - send events here
    fileprivate func sendEvents(handler: ErrorHandler?) {
        //  let eventsToSync = Persistency.instance.batchOfEvents(3) // or use Persistency.instance.queueCount
        //  .... send events to server
        //  when successful response comes back, dequeue events from disk
        //  Persistency.isnstance.dequeue(3, handler: handler)
        handler?(nil)
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
        Persistency.instance.dequeue(Persistency.instance.queueCount, handler: {
            handler?()
        })
    }
}


