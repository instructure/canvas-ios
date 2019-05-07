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

import AVKit
import UIKit
import TechDebt
import PSPDFKit
import CanvasKeymaster
import Fabric
import Crashlytics
import CanvasCore
import ReactiveSwift
import UserNotifications
import Firebase
import Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)
    @objc var session: Session?

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Router.shared()
        return env
    }()

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        environment.logger.log(#function)
        setupCrashlytics()
        ResetAppIfNecessary()
        if hasFirebase {
            FirebaseApp.configure()
        }
        DocViewerViewController.setup(.studentPSPDFKitLicense)
        if let key = Secret.studentPSPDFKitLicense.string {
           PSPDFKit.setLicenseKey(key)
        }
        prepareReactNative()
        NetworkMonitor.engage()
        Router.shared().addCanvasRoutes(handleError)
        setupDefaultErrorHandling()
        UIApplication.shared.reactive.applicationIconBadgeNumber
            <~ TabBarBadgeCounts.applicationIconBadgeNumber
        CanvasAnalytics.setHandler(self)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        if let session = Keychain.mostRecentSession {
            window?.rootViewController = LoadingViewController.create()
            userDidLogin(keychainEntry: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true)
        }
        window?.makeKeyAndVisible()
        return true
    }

    func setup(session: KeychainEntry) {
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }
        if hasFirebase {
            Analytics.setUserID(session.userID)
            Analytics.setUserProperty(session.baseURL.absoluteString, forName: "base_url")
        }

        // Legacy CanvasKeymaster support
        let legacyClient = CKIClient(baseURL: session.baseURL, token: session.accessToken)!
        legacyClient.actAsUserID = session.actAsUserID
        legacyClient.originalIDOfMasqueradingUser = session.originalUserID
        legacyClient.originalBaseURL = session.originalBaseURL
        legacyClient.fetchCurrentUser().subscribeNext { user in
            legacyClient.setValue(user, forKey: "currentUser")
            CanvasKeymaster.the().setup(with: legacyClient)
            self.session = legacyClient.authSession
            PageViewEventController.instance.userDidChange()
            LegacyModuleProgressShim.observeProgress(legacyClient.authSession)
            ModuleItem.beginObservingProgress(legacyClient.authSession)
            CKCanvasAPI.updateCurrentAPI()
            GetBrandVariables().fetch(environment: self.environment) { response, _, _ in
                Brand.setCurrent(Brand(core: Core.Brand.shared), applyInWindow: self.window)
                NativeLoginManager.login(as: session)
            }
        }
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return openCanvasURL(url)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.application(application, handleOpen: url)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return openCanvasURL(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.handleLaunch()
        CoreWebView.keepCookieAlive(for: environment)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        environment.logger.log(#function)
        CoreWebView.stopCookieKeepAlive()
        CanvasCore.LocalizationManager.closed()
    }
}

// MARK: Push notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationKitController.didRegisterForRemoteNotifications(deviceToken, errorHandler: handlePushNotificationRegistrationError)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handlePushNotificationRegistrationError((error as NSError).addingInfo())
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        StartupManager.shared.enqueueTask { [weak self] in
            PushNotifications.record(response.notification)
            let userInfo = response.notification.request.content.userInfo

            // Handle local notifications we know about first
            if let assignmentURL = userInfo[CBILocalNotificationAssignmentURLKey] as? String,
                let url = URL(string: assignmentURL) {
                self?.openCanvasURL(url)
                return
            } else if let routerURL = userInfo[NotificationManager.RouteURLKey] as? String,
                let url = URL(string: routerURL) {
                self?.openCanvasURL(url)
                return
            }

            // Must be a push notification
            self?.routeToPushNotificationPayloadURL(userInfo)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    @objc func handlePushNotificationRegistrationError(_ error: NSError) {
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["source": "push_notification_registration"])
    }
}

extension AppDelegate: CanvasAnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String : Any]?) {
        if hasFirebase {
            Analytics.logEvent(name, parameters: parameters)
        }
    }
}

// MARK: Logging in/out
extension AppDelegate {
    
    @objc func addClearCacheGesture(_ view: UIView) {
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(clearCache))
        clearCacheGesture.numberOfTapsRequired = 3
        clearCacheGesture.numberOfTouchesRequired = 4
        view.addGestureRecognizer(clearCacheGesture)
    }
    
    @objc func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        let alert = UIAlertController(title: NSLocalizedString("Cache cleared", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: nil))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: SoErroneous
extension AppDelegate {
    
    @objc func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
        guard let presentFrom = presentingViewController else { return }
        
