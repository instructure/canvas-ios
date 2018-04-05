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

import UIKit
import TechDebt
import PSPDFKit
import CanvasKeymaster
import Fabric
import Crashlytics
import CanvasCore
import ReactiveSwift
import BugsnagReactNative
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let loginConfig = LoginConfiguration(mobileVerifyName: "iCanvas", logo: UIImage(named: "student-logomark")!, fullLogo: UIImage(named: "student-logo")!)
    var session: Session?
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if unitTesting {
            return true
        }

        if (uiTesting) {
            BuddyBuildSDK.setup()
        } else {
            configureBugSnag()
            setupCrashlytics()
        }
        NotificationKitController.setupForPushNotifications(delegate: self)
        TheKeymaster.fetchesBranding = true
        TheKeymaster.delegate = loginConfig
        
        window = MasqueradableWindow(frame: UIScreen.main.bounds)
        showLoadingState()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.postLaunchSetup()
        }
        
        return true
    }
    
    func showLoadingState() {
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
    
    func configureBugSnag() {
        let configuration = BugsnagConfiguration()
        configuration.add { (data, report) -> Bool in
            var user = Dictionary<String, String>()
            let region = Locale.current.regionCode
            if let session = self.session, region != "CA" {
                user["baseURL"] = session.baseURL.absoluteString
                user["id"] = session.user.id
                report.addMetadata(user, toTabWithName: "user")
            }
            return true
        }
        BugsnagReactNative.start(with: configuration)
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "FakeCrash"), object: nil, queue: nil) { _  in
            let exception = NSException(name:NSExceptionName(rawValue: "FakeException"),
                                        reason:"The red coats are coming, the red coats are coming!",
                                        userInfo:nil)
            Bugsnag.notify(exception)
        }
    }
}

// MARK: Push notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationKitController.didRegisterForRemoteNotifications(deviceToken, errorHandler: handleError)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handleError((error as NSError).addingInfo())
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
            }

            // Must be a push notification
            self?.routeToPushNotificationPayloadURL(userInfo)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.requestReview()
    }
}

// MARK: Post launch setup
extension AppDelegate {
    
    func postLaunchSetup() {
        PSPDFKit.license()
        prepareReactNative()
        Analytics.prepare()
        NetworkMonitor.engage()
        CBILogger.install(loginConfig.logFileManager)
        excludeHelmInBranding()
        Router.shared().addCanvasRoutes(handleError)
        setupDefaultErrorHandling()
        UIApplication.shared.reactive.applicationIconBadgeNumber
            <~ TabBarBadgeCounts.applicationIconBadgeNumber
    }
}

// MARK: Logging in/out
extension AppDelegate {
    
    func addClearCacheGesture(_ view: UIView) {
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(clearCache))
        clearCacheGesture.numberOfTapsRequired = 3
        clearCacheGesture.numberOfTouchesRequired = 4
        view.addGestureRecognizer(clearCacheGesture)
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        let alert = UIAlertController(title: NSLocalizedString("Cache cleared", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: nil))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: SoErroneous
extension AppDelegate {
    
    func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
        guard let presentFrom = presentingViewController else { return }
        
        DispatchQueue.main.async {
            let alertDetails = error.alertDetails(reportAction: {
                let support = SupportTicketViewController.present(from: presentingViewController, supportTicketType: SupportTicketTypeProblem)
                support?.reportedError = error
            })
            
            if let deets = alertDetails {
                let alert = UIAlertController(title: deets.title, message: deets.description, preferredStyle: .alert)
                deets.actions.forEach(alert.addAction)
                presentFrom.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setupDefaultErrorHandling() {
        CanvasCore.ErrorReporter.setErrorHandler({ error, presentingViewController in
            self.alertUser(of: error, from: presentingViewController)
            
            if error.shouldRecordInCrashlytics {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: nil)
            }
        })
    }
    
    var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    
    func handleError(_ error: NSError) {
        ErrorReporter.reportError(error, from: window?.rootViewController)
    }
}

// MARK: Crashlytics
extension AppDelegate {
    
    func setupCrashlytics() {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: "Fabric") else {
            NSLog("WARNING: Crashlytics was not properly initialized.");
            return
        }
        
        Fabric.with([Crashlytics.self])
    }
}


// MARK: Launching URLS
extension AppDelegate {
    @discardableResult func openCanvasURL(_ url: URL) -> Bool {
        // the student app doesn't have as predictable of a tab bar setup and for
        // several views, does not have a route configured for them so for now we
        // will hard code until we move more things over to helm
        let tabRoutes = [["/", "", "/courses"], ["/calendar"], ["/to-do"], ["/notifications"], ["/conversations", "/inbox"]]
        StartupManager.shared.enqueueTask({
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
                tabBarController.selectedIndex = i
                tabBarController.resetSelectedViewController()
            } else {
                
                if handleDropboxOpenURL(url) {
                    return
                }
                
                if url.scheme == "file" {
                    do {
                        try ReceivedFilesViewController.add(toReceivedFiles: url)
                    } catch let e as NSError {
                        self.handleError(e)
                    }
                } else {
                    Router.shared().openCanvasURL(url)
                }
            }
        })        
        return true
    }
}

extension AppDelegate: NativeLoginManagerDelegate {
    func didLogin(_ client: CKIClient) {
        let session = client.authSession
        self.session = session
        
        LegacyModuleProgressShim.observeProgress(session)
        ModuleItem.beginObservingProgress(session)
        CKCanvasAPI.updateCurrentAPI()
        
        if let brandingInfo = client.branding?.jsonDictionary() as? [String: Any] {
            Brand.setCurrent(Brand(webPayload: brandingInfo), applyInWindow: window)
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = controller
        }, completion:nil)
    }
}
