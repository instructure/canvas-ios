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

class PageViewEventController {
    open static let instance = PageViewEventController()
    private(set) var userID: String?
    var enabled: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private init() {
        setup()
    }
    
    private func setup() {
        enableAppLifeCycleNotifications(true)
    }
    
    //  MARK: - Public
    
    func associateUser(_ userID: String?) {
        self.userID = userID
    }
    
    func logPageView(_ eventName: String, attributes: PageViewEventDictionary? = nil, eventDurationInSeconds: TimeInterval = 0) {
        if(!enabled) { return }
        guard let userID = userID else { return }
        let event = PageViewEvent(eventName: eventName, attributes: attributes, userID: userID, eventDuration: eventDurationInSeconds)
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
            NotificationCenter.default.addObserver(self, selector:  #selector(PageViewEventController.appWillTerminate(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
            
            CanvasKeymaster.the().signalForLogin.subscribeNext { [weak self] (client) in
                guard let client = client else { return }
                self?.userID = client.currentUser.id
            }
            
            CanvasKeymaster.the().signalForLogout.subscribeNext({ [weak self] (_) in
                self?.sync() {
                    self?.userID = nil
                }
            })
        }
        else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    fileprivate func sync(_ handler: EmptyHandler? = nil) {
        sendEvents{ error in
            handler?()
        }
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
