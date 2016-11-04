
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


public class NotificationKitController {
    
    private var remoteService: RemoteService
    
    public init(session: Session) {
        self.remoteService = RemoteService(session: session)    }
    
    public enum RegisterPushNotificationTokenResult {
        case Success()
        case Error(NSError)
    }
    
    // This is super ugly, change with Swift 2.0 - guard
    public typealias RegisterPushNotificationTokenCompletion = (result: RegisterPushNotificationTokenResult) -> ()
    public func registerPushNotificationTokenWithPushService(deviceToken: NSData, registrationCompletion: RegisterPushNotificationTokenCompletion) {
        let token = PushNotificationToken(deviceTokenData: deviceToken)
        self.remoteService.registerPushNotificationTokenWithPushService(token, completion: { (pushNotificationRegistrationResult) -> () in
            
            if pushNotificationRegistrationResult.error != nil {
                registrationCompletion(result: RegisterPushNotificationTokenResult.Error(pushNotificationRegistrationResult.error!))
            } else if pushNotificationRegistrationResult.value != nil {
                
                // Verify whether user has previously set up notification preferences
                self.remoteService.getNotificationPreferencesSetup({ (notificationPreferencesResult) -> () in
                    if notificationPreferencesResult.error != nil {
                        // nothing has been saved for the piece that we're looking at
                        // TODO: How can we make this more robust with the Request stuff?  a problem for future generations
                        if notificationPreferencesResult.error!.code == 400 && notificationPreferencesResult.error!.localizedFailureReason == "no data for scope" {
                            // should do setup
                            self.setNotificationPreferenceDefaults(registrationCompletion)
                        } else {
                            // actually had an error, return that
                            registrationCompletion(result: RegisterPushNotificationTokenResult.Error(notificationPreferencesResult.error!))
                        }
                    } else {
                        // There's no need to look at the data at this point, if it's able to fetch the data then we don't need to setup the notification preferences, the only way a value gets there is if the values get setup
                        registrationCompletion(result: RegisterPushNotificationTokenResult.Success())
                    }
                })
            }
        })
    }
    
