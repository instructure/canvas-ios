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
                    let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", comment: "rollcall status error")])
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
                let error = NSError(domain: "com.instructure.rollcall", code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error: No data returned from the rollcall api.", comment: "rollcall status error")])
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
        guard HTTPCookieStorage.shared.cookies?
            .filter({$0.domain == "rollcall.instructure.com"})
            .first != nil else {
            return
        }
        
        guard case .launchingTool(let webView) = state else {
            return
        }
        
        if let request = webView.request,
            let response = URLCache.shared.cachedResponse(for: request),
            let html = String(data: response.data, encoding: .utf8) {
//                "<meta name=\"csrf-token\" content=\"cLVdjqbv/LR844EM1WLfSgZkmATdvk3SXn6GLeDjGcoZztWhSgiI7Dcj9UbFM/0REoymK2aOQC8+G0yLNws3Mg==\">"
            
            // search for the xsrf token
            let linkRegexPattern = "<meta.*name=\"csrf-token\".*content=\"([^\"]*)\""
            let linkRegex = try! NSRegularExpression(pattern: linkRegexPattern,
                                                     options: .caseInsensitive)
            let matches = linkRegex.matches(in: html,
                                            range: NSMakeRange(0, html.utf16.count))
            
            guard let csrfToken = matches.first.map({ result -> String in
                let hrefRange = result.rangeAt(1)
                let start = String.UTF16Index(hrefRange.location)
                let end = String.UTF16Index(hrefRange.location + hrefRange.length)
                
                return String(html.utf16[start..<end])!
            }) else {
                return
            }
            
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = [
                "X-CSRF-Token": csrfToken,
            ]
            config.httpCookieStorage = .shared
            let session = URLSession(configuration: config)
            state = .active(session)
        }
    }
}

extension RollCallSession: UIWebViewDelegate {
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        attemptToActivate()
    }
}
