//
//  LTILaunch.swift
//  CanvasCore
//
//  Created by Nathan Armstrong on 1/30/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation
import SafariServices
import Result
import Marshal
import ReactiveSwift

private let error = NSError(subdomain: "CanvasCore",
                            description: NSLocalizedString("Error retrieving tool launch URL", comment: ""))

public class ExternalToolManager: NSObject {

    public static let shared = ExternalToolManager()

    private var disposable: Disposable?

    @objc
    public static func isQuizzesNext(_ url: URL) -> Bool {
        let regex = "\\.quiz-lti-\\w+-prod\\.instructure\\.com\\/lti\\/launch"
        let range = url.absoluteString.range(of: regex, options: .regularExpression, range: nil, locale: nil)
        return range != nil
    }

    @objc
    public func launch(_ launchURL: URL, in session: Session, from viewController: UIViewController, completionHandler: (() -> Void)? = nil) {
        launch(launchURL, in: session, from: viewController, courseID: nil, fallbackURL: nil, completionHandler: completionHandler)
    }

    @objc
    public func launch(_ launchURL: URL, in session: Session, from viewController: UIViewController, courseID: String? = nil, completionHandler: (() -> Void)? = nil) {
        launch(launchURL, in: session, from: viewController, courseID: courseID, fallbackURL: nil, completionHandler: completionHandler)
    }

    @objc
    public func launch(_ launchURL: URL, in session: Session, from viewController: UIViewController, courseID: String?, fallbackURL: URL?, completionHandler: (() -> Void)? = nil) {
        getSessionlessLaunchURL(forLaunchURL: launchURL, in: session, courseID: courseID) { [weak self, weak viewController] url, error in
            guard let me = self, let vc = viewController else { return }
            if let url = url {
                me.present(url, from: vc, completionHandler: completionHandler)
                return
            }
            if let error = error {
                if error.code == 401, let fallbackURL = fallbackURL {
                    // There's a bug with the API that is causing 401 errors which "should" never happen.
                    // So if it does, load the Canvas Web version.
                    me.showFallbackURL(fallbackURL, in: session, from: vc, completionHandler: completionHandler)
                    return
                }
                me.fail(error, from: vc)
            }
        }
    }

    @objc
    public func getSessionlessLaunchURL(forLaunchURL launchURL: URL, in session: Session, courseID: String? = nil, completionHandler: @escaping (URL?, NSError?) -> Void) {
        guard let url = getSessionlessLaunchRequestURL(session, launchURL: launchURL, courseID: courseID) else {
            completionHandler(nil, error)
            return
        }

        var request = URLRequest(url: url).authorized(with: session)
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
                    completionHandler(url, nil)
                case .failed(let error):
                    completionHandler(nil, error)
                default:
                    break
                }
        }
    }

    private func showFallbackURL(_ url: URL, in session: Session, from viewController: UIViewController, completionHandler: (() -> Void)? = nil) {
        getAuthenticatedFallbackURL(forURL: url, in: session) { [weak self, weak viewController] result in
            guard let me = self, let vc = viewController else { return }
            switch result {
            case .success(let url):
                me.present(url, from: vc, completionHandler: completionHandler)
            case .failure(let error):
                me.fail(error, from: vc)
            }
        }
    }

    private func getAuthenticatedFallbackURL(forURL url: URL, in session: Session, completionHandler: @escaping (Result<URL, NSError>) -> Void) {
        let authRequest: URLRequest
        do {
            let returnURL = url.appending(value: "borderless", forQueryParameter: "display") ?? url
            let params = [
                "return_to": returnURL.absoluteString,
            ]
            authRequest = try session.GET("/login/session_token", parameters: params, encoding: .url, authorized: true)
        } catch let error as NSError {
            completionHandler(.failure(error))
            return
        }

        disposable?.dispose()
        disposable = session.JSONSignalProducer(authRequest)
            .take(first: 1)
            .flatMap(.latest) { json in
                attemptProducer { () -> URL in
                    let url: URL = try json <| "session_url"
                    return url
                }
            }
            .start { event in
                switch event {
                case .value(let url):
                    completionHandler(.success(url))
                case .failed(let error):
                    completionHandler(.failure(error))
                default:
                    break
                }
            }
    }

    private func getSessionlessLaunchRequestURL(_ session: Session, launchURL: URL, courseID: String?) -> URL? {
        /*
         If we already have a sessionless_launch url we can return it.
         This happens in the following scenarios (and most likely more):
            * LTI course tabs
            * External tool assignment submissions
            * LTI module items
            * Basically anywhere the API is giving us information about the LTI tool directly
         */
        if launchURL.path.contains("/external_tools/sessionless_launch") {
            return launchURL
        }

        /*
         When an external tool is embedded in rich content the url will look like this:
         `https://account.instructure.com/courses/:courseID/external_tools/retrieve?url=https://account.instructure.com/link/to/lti/tool`
         We must pass the `url` query parameter to the sessionless_launch endpoint to get the sessionless launch url.
         */
        if launchURL.path.contains("/external_tools/retrieve") {
            let components = URLComponents(url: launchURL, resolvingAgainstBaseURL: false)
            if let queryItems = components?.queryItems,
                let urlQueryItem = queryItems.findFirst({ $0.name == "url" }),
                let urlQuery = urlQueryItem.value {
                let url: URL
                if let courseID = extractCourseID(launchURL) {
                    url = session.baseURL/"api/v1/courses/\(courseID)/external_tools/sessionless_launch"
                } else {
                    url = session.baseURL/"api/v1/accounts/self/external_tools/sessionless_launch"
                }
                return url.appending(value: urlQuery, forQueryParameter: "url")
            }
        }

        /*
         * launchURL is probably (hopefully) the url to the LTI tool
         * So we tack it onto the sessionless_launch endpoint
         */
        let url = session.baseURL/"api/v1/accounts/self/external_tools/sessionless_launch"
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
        return retrieve[idRange]
    }

    private func markViewed(_ launchURL: URL, in session: Session, for courseID: String) {
        let context = ContextID.course(withID: courseID)
        session.progressDispatcher.dispatch(
            Progress(
                kind: .viewed,
                contextID: context,
                itemType: Progress.ItemType.externalTool,
                itemID: launchURL.absoluteString
            )
        )
    }

    private func present(_ url: URL, from viewController: UIViewController, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let safari = SFSafariViewController(url: url)
            viewController.present(safari, animated: true, completion: completionHandler)
        }
    }

    private func fail(_ error: NSError, from viewController: UIViewController, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            ErrorReporter.reportError(error, from: viewController)
            completionHandler?()
        }
    }
}
