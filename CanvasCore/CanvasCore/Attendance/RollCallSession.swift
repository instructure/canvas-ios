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
                    case .active(_): delegate.sessionDidBecomeActive?(self)
                    default: break
                    }
                }
            }
        }
    }
    
    weak public var delegate: RollCallSessionDelegate?

    public init(client: CKIClient, initialLaunchURL: URL) {
        self.state = .fetchingLaunchURL
        super.init()
        
        client.get(initialLaunchURL.absoluteString, parameters: nil, progress: nil, success: { (task, response) in
            if let response = response as? [String: Any], let sessionlessURL = response["url"] as? String {
                self.launch(url: URL(string: sessionlessURL)!)
            }
        }) { (task, error) in
            self.state = .error(error)
        }
    }

    func launch(url: URL) {
        guard case .fetchingLaunchURL = state else { return }

        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        webView.delegate = self
        webView.alpha = 0.0
        state = .launchingTool(webView)
        webView.loadRequest(URLRequest(url: url))
    }
    
    public func fetchStatuses(section: Int, date: Date, result: @escaping ([Status], Error?) -> ()) {
        guard case .active(let session) = state else { return }
        let date = Status.dateFormatter.string(from: date)
        
        let url = URL(string: "https://rollcall.instructure.com/statuses?section_id=\(section)&class_date=\(date)")!

        task = session.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else {
                    let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", tableName: "Localizable", bundle: .core, value: "", comment: "rollcall status error")])
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
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Key not found: \(k)", tableName: "Localizable", bundle: .core, value: "", comment: "")
                case .nullValue(key: let k):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Unexpected null value: \(k)", tableName: "Localizable", bundle: .core, value: "", comment: "")
                case let .typeMismatch(expected: e, actual: a):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Expected \(e), received \(a)", tableName: "Localizable", bundle: .core, value: "", comment: "")
                case let .typeMismatchWithKey(key: k, expected: e, actual: a):
                    localizedDescription = NSLocalizedString("Error parsing the Roll Call response. Expected \(e), received \(a) for key \(k)", tableName: "Localizable", bundle: .core, value: "", comment: "")
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

    var task: URLSessionTask?
    public func updateStatus(_ status: Status, completed: @escaping (Int?, Error?) -> Void) -> Void {
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
        
        task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", tableName: "Localizable", bundle: .core, value: "", comment: "rollcall status error")])
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
                let id: Int? = try statusJSON <| "id"
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
    
    fileprivate func attemptToActivate() {
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
            state = .error(NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", tableName: "Localizable", bundle: .core, value: "", comment: "rollcall status error")]))
        }
    }
}

extension RollCallSession: UIWebViewDelegate {
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        attemptToActivate()
    }
}