    // This is super ugly, change with Swift 2.0 - guard
    private func setNotificationPreferenceDefaults(registrationCompletion: RegisterPushNotificationTokenCompletion) {
        // After we've successfully registered for push notifications set all of the preferences to IMMEDIATELY tostart sending push notifications
        self.remoteService.getUserCommunicationChannels({ (getChannelsResult) -> () in
            // result.value?.content
            if getChannelsResult.error != nil {
                registrationCompletion(result: RegisterPushNotificationTokenResult.Error(getChannelsResult.error!))
            } else if getChannelsResult.value != nil {
                if let channels: [CommunicationChannel] = getChannelsResult.value {
                    // Find push notification channel id
                    var channelID = ""
                    
                    for channel in channels {
                        if channel.type == CommunicationChannelType.Push {
                            channelID = channel.id
                            break
                        }
                    }
                    
                    if channelID != "" {
                        self.remoteService.getNotificationPreferences(channelID, completion: { (getNotificationResult) -> () in
                            if getNotificationResult.error != nil {
                                registrationCompletion(result: RegisterPushNotificationTokenResult.Error(getNotificationResult.error!))
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
                                            registrationCompletion(result: RegisterPushNotificationTokenResult.Error(setPreferencesResult.error!))
                                        } else if (setPreferencesResult.value != nil) {
                                            // need to set the key/value data indicating that this process has happened so that any settings updated by the user after this or on different devices doesn't get overwritten
                                            self.remoteService.updateNotificationPreferencesSetup({ (updateNotificationPreferencesSetupResult) -> () in
                                                if updateNotificationPreferencesSetupResult.error != nil {
                                                    // error
                                                    registrationCompletion(result: RegisterPushNotificationTokenResult.Error(updateNotificationPreferencesSetupResult.error!))
                                                } else {
                                                    registrationCompletion(result: RegisterPushNotificationTokenResult.Success())
                                                }
                                            })
                                        }
                                    })
                                } else {
                                    
                                    let localizedDescription = NSLocalizedString("Unable to parse JSON for communication channels", tableName: "Localizable", bundle: .notificationKit(), comment: "Error message when parsing communication preferences")
                                    let error = NSError.simpleError(localizedDescription, code: 90210)
                                    registrationCompletion(result: RegisterPushNotificationTokenResult.Error(error))
                                }
                            }
                        })
                    } else {
                        
                        let localizedDescription = NSLocalizedString("No push channel found", tableName: "Localizable", bundle: .notificationKit(), comment: "Error when push channel cannot be found in notificaitons")
                        let error = NSError.simpleError(localizedDescription, code: 90211)
                        registrationCompletion(result: RegisterPushNotificationTokenResult.Error(error))
                    }
                } else {
                    let localizedDescription = NSLocalizedString("Unable to parse JSON for notification preferences", tableName: "Localizable", bundle: .notificationKit(), comment: "Error message when parsing notification preferences")
                    let error = NSError.simpleError(localizedDescription, code: 90212)
                    registrationCompletion(result: RegisterPushNotificationTokenResult.Error(error))
                }
            }
        })

    }
    
    public typealias CommunicationChannelsCompletion = (result: Result<[CommunicationChannel], NSError>) -> ()
    public func getCommunicationChannels(completion: CommunicationChannelsCompletion) {
        self.remoteService.getUserCommunicationChannels { (result) -> () in
            completion(result: result)
        }
    }
    
    public typealias NotificationPreferencesCompletion = (result: Result<[NotificationPreference], NSError>) -> ()
    public func getNotificationPreferences(channel: CommunicationChannel, completion: NotificationPreferencesCompletion) {
        self.remoteService.getNotificationPreferences(channel.id, completion: { (result) -> () in
            completion(result: result)
        })
    }
    
    public typealias SetNotificationPreferencesCompletion = (result: Result<Bool, NSError>) -> ()
    public func setNotificationPreferences(channel: CommunicationChannel, preferences: [NotificationPreference], completion: SetNotificationPreferencesCompletion) {
        self.remoteService.setNotificationPreferences(channel.id, preferences: preferences) { (result) -> () in
            completion(result: result)
        }
    }


    // MARK: Pre-authorization for Push Notifications
    public static func registerForPushNotificationsIfAppropriate(controller: UIViewController) {
        if PushPreAuthStatus.currentPushPreAuthStatus() == .NeverShown && !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            showPreauthorizationAlert(controller)
        } else if PushPreAuthStatus.currentPushPreAuthStatus() != .ShownAndDeclined {
            registerForRemoteNotifications()
        }
    }
    
    public typealias ShowPreauthorizationAlertCompletion = (result: Bool) -> ()
    public static func showPreauthorizationAlert(controller: UIViewController, completion: ShowPreauthorizationAlertCompletion? = nil) {
        let yesActionTitle = NSLocalizedString("Yes", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for yes button for push notification pre-authorization alert")
        let yesAction = UIAlertAction(title: yesActionTitle, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            PushPreAuthStatus.setCurrentPushPreAuthStatus(PushPreAuthStatus.ShownAndAccepted)
            if completion != nil {
                completion!(result: true)
            }
            self.registerForRemoteNotifications()
        }
        
        let noActionTitle = NSLocalizedString("No", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for no button for push notification pre-authorization alert")
        let noAction = UIAlertAction(title: noActionTitle, style: .Cancel) { (alertAction) -> Void in
            PushPreAuthStatus.setCurrentPushPreAuthStatus(PushPreAuthStatus.ShownAndDeclined)
            if completion != nil {
                completion!(result: false)
            }
        }
        
        let alertTitle = NSLocalizedString("Allow Push Notifications?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for push notification pre-authorization alert")
        let alertMessage = NSLocalizedString("Would you like to allow Canvas to send you important notifications about announcements, course, assignments, etc?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Message for push notification pre-authorization alert")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Register for push
    public static func registerForRemoteNotifications() {
        let categories = Set<UIUserNotificationCategory>()
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    // MARK: Unregister for push
    public static func unregisterForRemoteNotifications() {
        UIApplication.sharedApplication().unregisterForRemoteNotifications()
    }
}
