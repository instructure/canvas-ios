//
// Copyright (C) 2018-present Instructure, Inc.
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

let TheKeymaster = CanvasKeymaster.the()

//@UIApplicationMain
class ParentAppDelegate: UIResponder, AppDelegateProtocol {

    var window: UIWindow?
    var session: Session?
    let loginConfig = LoginConfiguration(mobileVerifyName: "iosParent",
                                         logo: UIImage(named: "parent-logomark")!,
                                         fullLogo: UIImage(named: "parent-logo")!)
    
    var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if (uiTesting) {
            BuddyBuildSDK.setup()
        } else {
            configureBugSnag()
            setupCrashlytics()
        }
        
        UserDefaults.standard.set(true, forKey: "reset_cache_on_next_launch")
        
        // TODO: Remove when logging out is functioning
        ResetAppIfNecessary()
        
        TheKeymaster.fetchesBranding = false
        TheKeymaster.delegate = loginConfig
        
        window = MasqueradableWindow(frame: UIScreen.main.bounds)
        showLoadingState()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.postLaunchSetup()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return openCanvasURL(url)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.requestReview()

        // TODO
        //        if let session = Keymaster.sharedInstance.currentSession {
        //            AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
        //        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        // On, iOS 10.0b1 application:didReceiveLocalNotification is not being called when opening the app from a local notification and making it transistion from the background. Instead, this is being called. Not
        // sure if this is a bug or some change in API behavior.
        //
        // This api exists as of 9.0, but the odd behavior only exists as of 10.0, so...
        if #available(iOS 10.0, *) {
            routeToRemindable(from: notification)
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if application.applicationState == .active {
            let alert = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("View", comment: ""), style: .cancel, handler: { [unowned self] _ in
                self.routeToRemindable(from: notification)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in }))
            visibleController.present(alert, animated: true, completion: nil)
        } else if application.applicationState == .inactive {
            routeToRemindable(from: notification)
        }
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
    
    func routeToRemindable(from notification: UILocalNotification) {
        if let urlString = notification.userInfo?[RemindableActionURLKey] as? String, let url = URL(string: urlString) {
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
        // TODO
        //let session = client.authSession
        
        let parentID = "087e9ee5-e271-43cf-a9c3-cbef222ef0d8" // twilson: observer1/password
        let baseURL = URL(string: "https://airwolf-iad-prod.instructure.com")
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VybmFtZSI6IjYzNF9odHRwczovL3R3aWxzb24uaW5zdHJ1Y3R1cmUuY29tLyIsInBhcmVudF9pZCI6IjA4N2U5ZWU1LWUyNzEtNDNjZi1hOWMzLWNiZWYyMjJlZjBkOCIsInRva2VuSWQiOiIyOGQzMmMwYy1lMzg0LTQyMGEtOGFlOC03M2I5NGNmMjYxNzQiLCJpYXQiOjE1MjUzOTE0MjJ9.Jxh7jz14hHqMwMdc2xG6dhG97SE7P3OokVgWNDiEp_F9xgiBqr3x58-BwyhCNQPoSJVCty2zvNEkkVBec7KsTg"
        
        let sessionUser = SessionUser(id: parentID, name: "")
        self.session = Session(baseURL: baseURL!, user: sessionUser, token: token)
    }
    
    func didLogout(_ controller: UIViewController) {
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = controller
        }, completion:nil)
    }
}
