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
import CanvasKit
import Marshal

@objc
public protocol RollCallSessionDelegate {
    @objc optional func session(_ session: RollCallSession, beganLaunchingToolInView view: UIWebView)
    @objc optional func session(_ session: RollCallSession, didFailWithError error: Error)
    @objc optional func sessionDidBecomeActive(_ session: RollCallSession)
}

public class RollCallSession: NSObject {
    enum State {
        case fetchingLaunchURL
        case launchingTool(UIWebView)
        case active(URLSession)
        case error(Error)
    }

    enum RequestState {
        case pendingSession
        case started(URLSessionTask)
    }

    var state: State {
        didSet {
            if let delegate = self.delegate {
                let state = self.state
                DispatchQueue.main.async {
                    switch state {
                    case .error(let error): delegate.session?(self, didFailWithError: error)
                    case .launchingTool(let webView): delegate.session?(self, beganLaunchingToolInView: webView)
                    case .active: delegate.sessionDidBecomeActive?(self)
                    default: break
                    }
                }
            }
        }
    }

    @objc weak public var delegate: RollCallSessionDelegate?

    @objc public init(client: CKIClient, initialLaunchURL: URL) {
        self.state = .fetchingLaunchURL
        super.init()

        client.get(initialLaunchURL.absoluteString, parameters: nil, progress: nil, success: { (_, response) in
            if let response = response as? [String: Any], let sessionlessURL = response["url"] as? String {
                self.launch(url: URL(string: sessionlessURL)!)
            }
        }, failure: { (_, error) in
            self.state = .error(error)
        })
    }

    @objc func launch(url: URL) {
        guard case .fetchingLaunchURL = state else { return }

        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        webView.delegate = self
        webView.alpha = 0.0
        state = .launchingTool(webView)
        webView.loadRequest(URLRequest(url: url))
    }

    public func fetchStatuses(section: String, date: Date, result: @escaping ([Status], Error?) -> Void) {
        guard case .active(let session) = state else { return }
        let date = Status.dateFormatter.string(from: date)

        let url = URL(string: "https://rollcall.instructure.com/statuses?section_id=\(section)&class_date=\(date)")!

        task = session.dataTask(with: url) { (data, _, error) in
            do {
                guard let data = data else {
                    let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", comment: "rollcall status error"),
                    ])
                    DispatchQueue.main.async {
                        result([], error)
                    }
                    return
                }
                let json = try JSONParser.JSONArrayWithData(data)
                let statii: [Status] = try [Status].value(from: json)
                DispatchQueue.main.async {
                    result(statii, nil)
                }
            } catch let error as MarshalError {
                let localizedDescription: String
                switch error {
                case .keyNotFound(key: let k):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Key not found: \(k)", comment: "")
                case .nullValue(key: let k):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Unexpected null value: \(k)", comment: "")
                case let .typeMismatch(expected: e, actual: a):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Expected \(e), received \(a)", comment: "")
                case let .typeMismatchWithKey(key: k, expected: e, actual: a):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Expected \(e), received \(a) for key \(k)", comment: "")
                }
                DispatchQueue.main.async {
                    result([], NSError(domain: "com.instructure.rollcall", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription]))
                }
            } catch let error {
                DispatchQueue.main.async {
                    result([], error)
                }
            }
        }
        task?.resume()
    }

    @objc var task: URLSessionTask?
    public func updateStatus(_ status: Status, completed: @escaping (String?, Error?) -> Void) {
        guard case .active(let session) = state else { return }

        var url = URL(string: "https://rollcall.instructure.com/statuses")!
        var method = "POST"
        if let id = status.id {
            url = URL(string: "https://rollcall.instructure.com/statuses/\(id)")!
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
        do {
            let data = try status.marshaled().jsonData()
            request.httpBody = data
        } catch let error {
            DispatchQueue.main.async {
                completed(nil, error)
            }
            print(error)
            return
        }

        task = session.dataTask(with: request) { (data, _, error) in
            guard let data = data else {
                let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", comment: "rollcall status error"),
                ])
                print(error)
                DispatchQueue.main.async {
                    completed(nil, error)
                }
                return
            }

            do {
                guard status.attendance != nil else {
                    // don't capture the ID of the deleted status... leave it nil
                    DispatchQueue.main.async {
                        completed(nil, nil)
                    }
                    return
                }
                let statusJSON = try JSONParser.JSONObjectWithData(data)
                let id: String? = try statusJSON.stringID("id")
                if let id = id {
                    DispatchQueue.main.async {
                        completed(id, nil)
                    }
                }
            } catch let e {
                print("Error parsing status response: \(e)")
                DispatchQueue.main.async {
                    completed(nil, e)
                }
            }
        }

        task?.resume()
    }

    private func attemptToActivate() {
        guard
            case .launchingTool(let webView) = state,
            let host = webView.request?.url?.host,
            host == "rollcall.instructure.com"
        else { return }

        let preTextContent = webView.stringByEvaluatingJavaScript(from: "document.querySelector('pre').textContent")
        let metaContent = webView.stringByEvaluatingJavaScript(from: "document.querySelector('meta[name=\"csrf-token\"]').content")

        if let csrfToken = metaContent, !csrfToken.isEmpty {
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = [
                "X-CSRF-Token": csrfToken,
            ]
            config.httpCookieStorage = .shared
            let session = URLSession(configuration: config)
            state = .active(session)
        } else if let message = preTextContent, !message.isEmpty {
            state = .error(NSError(domain: "com.instructure.rollcall", code: 2, userInfo: [NSLocalizedDescriptionKey: message]))
        } else {
            state = .error(NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", comment: "rollcall status error"),
            ]))
        }
    }
}

extension RollCallSession: UIWebViewDelegate {
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        attemptToActivate()
    }
}
