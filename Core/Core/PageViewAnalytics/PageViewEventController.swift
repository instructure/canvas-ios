//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

typealias ErrorHandler = (Error?) -> Void

@objc(PageViewEventController)
public class PageViewEventController: NSObject {

    public struct Constants {
        public static let customPageViewPath = "customPageViewPath"
    }

    @objc public static let instance = PageViewEventController()
    private var requestManager = PageViewEventRequestManager()
    private let session = PageViewSession()
    var persistency: Persistency = Persistency.instance
    var appCanLogEvents: () -> Bool = {
        let isNotTest = !ProcessInfo.isUITest
        let isStudent = Bundle.main.isStudentApp
        return isNotTest && isStudent
    }

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

    // MARK: - Public
    @objc func logPageView(_ eventNameOrPath: String, attributes: [String: String] = [:], eventDurationInSeconds: TimeInterval = 0) {
        if(!appCanLogEvents()) { return }
        guard let authSession = Keychain.mostRecentSession else { return }

        let userID = authSession.userID
        var mutableAttributes = attributes
        mutableAttributes["session_id"] = session.ID
        mutableAttributes["app_name"] = "Canvas Student for iOS"
        mutableAttributes["user_id"] = userID
        mutableAttributes["agent"] = UserAgent.default.description
        if let masqueradeID = authSession.actAsUserID {
            mutableAttributes["user_id"] = masqueradeID
            mutableAttributes["real_user_id"] = userID
        }
        if let url = cleanupUrl(url: eventNameOrPath, attributes: mutableAttributes) {
            mutableAttributes["url"] = url
            if let parsedUrlPieces = parsePageViewParts(url) {
                mutableAttributes["domain"] = parsedUrlPieces.domain ?? authSession.baseURL.host
                mutableAttributes["context_type"] = parsedUrlPieces.context
                mutableAttributes["context_id"] = parsedUrlPieces.contextID
            }
        }

        let event = PageViewEvent(eventName: eventNameOrPath, attributes: mutableAttributes, userID: userID, eventDuration: eventDurationInSeconds)
        persistency.addToQueue(event)
    }

    @objc public func userDidChange() {
        sync({ [weak self] in
            self?.requestManager.cleanup()
            self?.session.resetSessionInfo()
        })
    }

    // MARK: - App Lifecycle

    @objc private func didEnterBackground(_ notification: Notification) {
        sync()
    }

    @objc private func willEnterForeground(_ notification: Notification) {
        persistency.restoreQueuedEventsFromFile()
    }

    @objc private func appWillTerminate(_ notification: Notification) {
        sync()
    }

    // MARK: - Helpers

    fileprivate func enableAppLifeCycleNotifications(_ enable: Bool) {
        if enable {
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PageViewEventController.appWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
        } else {
            // swiftlint:disable:next notification_center_detachment
            NotificationCenter.default.removeObserver(self)
        }
    }

    fileprivate func sync(_ handler: EmptyHandler? = nil) {
        if(!appCanLogEvents()) { handler?(); return }
        requestManager.sendEvents { _ in
            handler?()
        }
    }

    private func cleanupUrl(url: String, attributes: PageViewEventDictionary?) -> String? {
        var path: String? = clipRnSpecialCaseSuffix(path: url)
        path = populatePlaceholderUrl(urlWithPlaceholders: path, params: attributes)
        path = path?.pruneApiVersionFromPath()
        return path
    }

    @objc func clipRnSpecialCaseSuffix(path: String) -> String {
        guard let url = URL(string: path) else { return path }
        if(url.pathComponents.last == "rn") {
            return (path as NSString).deletingLastPathComponent
        }
        return path
    }

    private func populatePlaceholderUrl(urlWithPlaceholders: String?, params: PageViewEventDictionary?) -> String? {
        guard let baseURL = Keychain.mostRecentSession?.baseURL,
            let urlWithPlaceholders = urlWithPlaceholders
            else { return nil }
        var path = urlWithPlaceholders
        if let customPageViewPath = params?[PageViewEventController.Constants.customPageViewPath]?.description { path = customPageViewPath }
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
        case courses
        case groups
        case users
        case accounts

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

    // swiftlint:disable:next large_tuple
    private func parsePageViewParts(_ url: String) -> (domain: String?, context: String?, contextID: String?)? {
        guard let urlObj = URL(string: url) else { return nil }
        let comps = urlObj.pathComponents
        let host = urlObj.host
        var context: String?
        var contextID: String?
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
    @objc open func allEvents() -> String {
        let count = persistency.queueCount
        let events = persistency.batchOfEvents(count)
        let defaultReturnValue = "[]"
        guard let encodedData = try? JSONEncoder().encode(events) else {
            return defaultReturnValue
        }
        return String(data: encodedData, encoding: .utf8) ?? defaultReturnValue
    }

    // MARK: - Dev menu
    @objc open func clearAllEvents(handler: (() -> Void)?) {
        persistency.dequeue(persistency.queueCount) {
            handler?()
        }
    }
}
