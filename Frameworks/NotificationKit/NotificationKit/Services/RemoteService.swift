//
//  RemoteService.swift
//  NotificationKit
//
//  Created by Miles Wright on 5/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import Result
import Marshal
import ReactiveCocoa

public class RemoteService {
    
    let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    // MARK: Notification Settings Globally Update
    public func getNotificationPreferencesSetup(completion: Result<Bool, NSError> -> ()) {
        requestForGetNotificationPreferencesSetup()
            .flatMap(.Concat, transform: session.JSONSignalProducer)
            .on(next: { response in
                let resultString: String = (try? response <| "\(RemoteService.customDataKey).\(RemoteService.key)") ?? "false"
                completion(Result(value: (resultString as NSString).boolValue))
            })
            .startWithFailed { error in
                completion(Result(error: error))
            }
    }
    
    private func requestForGetNotificationPreferencesSetup() -> SignalProducer<NSURLRequest, NSError> {
        let path = pathForKeyValueStore()
        let parameters = [RemoteService.namespaceKey: RemoteService.namespaceValue]
        return attemptProducer { try session.GET(path, parameters: parameters) }
    }
    
    public func updateNotificationPreferencesSetup(completion: Result<Bool, NSError> -> ()) {
        requestForGetNotificationPreferencesSetup()
            .flatMap(.Concat, transform: session.emptyResponseSignalProducer)
            .on(next: { completion(Result(value: true)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    private func requestForUpdateNotificationPreferencesSetup() -> SignalProducer<NSURLRequest, NSError> {
        let path = pathForKeyValueStore()
        let parameters: [String : AnyObject] = [RemoteService.namespaceKey: RemoteService.namespaceValue, RemoteService.customDataKey: "true"]
        return attemptProducer { try session.POST(path, parameters: parameters) }
    }
    
    // DON'T CHANGE THESE! THE FATE OF THE WORLD DEPENDS ON IT!
    // *******************************************************************************************
    private static let scope = "data_sync"
    private static let namespaceKey = "ns"
    private static let namespaceValue = "MOBILE_CANVAS_USER_NOTIFICATION_STATUS_SETUP"
    private static let customDataKey = "data"
    private static let key = "NOTIFICATION_PREFERENCES_SETUP"
    // *******************************************************************************************

    private func pathForKeyValueStore() -> String {
        return "api/v1/users/self/custom_data/\(RemoteService.scope)"
    }
    
    // MARK: Push notification registration
    public func registerPushNotificationTokenWithPushService(pushToken: String, completion: Result<Bool, NSError> -> ()) {
        requestForPushNotificationRegistration(pushToken)
            .flatMap(.Concat, transform: session.emptyResponseSignalProducer)
            .on(next: { completion(Result(value: true)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    private func requestForPushNotificationRegistration(pushToken: String) -> SignalProducer<NSURLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels"
        
        let channel = ["type": "push", "token": pushToken]
        let params = ["communication_channel": channel]
        
        return attemptProducer { try session.POST(path, parameters: params) }
    }
    
    // MARK: Retrieve communication channels
    //       GET /users/:user_id/communication_channels
    public func getUserCommunicationChannels(completion: Result<[CommunicationChannel], NSError> -> ()) {
        requestForUserCommunicationChannels()
            .flatMap(.Merge, transform: { self.session.paginatedJSONSignalProducer($0) } )
            .map { $0.flatMap(CommunicationChannel.create) }
            .on(next: { completion(Result(value: $0)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    private func requestForUserCommunicationChannels() -> SignalProducer<NSURLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels"
        
        return attemptProducer { try session.GET(path) }
    }
    
    // MARK: Retrieve notification preferences for a channel
    //       GET /users/:user_id/communication_channels/:communication_channel_id/notification_preferences
    public func getNotificationPreferences(channelID: String, completion: Result<[NotificationPreference], NSError> -> ()) {
        requestForNotificationPreferences(channelID)
            .flatMap(.Concat, transform: { self.session.paginatedJSONSignalProducer($0, keypath: "notification_preferences") } )
            .map { $0.flatMap(NotificationPreference.create) }
            .on(next: { completion(Result(value: $0)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    private func requestForNotificationPreferences(channelID: String) -> SignalProducer<NSURLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels/\(channelID)/notification_preferences"
        
        return attemptProducer { try session.GET(path) }
    }

    
    // MARK: Update preferences for a channel
    //       PUT /users/self/communication_channels/5574839/notification_preferences[new_file_added][frequency]=immediately&notification_preferences[new_files_added][frequency]=immediately
    //       e.g. https://mobiledev.instructure.com/api/v1/users/self/communication_channels/5574839/notification_preferences[new_file_added][frequency]=immediately&notification_preferences[new_files_added][frequency]=immediately
    public func setNotificationPreferences(channelID: String, preferences: [NotificationPreference], completion: Result<Bool, NSError> -> ()) {
        requestForSetNotificationPreferences(channelID, preferences: preferences)
            .flatMap(.Merge, transform: session.emptyResponseSignalProducer)
            .on(next: { completion(Result(value: true)) })
            .startWithFailed { err in completion(Result(error: err)) }
    }
    
    private func requestForSetNotificationPreferences(channelID: String, preferences: [NotificationPreference]) -> SignalProducer<NSURLRequest, NSError> {
        let path = "api/v1/users/self/communication_channels/\(channelID)/notification_preferences"
        var notificationMap = [String : AnyObject]()
        
        for preference in preferences {
            notificationMap[preference.notification] = ["frequency" : "\(preference.frequency.rawValue)"]
        }
        
        let parameters = ["notification_preferences" : notificationMap]
        return attemptProducer { try self.session.PUT(path, parameters: parameters) }
    }
}
