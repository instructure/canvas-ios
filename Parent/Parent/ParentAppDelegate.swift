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
import CanvasCore
import CanvasKeymaster
import Fabric
import Crashlytics
import BugsnagReactNative
import UserNotifications

let TheKeymaster = CanvasKeymaster.the()
let ParentAppRefresherTTL: TimeInterval = 5.minutes

@UIApplicationMain
class ParentAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var session: Session?
    let loginConfig = LoginConfiguration(mobileVerifyName: "iosParent",
                                         logo: UIImage(named: "parent-logomark")!,
                                         fullLogo: UIImage(named: "parent-logo")!,
                                         supportsCanvasNetworkLogin: false,
                                         whatsNewURL: "https://s3.amazonaws.com/tr-learncanvas/docs/WhatsNewCanvasParent.pdf")
    
    var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if !uiTesting {
            configureBugSnag()
            setupCrashlytics()
        }
        
        ResetAppIfNecessary()
        
        TheKeymaster.fetchesBranding = false
        TheKeymaster.delegate = loginConfig
        
        window = MasqueradableWindow(frame: UIScreen.main.bounds)
        showLoadingState()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.postLaunchSetup()
        }

        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return openCanvasURL(url)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.handleLaunch()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        LocalizationManager.closed()
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
    
    func openCanvasURL(_ url: URL) -> Bool {
        if url.scheme == "canvas-parent" {
            if let _ = session {
                Router.sharedInstance.route(visibleController, toURL: url, modal: false)
            } else if let window = window, let vc = Router.sharedInstance.viewControllerForURL(url) {
                Router.sharedInstance.route(window, toRootViewController: vc)
            } else {
                // should never get here... should either have a session or a window!
            }
        }
        
        return false
    }
    
    func routeToRemindable(from response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let urlString = userInfo[RemindableActionURLKey] as? String, let url = URL(string: urlString) {
            Router.sharedInstance.route(visibleController, toURL: url, modal: true)
        }
    }
}

// MARK: Post launch setup
extension ParentAppDelegate {
    
    func postLaunchSetup() {
        prepareReactNative()
        setupDefaultErrorHandling()
    }
}

// MARK: Logging in/out
extension ParentAppDelegate {
    
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
extension ParentAppDelegate {
    
    func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
        guard let presentFrom = presentingViewController else { return }
        
        DispatchQueue.main.async {
            let alertDetails = error.alertDetails(reportAction: {
                // TODO
                //let support = SupportTicketViewController.present(from: presentingViewController, supportTicketType: SupportTicketTypeProblem)
                //support?.reportedError = error
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
    
    
    
    func handleError(_ error: NSError) {
        ErrorReporter.reportError(error, from: window?.rootViewController)
    }
}

// MARK: Crashlytics
extension ParentAppDelegate {
    
    func setupCrashlytics() {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: "Fabric") else {
            NSLog("WARNING: Crashlytics was not properly initialized.");
            return
        }
        
        Fabric.with([Crashlytics.self])
    }
}


extension ParentAppDelegate: NativeLoginManagerDelegate {
    func didLogin(_ client: CKIClient) {
        self.session = client.authSession
        
        // UX requires that students are given color schemes in a specific order.
        // The method call below ensures that we always start with the first color scheme.
        ColorCoordinator.clearColorSchemeDictionary()
        // TODO: use logged in locale
        // LocalizationManager.setCurrentLocale(client.locale)
    }
    
    func didLogout(_ controller: UIViewController) {
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = controller
        }, completion:nil)
    }
}

// MARK: UNUserNotificationCenterDelegate
extension ParentAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        StartupManager.shared.enqueueTask { [weak self] in
            self?.routeToRemindable(from: response)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
