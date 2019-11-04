//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import UIKit
import WebKit
import Core

func attendanceError(message: String, code: Int = 0) -> Error {
    return NSError(domain: "com.instructure.rollcall", code: code, userInfo: [
        NSLocalizedDescriptionKey: message,
    ])
}

protocol RollCallSessionDelegate: class {
    func session(_ session: RollCallSession, didFailWithError error: Error)
    func sessionDidBecomeActive(_ session: RollCallSession)
}

class RollCallSession: NSObject, WKNavigationDelegate {
    enum State {
        case fetchingLaunchURL
        case launchingTool(WKWebView)
        case active(URLSession)
        case error(Error)
    }

    var state: State {
        didSet {
            performUIUpdate {
                switch self.state {
                case .fetchingLaunchURL, .launchingTool: break
                case .active: self.delegate?.sessionDidBecomeActive(self)
                case .error(let error): self.delegate?.session(self, didFailWithError: error)
                }
            }
        }
    }

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Status.dateFormatter)
        return decoder
    }()

    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Status.dateFormatter)
        return encoder
    }()

    var baseURL = URL(string: "https://rollcall.instructure.com")!
    let context: Context
    weak var delegate: RollCallSessionDelegate?
    let env = AppEnvironment.shared
    let toolID: String

    init(context: Context, toolID: String, delegate: RollCallSessionDelegate? = nil) {
        self.context = context
        self.delegate = delegate
        self.state = .fetchingLaunchURL
        self.toolID = toolID
        super.init()
    }

    func start() {
        guard case .fetchingLaunchURL = state else { return }
        LTITools(env: env, context: context, id: toolID, launchType: .course_navigation).getSessionlessLaunchURL { url in
            if let url = url {
                self.launch(url: url)
            } else {
                self.state = .error(attendanceError(message: NSLocalizedString("Failed to launch rollcall LTI tool.", comment: ""), code: 1))
            }
        }
    }

    func launch(url: URL) {
        guard case .fetchingLaunchURL = state else { return }

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        state = .launchingTool(webView)
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
        guard
            case .launchingTool(let webView) = state,
            webView.url?.host == baseURL.host
        else { return }

        // Force cookies to flush. Only works on device. Simulator is flaky.
        webView.configuration.processPool = WKProcessPool()
        webView.evaluateJavaScript("""
        ({
            error: (document.querySelector('pre') || {}).textContent || '',
            csrf: (document.querySelector('meta[name=\"csrf-token\"]') || {}).content || '',
        })
        """) { (value, _) in
            let dict = value as? [String: String]
            if let csrf = dict?["csrf"], !csrf.isEmpty {
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    let config = URLSessionConfiguration.ephemeral
                    config.httpAdditionalHeaders = [ "X-CSRF-Token": csrf ]
                    for cookie in cookies {
                        config.httpCookieStorage?.setCookie(cookie)
                    }
                    self.state = .active(URLSessionAPI.delegateURLSession(config, nil, nil))
                }
            } else if let message = dict?["error"], !message.isEmpty {
                self.state = .error(attendanceError(message: message, code: 2))
            } else {
                self.state = .error(attendanceError(message: NSLocalizedString("Error: No data returned from the rollcall api.", comment: ""), code: 1))
            }
        }
    }

    func fetchStatuses(section: String, date: Date, completed: @escaping ([Status], Error?) -> Void) {
        guard case .active(let session) = state else { return completed([], nil) }

        let date = Status.dateFormatter.string(from: date)
        let url = URL(string: "/statuses?section_id=\(section)&class_date=\(date)", relativeTo: baseURL)!
        session.dataTask(with: URLRequest(url: url)) { (data, _, error) in
            do {
                guard let data = data else {
                    return completed([], attendanceError(message: NSLocalizedString("Error: No data returned from the rollcall api.", comment: ""), code: 1))
                }
                let statuses: [Status] = try self.decoder.decode([Status].self, from: data)
                completed(statuses, nil)
            } catch let error {
                completed([], error)
            }
        }
        .resume()
    }

    func updateStatus(_ status: Status, completed: @escaping (ID?, Error?) -> Void) {
        guard case .active(let session) = state else { return completed(nil, nil) }

        var url = URL(string: "/statuses", relativeTo: baseURL)!
        var method = "POST"
        if let id = status.id?.value {
            url.appendPathComponent(id)
            if status.attendance == nil {
                method = "DELETE"
            } else {
                method = "PUT"
            }
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method
        request.httpBody = try? encoder.encode(status)

        session.dataTask(with: request) { (data, _, error) in
            guard let data = data else {
                let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", comment: "rollcall status error"),
                ])
                return completed(nil, error)
            }

            // don't capture the ID of the deleted status... leave it nil
            guard status.attendance != nil else { return completed(nil, nil) }
            do {
                let status = try self.decoder.decode(Status.self, from: data)
                completed(status.id, nil)
            } catch let e {
                completed(nil, e)
            }
        }
        .resume()
    }
}
