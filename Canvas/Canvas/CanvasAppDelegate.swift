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
    var window: UIWindow? = MasqueradableWindow(frame: UIScreen.main.bounds)
    @objc let loginConfig = LoginConfiguration(mobileVerifyName: "iCanvas", logo: UIImage(named: "student-logomark")!, fullLogo: UIImage(named: "student-logo")!)
    @objc var session: Session?

    let appID = Bundle.main.bundleIdentifier ?? "com.instructure.icanvas"
    let appGroup = "group.com.instructure.icanvas"

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
        NotificationKitController.setupForPushNotifications(delegate: self)
        TheKeymaster.fetchesBranding = true
        TheKeymaster.delegate = loginConfig
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        showLoadingState()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.postLaunchSetup()
        }
        
        return true
    }
    
    @objc func showLoadingState() {
        guard let window = self.window else { return }
        if let root = window.rootViewController, let tag = root.tag, tag == "LaunchScreenPlaceholder" { return }
        let placeholder = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        placeholder.tag = "LaunchScreenPlaceholder"
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = placeholder
        }, completion:nil)
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

// MARK: Post launch setup
extension AppDelegate {
    
    @objc func postLaunchSetup() {
        PSPDFKit.license()
        prepareReactNative()
        NetworkMonitor.engage()
        excludeHelmInBranding()
        Router.shared().addCanvasRoutes(handleError)
        setupDefaultErrorHandling()
        UIApplication.shared.reactive.applicationIconBadgeNumber
            <~ TabBarBadgeCounts.applicationIconBadgeNumber
        CanvasAnalytics.setHandler(self)
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
    
    @objc var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
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
        if TheKeymaster.numberOfClients == 0, let host = url.host {
            TheKeymaster.login(withSuggestedDomain: host)
        }
        // the student app doesn't have as predictable of a tab bar setup and for
        // several views, does not have a route configured for them so for now we
        // will hard code until we move more things over to helm
        let tabRoutes = [["/", "", "/courses", "/groups"], ["/calendar"], ["/to-do"], ["/notifications"], ["/conversations", "/inbox"]]
        StartupManager.shared.enqueueTask({ [weak self] in
            let path = url.path
            var index: Int?
            
            for (i, element) in tabRoutes.enumerated() {
                if let _ = element.index(of: path) {
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

extension AppDelegate: NativeLoginManagerDelegate {
    func willLogout() {
        CoreWebView.stopCookieKeepAlive()
        PageViewEventController.instance.userDidChange()
    }
    
    func didLogin(_ client: CKIClient) {
        let session = client.authSession
        self.session = session
        PageViewEventController.instance.userDidChange()
        LegacyModuleProgressShim.observeProgress(session)
        ModuleItem.beginObservingProgress(session)
        CKCanvasAPI.updateCurrentAPI()
        if hasFirebase {
            Analytics.setUserID(client.currentUser.id)
            Analytics.setUserProperty(client.baseURL?.absoluteString, forName: "base_url")
        }
        if let entry = client.keychainEntry {
            Keychain.addEntry(entry)
            environment.userDidLogin(session: entry)
            CoreWebView.keepCookieAlive(for: environment)
        }

        if let brandingInfo = client.branding?.jsonDictionary() as? [String: Any] {
            Brand.setCurrent(Brand(webPayload: brandingInfo), applyInWindow: window)
            // copy to new Core.Brand
            if let data = try? JSONSerialization.data(withJSONObject: brandingInfo) {
                let response = try! JSONDecoder().decode(APIBrandVariables.self, from: data)
                Core.Brand.shared = Core.Brand(response: response)
            }
        }

        if let locale = client.effectiveLocale {
            CanvasCore.LocalizationManager.setCurrentLocale(locale)
		}

        let countryCode: String? = Locale.current.regionCode
        if countryCode != "CA" {
            let crashlyticsUserId = "\(session.user.id)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        if let entry = environment.currentSession {
            environment.userDidLogout(session: entry)
            CoreWebView.stopCookieKeepAlive()
        }
        Keychain.clearEntries()
        NotificationKitController.deregisterPushNotifications { _ in
            // this is a no-op because we don't want errors to prevent logging out
        }
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = controller
        }, completion:nil)
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

