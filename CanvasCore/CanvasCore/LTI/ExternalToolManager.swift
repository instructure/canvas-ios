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
import SafariServices
import Marshal
import ReactiveSwift
import Core

private let error = NSError(subdomain: "CanvasCore",
                            description: NSLocalizedString("Error retrieving tool launch URL", comment: ""))

public class ExternalToolManager: NSObject {
    @objc public static let shared = ExternalToolManager()

    private var disposable: Disposable?

    public var openInSafari: Bool {
        return UserDefaults.standard.bool(forKey: "open_lti_safari")
    }

    @objc
    public static func isQuizzesNext(_ url: URL) -> Bool {
        let regex = "\\.quiz-lti-\\w+-prod\\.instructure\\.com\\/lti\\/launch"
        let range = url.absoluteString.range(of: regex, options: .regularExpression, range: nil, locale: nil)
        return range != nil
    }

    @objc
    public func launch(_ launchURL: URL, in session: Session, from viewController: UIViewController, completionHandler: (() -> Void)? = nil) {
        launch(launchURL, in: session, from: viewController, fallbackURL: nil, completionHandler: completionHandler)
    }

    @objc
    public func launch(_ launchURL: URL, in session: Session, from viewController: UIViewController, courseID: String? = nil, completionHandler: (() -> Void)? = nil) {
        launch(launchURL, in: session, from: viewController, fallbackURL: nil, completionHandler: completionHandler)
    }

    /**
     Launches an external tool.

     - Parameter launchURL: The best url we have to launch the external tool.
     - Parameter session: The current auth session.
     - Parameter viewController: The view controller that should present the SFSafariViewController or any errors.
     - Parameter fallbackURL: Sometimes the API returns a 401 for the request for the sessionless launch url.
        In that case we show a borderless canvas web using the fallbackURL.
        The most common scenario is to use the html_url of the external tool item.
     - Parameter completionHandler: Called once the SFSafariViewController has been presented.
    */
    @objc
    public func launch(_ launchURL: URL, in session: Session, from viewController: UIViewController, fallbackURL: URL?, completionHandler: (() -> Void)? = nil) {
        Analytics.shared.logEvent("external_tool_launched", parameters: ["launchUrl": launchURL])
        getSessionlessLaunchURL(forLaunchURL: launchURL.ensureHTTPS(), in: session) { [weak self, weak viewController] url, pageViewPath, error in
            guard let me = self, let vc = viewController else { return }
            if let url = url {
                me.present(url, pageViewPath: pageViewPath, from: vc, completionHandler: completionHandler)
                return
            }
            if let error = error {
                if let fallbackURL = fallbackURL {
                    // There's a bug with the API that is causing 401 errors which "should" never happen.
                    // So when this happens, load the Canvas Web version.
                    // Example: https://instructure.atlassian.net/browse/MBL-9506
                    me.showAuthenticatedURL(fallbackURL, in: session, from: vc, completionHandler: completionHandler)
                    return
                }
                me.fail(error, from: vc, completionHandler: completionHandler)
            }
        }
    }

    @objc func constructPageViewPath(url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let toolID = components?.queryItems?.first { $0.name == "id" }
        if let path = url.pathComponents.pathTo(lastComponent: "external_tools"), let toolID = toolID, let id = toolID.value {
            
            let pageViewPath: NSString = path as NSString
            return pageViewPath.appendingPathComponent(id)
        }
        return nil
    }
    