        DispatchQueue.main.async {
            let alertDetails = error.alertDetails(reportAction: {
                let support = SupportTicketViewController.present(from: presentingViewController, supportTicketType: SupportTicketTypeProblem, defaultSubject: nil)
                support?.reportedError = error
            })
            
            if let deets = alertDetails {
                let alert = UIAlertController(title: deets.title, message: deets.description, preferredStyle: .alert)
                deets.actions.forEach(alert.addAction)
                presentFrom.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func setupDefaultErrorHandling() {
        CanvasCore.ErrorReporter.setErrorHandler({ error, presentingViewController in
            self.alertUser(of: error, from: presentingViewController)
            
            if error.shouldRecordInCrashlytics {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: nil)
            }
        })
    }
    
    @objc func handleError(_ error: NSError) {
        DispatchQueue.main.async {
            ErrorReporter.reportError(error, from: self.window?.rootViewController)
        }
    }
}

// MARK: Crashlytics
extension AppDelegate {
    
    @objc func setupCrashlytics() {
        guard !uiTesting else { return }
        guard hasFabric else {
            NSLog("WARNING: Crashlytics was not properly initialized.");
            return
        }
        
        Fabric.with([Crashlytics.self])
        CanvasCrashlytics.setupForReactNative()
    }
}


// MARK: Launching URLS
extension AppDelegate {
    @objc @discardableResult func openCanvasURL(_ url: URL) -> Bool {
        if Keychain.mostRecentSession == nil, let host = url.host {
            let loginNav = LoginNavigationController.create(loginDelegate: self)
            loginNav.login(host: host)
            window?.rootViewController = loginNav
        }
        // the student app doesn't have as predictable of a tab bar setup and for
        // several views, does not have a route configured for them so for now we
        // will hard code until we move more things over to helm
        let tabRoutes = [["/", "", "/courses", "/groups"], ["/calendar"], ["/to-do"], ["/notifications"], ["/conversations", "/inbox"]]
        StartupManager.shared.enqueueTask({ [weak self] in
            let path = url.path
            var index: Int?
            
            for (i, element) in tabRoutes.enumerated() {
                if let _ = element.firstIndex(of: path) {
                    index = i
                    break
                }
            }
            
            if let i = index {
                guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else { return }
                
                let finish = {
                    tabBarController.selectedIndex = i
                    tabBarController.resetSelectedViewController()
                }
                
                if let _ = tabBarController.presentedViewController {
                    tabBarController.dismiss(animated: true, completion: {
                        DispatchQueue.main.async(execute: finish)
                    })
                } else {
                    finish()
                }
            } else {
                
                if handleDropboxOpenURL(url) {
                    return
                }
                
                if url.scheme == "file" {
                    do {
                        try ReceivedFilesViewController.add(toReceivedFiles: url)
                    } catch let e as NSError {
                        self?.handleError(e)
                    }
                } else {
                    Router.shared().openCanvasURL(url, withOptions: ["modal": true])
                }
            }
        })        
        return true
    }
}

extension AppDelegate: LoginDelegate, NativeLoginManagerDelegate {
    var loginLogo: UIImage { return UIImage(named: "student-logo")! }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self)
        }, completion: nil)
    }

    func stopActing() {
        if let session = environment.currentSession {
            stopActing(as: session)
        }
    }

    func logout() {
        if let session = environment.currentSession {
            userDidLogout(keychainEntry: session)
        }
    }

    func openExternalURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func userDidLogin(keychainEntry: KeychainEntry) {
        Keychain.addEntry(keychainEntry)
        if let locale = keychainEntry.locale {
            CanvasCore.LocalizationManager.setCurrentLocale(locale)
            if CanvasCore.LocalizationManager.needsRestart { return }
        }
        setup(session: keychainEntry)
    }

    func userDidStopActing(as keychainEntry: KeychainEntry) {
        Keychain.removeEntry(keychainEntry)
        guard environment.currentSession == keychainEntry else { return }
        PageViewEventController.instance.userDidChange()
        NotificationKitController.deregisterPushNotifications { _ in }
        UIApplication.shared.applicationIconBadgeNumber = 0
        environment.userDidLogout(session: keychainEntry)
        CoreWebView.stopCookieKeepAlive()
    }

    func userDidLogout(keychainEntry: KeychainEntry) {
        let wasCurrent = environment.currentSession == keychainEntry
        userDidStopActing(as: keychainEntry)
        if wasCurrent { changeUser() }
    }
}

//  MARK: - Handle siri notifications
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let path = userActivity.userInfo?["url"] as? String, let url = URL(string: path) {
            openCanvasURL(url)
            return true
        }
        return false
    }
}

