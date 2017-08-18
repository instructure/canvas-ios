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
import TooLegit
import Result


open class NotificationKitController {
    
    fileprivate var remoteService: RemoteService
    
    public init(session: Session) {
        self.remoteService = RemoteService(session: session)    }
    
    public enum RegisterPushNotificationTokenResult {
        case success()
        case error(NSError)
    }
    
    // This is super ugly, change with Swift 2.0 - guard
    public typealias RegisterPushNotificationTokenCompletion = (_ result: RegisterPushNotificationTokenResult) -> ()
    open func registerPushNotificationTokenWithPushService(_ deviceToken: Data, registrationCompletion: @escaping RegisterPushNotificationTokenCompletion) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        self.remoteService.registerPushNotificationTokenWithPushService(token, completion: { (pushNotificationRegistrationResult) -> () in
            
            if pushNotificationRegistrationResult.error != nil {
                registrationCompletion(RegisterPushNotificationTokenResult.error(pushNotificationRegistrationResult.error!))
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
                            registrationCompletion(RegisterPushNotificationTokenResult.error(notificationPreferencesResult.error!))
                        }
                    } else {
                        // There's no need to look at the data at this point, if it's able to fetch the data then we don't need to setup the notification preferences, the only way a value gets there is if the values get setup
                        registrationCompletion(RegisterPushNotificationTokenResult.success())
                    }
                })
            }
        })
    }
    
    // This is super ugly, change with Swift 2.0 - guard
    fileprivate func setNotificationPreferenceDefaults(_ registrationCompletion: @escaping RegisterPushNotificationTokenCompletion) {
        // After we've successfully registered for push notifications set all of the preferences to IMMEDIATELY tostart sending push notifications
        self.remoteService.getUserCommunicationChannels({ (getChannelsResult) -> () in
            // result.value?.content
            if getChannelsResult.error != nil {
                registrationCompletion(RegisterPushNotificationTokenResult.error(getChannelsResult.error!))
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
                                registrationCompletion(RegisterPushNotificationTokenResult.error(getNotificationResult.error!))
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
                                            registrationCompletion(.error(setPreferencesResult.error!))
                                        } else if (setPreferencesResult.value != nil) {
                                            // need to set the key/value data indicating that this process has happened so that any settings updated by the user after this or on different devices doesn't get overwritten
                                            self.remoteService.updateNotificationPreferencesSetup({ (updateNotificationPreferencesSetupResult) -> () in
                                                if updateNotificationPreferencesSetupResult.error != nil {
                                                    // error
                                                    registrationCompletion(.error(updateNotificationPreferencesSetupResult.error!))
                                                } else {
                                                    registrationCompletion(.success())
                                                }
                                            })
                                        }
                                    })
                                } else {
                                    
                                    let localizedDescription = NSLocalizedString("Unable to parse JSON for communication channels", tableName: "Localizable", bundle: .notificationKit(), comment: "Error message when parsing communication preferences")
                                    let error = NSError.simpleError(localizedDescription, code: 90210)
                                    registrationCompletion(.error(error))
                                }
                            }
                        })
                    } else {
                        
                        let localizedDescription = NSLocalizedString("No push channel found", tableName: "Localizable", bundle: .notificationKit(), comment: "Error when push channel cannot be found in notificaitons")
                        let error = NSError.simpleError(localizedDescription, code: 90211)
                        registrationCompletion(.error(error))
                    }
                } else {
                    let localizedDescription = NSLocalizedString("Unable to parse JSON for notification preferences", tableName: "Localizable", bundle: .notificationKit(), comment: "Error message when parsing notification preferences")
                    let error = NSError.simpleError(localizedDescription, code: 90212)
                    registrationCompletion(.error(error))
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
    open static func registerForPushNotificationsIfAppropriate(_ controller: UIViewController) {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            return
        }
        if PushPreAuthStatus.currentPushPreAuthStatus() == .neverShown {
            showPreauthorizationAlert(controller)
        } else if PushPreAuthStatus.currentPushPreAuthStatus() != .shownAndDeclined {
            registerForRemoteNotifications()
        }
    }
    
    public typealias ShowPreauthorizationAlertCompletion = (_ result: Bool) -> ()
    open static func showPreauthorizationAlert(_ controller: UIViewController, completion: ShowPreauthorizationAlertCompletion? = nil) {
        let yesActionTitle = NSLocalizedString("Yes", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for yes button for push notification pre-authorization alert")
        let yesAction = UIAlertAction(title: yesActionTitle, style: UIAlertActionStyle.default) { (alertAction) -> Void in
            PushPreAuthStatus.setCurrentPushPreAuthStatus(PushPreAuthStatus.shownAndAccepted)
            if completion != nil {
                completion!(true)
            }
            self.registerForRemoteNotifications()
        }
        
        let noActionTitle = NSLocalizedString("No", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for no button for push notification pre-authorization alert")
        let noAction = UIAlertAction(title: noActionTitle, style: .cancel) { (alertAction) -> Void in
            PushPreAuthStatus.setCurrentPushPreAuthStatus(PushPreAuthStatus.shownAndDeclined)
            if completion != nil {
                completion!(false)
            }
        }
        
        let alertTitle = NSLocalizedString("Allow Push Notifications?", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for push notification pre-authorization alert")
        let alertMessage = NSLocalizedString("Would you like to allow Canvas to send you important notifications about announcements, course, assignments, etc?", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Message for push notification pre-authorization alert")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Register for push
    open static func registerForRemoteNotifications() {
        let categories = Set<UIUserNotificationCategory>()
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    // MARK: Unregister for push
    open static func unregisterForRemoteNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}
