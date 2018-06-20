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
import Reachability

struct Pandata {
    static let tokenKeychainKey = "com.instructure.pandataToken"
    static let expiresAtKey = "expires_at"
}

class PageViewEventRequestManager {
    
    fileprivate let maxBatchCount = 300
    
    func sendEvents(handler: ErrorHandler?) {
        guard FeatureFlags.featureFlagEnabled(.pageViewLogging) else { handler?(nil); return }
        guard let reachability = Reachability(hostName: "www.google.com"), reachability.isReachable() else { handler?(nil); return }
        
        retrievePandataEndpointInfo { [weak self] (endpointInfo) in
            guard let sself = self, let endpointInfo = endpointInfo else { handler?(nil); return }
            
            let totalEvents = Persistency.instance.queueCount
            var count = totalEvents
            if(totalEvents > sself.maxBatchCount) {
                count = sself.maxBatchCount
            }
            
            if(count == 0) { handler?(nil); return }
            
            var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "send pageview events") {
                backgroundTask = UIBackgroundTaskInvalid
            }
            
            let eventsToSync = Persistency.instance.batchOfEvents(count)
            
            if let data = try? JSONEncoder().encode(eventsToSync), let json = String(data: data, encoding: .utf8) {
                APIBridge.shared().call("sendEvents", args: [json as Any, endpointInfo as Any]) { response, error in
                    if let success = response as? String, success.lowercased() == "ok" {
                        Persistency.instance.dequeue(count, handler: {
                            handler?(nil)
                            UIApplication.shared.endBackgroundTask(backgroundTask)
                        })
                    }
                    else {
                        handler?(error)
                        UIApplication.shared.endBackgroundTask(backgroundTask)
                    }
                }
            }
            else {
                UIApplication.shared.endBackgroundTask(backgroundTask)
            }
        }
    }
    
    func cleanup() {
        FXKeychain.default().removeObject(forKey: Pandata.tokenKeychainKey)
    }
    
    fileprivate func storePandataEndpointInfo(_ tokenData: [String: Any]) {
        FXKeychain.default().setObject(tokenData, forKey: Pandata.tokenKeychainKey)
    }
    
    fileprivate func retrievePandataEndpointInfo(handler: (([String: Any]?) -> Void)?) {
        if let data = FXKeychain.default().object(forKey: Pandata.tokenKeychainKey) as? [String: Any], let expiration = data[Pandata.expiresAtKey] as? Double {
            let expDt = Date(timeIntervalSince1970: expiration / 1000)
            if expDt >= Date() {
                handler?(data)
                return
            }
        }
        
        guard let userID = CanvasKeymaster.the().currentClient?.currentUser.id else { handler?(nil); return }
        requestPandataEndpointInfo(userID: userID) { [weak self] (data, error) in
            guard let data = data else { handler?(nil); return }
            self?.storePandataEndpointInfo(data)
            handler?(data)
        }
    }
    
    func requestPandataEndpointInfo(userID: String, handler: @escaping ([String: Any]? , Error? ) -> Void ) {
        var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "fetch pandata token") { backgroundTask = UIBackgroundTaskInvalid }
        
        APIBridge.shared().call("fetchPandataToken", args: [userID]) { response, error in
            guard let data = response as? [String: Any] else {
                handler(nil, error)
                UIApplication.shared.endBackgroundTask(backgroundTask)
                return
            }
            
            handler(data, nil)
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
}
