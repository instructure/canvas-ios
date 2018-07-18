//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Result

extension String {
    init(deviceToken: Data) {
        self = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    }
}

public struct UserDeviceToken: Equatable {
    public let session: Session
    public let token: String

    public static func == (lhs: UserDeviceToken, rhs: UserDeviceToken) -> Bool {
        return lhs.session.user.id == rhs.session.user.id &&
            lhs.session.baseURL == rhs.session.baseURL &&
            lhs.token == rhs.token
    }

    public static var current: UserDeviceToken?

    public init(session: Session, token: Data) {
        self.session = session
        self.token = String(deviceToken: token)
    }
}

open class NotificationKitController {
    
    fileprivate var remoteService: RemoteService
    
    public init(session: Session) {
        self.remoteService = RemoteService(session: session)    }
    
    public typealias RegisterPushNotificationTokenResult = Result<Void, NSError>

    public static func setupForPushNotifications(delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
        #if !arch(i386) && !arch(x86_64) // Can't register on simulator
            UIApplication.shared.registerForRemoteNotifications()
        #endif
    }

    public static func didRegisterForRemoteNotifications(_ deviceToken: Data, errorHandler: @escaping (NSError) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            if let client = CanvasKeymaster.the().currentClient {
                let session = client.authSession
                let controller = NotificationKitController(session: session)
                let userToken = UserDeviceToken(session: session, token: deviceToken)
                let register = { () -> Void in
                    controller.registerPushNotificationTokenWithPushService(userToken) { result in
                        switch result {
                        case .success:
                            UserDeviceToken.current = userToken
                            break
                        case .failure(let error):
                            errorHandler(error.addingInfo())
                        }
                    }
                }

                // Check if the current token is the same as the new one
                if let currentUserToken = UserDeviceToken.current, currentUserToken != userToken {
                    // Not the same so deregister the old one before registering the new one.
                    controller.deregisterPushNotificationTokenWithPushService(currentUserToken) { result in
                        switch result {
                        case .success:
                            register()
                        case .failure(let error):
                            errorHandler(error.addingInfo())
                        }
                    }
                } else {
                    // This is either the very first token or the same token as before
                    // so we can go ahead and register it
                    register()
                }
            }
        }
    }

    public static func deregisterPushNotifications(completionHandler: @escaping (NSError?) -> Void) {
        guard let userToken = UserDeviceToken.current else {
            completionHandler(nil)
            return
        }
        let controller = NotificationKitController(session: userToken.session)
        controller.deregisterPushNotificationTokenWithPushService(userToken) { result in
            switch result {
            case .success:
                UserDeviceToken.current = nil
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        }
    }
    
    // This is super ugly, change with Swift 2.0 - guard
    public typealias RegisterPushNotificationTokenCompletion = (_ result: RegisterPushNotificationTokenResult) -> ()
    open func registerPushNotificationTokenWithPushService(_ deviceToken: UserDeviceToken, registrationCompletion: @escaping RegisterPushNotificationTokenCompletion) {
        self.remoteService.registerPushNotificationTokenWithPushService(deviceToken.token, completion: { (pushNotificationRegistrationResult) -> () in
            
            if pushNotificationRegistrationResult.error != nil {
                registrationCompletion(RegisterPushNotificationTokenResult.failure(pushNotificationRegistrationResult.error!))
            } else if pushNotificationRegistrationResult.value != nil {
                
                // Verify whether user has previously set up notification preferences
                self.remoteService.getNotificationPreferencesSetup({ (notificationPreferencesResult) -> () in
                    if notificationPreferencesResult.error != nil {
                        // nothing has been saved for the piece that we're looking at
                        // TODO: How can we make this more robust with the Request stuff?  a problem for future generations
                        
                        if notificationPreferencesResult.error!.code == 400 {
                            // should do setup
                            self.setNotificationPreferenceDefaults(registrationCompletion)
                        } else {
                            // actually had an error, return that
                            registrationCompletion(RegisterPushNotificationTokenResult.failure(notificationPreferencesResult.error!))
                        }
                    } else {
                        // There's no need to look at the data at this point, if it's able to fetch the data then we don't need to setup the notification preferences, the only way a value gets there is if the values get setup
                        registrationCompletion(RegisterPushNotificationTokenResult.success())
                    }
                })
            }
        })
    }

    func deregisterPushNotificationTokenWithPushService(_ deviceToken: UserDeviceToken, completionHandler: @escaping (Result<Void, NSError>) -> Void) {
        self.remoteService.deregisterPushNotificationTokenWithPushService(deviceToken.token, completion: completionHandler)
    }
    
    // This is super ugly, change with Swift 2.0 - guard
    fileprivate func setNotificationPreferenceDefaults(_ registrationCompletion: @escaping RegisterPushNotificationTokenCompletion) {
        // After we've successfully registered for push notifications set all of the preferences to IMMEDIATELY tostart sending push notifications
        self.remoteService.getUserCommunicationChannels({ (getChannelsResult) -> () in
            // result.value?.content
            if getChannelsResult.error != nil {
                registrationCompletion(RegisterPushNotificationTokenResult.failure(getChannelsResult.error!))
            } else if getChannelsResult.value != nil {
                if let channels: [CommunicationChannel] = getChannelsResult.value {
                    // Find push notification channel id
                    var channelID = ""
                    
                    for channel in channels {
                        if channel.type == .push {
                            channelID = channel.id
                            break
                        }
                    }
                    
                    if channelID != "" {
                        self.remoteService.getNotificationPreferences(channelID, completion: { (getNotificationResult) -> () in
                            if getNotificationResult.error != nil {
                                registrationCompletion(RegisterPushNotificationTokenResult.failure(getNotificationResult.error!))
                            } else if (getNotificationResult.value != nil) {
                                if let preferences: [NotificationPreference] = getNotificationResult.value {
                                    // We don't use/care about some preferences, strip those out so we're not setting values for ones that we don't let them change through the application
                                    let actualPreferences = preferences.filter { preference in
                                        switch preference.category {
                                        case "registration", "summaries", "other", "migration", "alert", "reminder", "recording_ready":
                                            return false
                                        default:
                                            return true
                                        }
                                    }
                                    
                                    // For the preferences that we care about, set them to Immediately
                                    for preference: NotificationPreference in actualPreferences {
                                        preference.frequency = NotificationPreference.Frequency.Immediately
                                    }
                                    
                                    self.remoteService.setNotificationPreferences(channelID, preferences: actualPreferences, completion: { (setPreferencesResult) -> () in
                                        if setPreferencesResult.error != nil {
                                            registrationCompletion(.failure(setPreferencesResult.error!))
                                        } else if (setPreferencesResult.value != nil) {
                                            // need to set the key/value data indicating that this process has happened so that any settings updated by the user after this or on different devices doesn't get overwritten
                                            self.remoteService.updateNotificationPreferencesSetup({ (updateNotificationPreferencesSetupResult) -> () in
                                                if updateNotificationPreferencesSetupResult.error != nil {
                                                    // error
                                                    registrationCompletion(.failure(updateNotificationPreferencesSetupResult.error!))
                                                } else {
                                                    registrationCompletion(.success())
                                                }
                                            })
                                        }
                                    })
                                } else {
                                    
                                    let localizedDescription = NSLocalizedString("Unable to parse JSON for communication channels", tableName: "Localizable", bundle: .core, comment: "Error message when parsing communication preferences")
                                    let error = NSError.simpleError(localizedDescription, code: 90210)
                                    registrationCompletion(.failure(error))
                                }
                            }
                        })
                    } else {
                        
                        let localizedDescription = NSLocalizedString("No push channel found", tableName: "Localizable", bundle: .core, comment: "Error when push channel cannot be found in notificaitons")
                        let error = NSError.simpleError(localizedDescription, code: 90211)
                        registrationCompletion(.failure(error))
                    }
                } else {
                    let localizedDescription = NSLocalizedString("Unable to parse JSON for notification preferences", tableName: "Localizable", bundle: .core, comment: "Error message when parsing notification preferences")
                    let error = NSError.simpleError(localizedDescription, code: 90212)
                    registrationCompletion(.failure(error))
                }
            }
        })

    }
    
    public typealias CommunicationChannelsCompletion = (_ result: Result<[CommunicationChannel], NSError>) -> ()
    open func getCommunicationChannels(_ completion: @escaping CommunicationChannelsCompletion) {
        self.remoteService.getUserCommunicationChannels { (result) -> () in
            completion(result)
        }
    }
    
    public typealias NotificationPreferencesCompletion = (_ result: Result<[NotificationPreference], NSError>) -> ()
    open func getNotificationPreferences(_ channel: CommunicationChannel, completion: @escaping NotificationPreferencesCompletion) {
        self.remoteService.getNotificationPreferences(channel.id, completion: { (result) -> () in
            completion(result)
        })
    }
    
    public typealias SetNotificationPreferencesCompletion = (_ result: Result<Bool, NSError>) -> ()
    open func setNotificationPreferences(_ channel: CommunicationChannel, preferences: [NotificationPreference], completion: @escaping SetNotificationPreferencesCompletion) {
        self.remoteService.setNotificationPreferences(channel.id, preferences: preferences) { (result) -> () in
            completion(result)
        }
    }


    // MARK: Pre-authorization for Push Notifications
    open static func registerForPushNotifications() {
        if NSClassFromString("EarlGreyImpl") != nil { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    #if !arch(i386) && !arch(x86_64) // Can't register on simulator
                        UIApplication.shared.registerForRemoteNotifications()
                    #endif
                }
            }
        }
    }
}
