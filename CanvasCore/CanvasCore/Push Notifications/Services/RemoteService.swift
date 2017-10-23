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
    
    

import Foundation


import Result
import Marshal
import ReactiveSwift

open class RemoteService {
    
    let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    // MARK: Notification Settings Globally Update
    open func getNotificationPreferencesSetup(_ completion: @escaping (Result<Bool, NSError>) -> ()) {
        requestForGetNotificationPreferencesSetup()
            .flatMap(.concat, transform: session.JSONSignalProducer)
            .on(value: { response in
                let resultString: String = (try? response <| "\(RemoteService.customDataKey).\(RemoteService.key)") ?? "false"
                completion(Result(value: (resultString as NSString).boolValue))
            })
            .startWithFailed { error in
                completion(Result(error: error))
            }
    }
    
    fileprivate func requestForGetNotificationPreferencesSetup() -> SignalProducer<URLRequest, NSError> {
        let path = pathForKeyValueStore()
        let parameters = [RemoteService.namespaceKey: RemoteService.namespaceValue]
        return attemptProducer { try session.GET(path, parameters: parameters) }
    }
    
    open func updateNotificationPreferencesSetup(_ completion: @escaping (Result<Bool, NSError>) -> ()) {
        requestForUpdateNotificationPreferencesSetup()
            .flatMap(.concat, transform: session.emptyResponseSignalProducer)
            .on(completed: { completion(Result(value: true)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    fileprivate func requestForUpdateNotificationPreferencesSetup() -> SignalProducer<URLRequest, NSError> {
        let path = pathForKeyValueStore()
        let parameters: [String : Any] = [RemoteService.namespaceKey: RemoteService.namespaceValue, RemoteService.customDataKey: "true"]
        return attemptProducer { try session.PUT(path, parameters: parameters) }
    }
    
    // DON'T CHANGE THESE! THE FATE OF THE WORLD DEPENDS ON IT!
    // *******************************************************************************************
    fileprivate static let scope = "data_sync"
    fileprivate static let namespaceKey = "ns"
    fileprivate static let namespaceValue = "MOBILE_CANVAS_USER_NOTIFICATION_STATUS_SETUP"
    fileprivate static let customDataKey = "data"
    fileprivate static let key = "NOTIFICATION_PREFERENCES_SETUP"
    // *******************************************************************************************

    fileprivate func pathForKeyValueStore() -> String {
        return "api/v1/users/self/custom_data/\(RemoteService.scope)"
    }
    
    // MARK: Push notification registration
    open func registerPushNotificationTokenWithPushService(_ pushToken: String, completion: @escaping (Result<Bool, NSError>) -> ()) {
        requestForPushNotificationRegistration(pushToken)
            .flatMap(.concat, transform: session.emptyResponseSignalProducer)
            .on(completed: { completion(Result(value: true)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    fileprivate func requestForPushNotificationRegistration(_ pushToken: String) -> SignalProducer<URLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels"
        
        let channel = ["type": "push", "token": pushToken]
        let params = ["communication_channel": channel]
        
        return attemptProducer { try session.POST(path, parameters: params) }
    }
    
    // MARK: Retrieve communication channels
    //       GET /users/:user_id/communication_channels
    open func getUserCommunicationChannels(_ completion: @escaping (Result<[CommunicationChannel], NSError>) -> ()) {
        requestForUserCommunicationChannels()
            .flatMap(.merge, transform: { self.session.paginatedJSONSignalProducer($0) } )
            .map { $0.flatMap(CommunicationChannel.create) }
            .on(value: { completion(Result(value: $0)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    fileprivate func requestForUserCommunicationChannels() -> SignalProducer<URLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels"
        
        return attemptProducer { try session.GET(path) }
    }
    
    // MARK: Retrieve notification preferences for a channel
    //       GET /users/:user_id/communication_channels/:communication_channel_id/notification_preferences
    open func getNotificationPreferences(_ channelID: String, completion: @escaping (Result<[NotificationPreference], NSError>) -> ()) {
        requestForNotificationPreferences(channelID)
            .flatMap(.concat, transform: { self.session.paginatedJSONSignalProducer($0, keypath: "notification_preferences") } )
            .map { $0.flatMap(NotificationPreference.create) }
            .on(value: { completion(Result(value: $0)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    fileprivate func requestForNotificationPreferences(_ channelID: String) -> SignalProducer<URLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels/\(channelID)/notification_preferences"
        
        return attemptProducer { try session.GET(path) }
    }

    
    // MARK: Update preferences for a channel
    //       PUT /users/self/communication_channels/5574839/notification_preferences[new_file_added][frequency]=immediately&notification_preferences[new_files_added][frequency]=immediately
    //       e.g. https://mobiledev.instructure.com/api/v1/users/self/communication_channels/5574839/notification_preferences[new_file_added][frequency]=immediately&notification_preferences[new_files_added][frequency]=immediately
    open func setNotificationPreferences(_ channelID: String, preferences: [NotificationPreference], completion: @escaping (Result<Bool, NSError>) -> ()) {
        requestForSetNotificationPreferences(channelID, preferences: preferences)
            .flatMap(.merge, transform: session.emptyResponseSignalProducer)
            .on(completed: { completion(Result(value: true)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    fileprivate func requestForSetNotificationPreferences(_ channelID: String, preferences: [NotificationPreference]) -> SignalProducer<URLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels/\(channelID)/notification_preferences"
        var notificationMap = [String : Any]()
        
        for preference in preferences {
            notificationMap[preference.notification] = ["frequency" : "\(preference.frequency.rawValue)"]
        }
        
        let parameters = ["notification_preferences" : notificationMap]
        return attemptProducer { try self.session.PUT(path, parameters: parameters) }
    }
}