    @objc
    public func getSessionlessLaunchURL(forLaunchURL launchURL: URL, in session: Session, completionHandler: @escaping (URL?, String?, NSError?) -> Void) {
        guard let url = getSessionlessLaunchRequestURL(session, launchURL: launchURL) else {
            completionHandler(nil, nil, error)
            return
        }
        var pageViewPath = constructPageViewPath(url: launchURL)
        if let path = pageViewPath {
            pageViewPath = path.pruneApiVersionFromPath()
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        disposable?.dispose()
        disposable = session.JSONSignalProducer(request)
            .take(first: 1)
            .flatMap(.latest) { json in
                attemptProducer { () -> URL in
                    let toolURL: URL = try json <| "url"
                    let url = toolURL.appending(value: "mobile", forQueryParameter: "platform") ?? toolURL
                    return url
                }
            }
            .start { event in
                switch event {
                case .value(let url):
                    completionHandler(url, pageViewPath,  nil)
                case .failed(let error):
                    completionHandler(nil, nil, error)
                default:
                    break
                }
        }
    }

    @objc public func showAuthenticatedURL(_ url: URL, in session: Session, from viewController: UIViewController, completionHandler: (() -> Void)? = nil) {
        session.getAuthenticatedURL(forURL: url) { [weak self, weak viewController] result in
            guard let me = self, let vc = viewController else { return }
            switch result {
            case .success(let newURL):
                me.present(newURL, pageViewPath: nil, from: vc, completionHandler: completionHandler)
            case .failure(_):
                me.present(url,  pageViewPath: nil, from: vc, completionHandler: completionHandler)
            }
        }
    }

    private func getSessionlessLaunchRequestURL(_ session: Session, launchURL: URL) -> URL? {
        /*
         If we already have a sessionless_launch url we can return it.
         This happens in the following scenarios (and most likely more):
            * LTI course tabs
            * External tool assignment submissions
            * LTI module items
            * Basically anywhere the API is giving us information about the LTI tool directly
         */
        if launchURL.path.hasSuffix("/external_tools/sessionless_launch") {
            return launchURL
        }

        /*
         When an external tool is embedded in rich content the url will look like this:
         `https://account.instructure.com/courses/:courseID/external_tools/retrieve?url=https://account.instructure.com/link/to/lti/tool`
         We must pass the `url` query parameter to the sessionless_launch endpoint to get the sessionless launch url.
         */
        if launchURL.path.hasSuffix("/external_tools/retrieve") {
            let components = URLComponents(url: launchURL, resolvingAgainstBaseURL: false)
            if let queryItems = components?.queryItems,
                let urlQueryItem = queryItems.first(where: { $0.name == "url" }),
                let urlQuery = urlQueryItem.value {
                let url: URL
                if let courseID = extractCourseID(launchURL) {
                    url = session.baseURL.appendingPathComponent("api/v1/courses/\(courseID)/external_tools/sessionless_launch")
                } else {
                    url = session.baseURL.appendingPathComponent("api/v1/accounts/self/external_tools/sessionless_launch")
                }
                return url.appending(value: urlQuery, forQueryParameter: "url")
            }
        }

        /*
         * launchURL is probably (hopefully) the url to the LTI tool
         * So we tack it onto the sessionless_launch endpoint
         */
        let url = session.baseURL.appendingPathComponent("api/v1/accounts/self/external_tools/sessionless_launch")
        return url.appending(value: launchURL.absoluteString, forQueryParameter: "url")
    }

    private func extractCourseID(_ url: URL) -> String? {
        let regex = "\\/courses\\/\\d+\\/external_tools\\/retrieve"
        guard let retrieveRange = url.absoluteString.range(of: regex, options: .regularExpression, range: nil, locale: nil) else {
            return nil
        }
        let retrieve = url.absoluteString[retrieveRange]
        guard let idRange = retrieve.range(of: "[0-9]+", options: .regularExpression, range: nil, locale: nil) else {
            return nil
        }
        return String(retrieve[idRange])
    }

    private func present(_ url: URL, pageViewPath: String?, from viewController: UIViewController, completionHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            if self.openInSafari {
                UIApplication.shared.open(url.ensureHTTPS(), options: [:]) { [weak self] success in
                    guard success else {
                        self?.fail(error, from: viewController, completionHandler: completionHandler)
                        return
                    }
                    completionHandler?()
                }
                return
            }
            let safari = ExternalToolSafariViewController(url: url.ensureHTTPS(), eventName: pageViewPath)
            safari.modalPresentationStyle = .overFullScreen
            viewController.present(safari, animated: true, completion: completionHandler)
        }
    }

    private func fail(_ error: NSError, from viewController: UIViewController, completionHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            ErrorReporter.reportError(error, from: viewController)
            completionHandler?()
        }
    }
}

extension URL {
    func ensureHTTPS() -> URL {
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comps?.scheme = "https"
        return comps?.url ?? self
    }
}

public class ExternalToolSafariViewController: SFSafariViewController, PageViewEventViewControllerLoggingProtocol {
    
    @objc var eventName: String = ""
    
    @objc init(url: URL, eventName: String?) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        super.init(url: url, configuration: config)
        self.eventName = eventName ?? url.path
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTrackingTimeOnViewController(eventName: eventName)
    }
}
