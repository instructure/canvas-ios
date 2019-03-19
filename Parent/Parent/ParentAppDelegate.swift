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
import Firebase
import UserNotifications
import Core

let TheKeymaster = CanvasKeymaster.the()
let ParentAppRefresherTTL: TimeInterval = 5.minutes

@UIApplicationMain
class ParentAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var legacySession: Session?
    var session: KeychainEntry?
    @objc let loginConfig = LoginConfiguration(mobileVerifyName: "iosParent",
                                         logo: UIImage(named: "parent-logomark")!,
                                         fullLogo: UIImage(named: "parent-logo")!,
                                         supportsCanvasNetworkLogin: false,
                                         whatsNewURL: "https://s3.amazonaws.com/tr-learncanvas/docs/WhatsNewCanvasParent.pdf")
    
    @objc var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        AppEnvironment.shared.router = Parent.router

        setupCrashlytics()
        ResetAppIfNecessary()
        if hasFirebase {
            FirebaseApp.configure()
        }
        
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

    @objc func showLoadingState() {
        guard let window = self.window else { return }
        if let root = window.rootViewController, let tag = root.tag, tag == "LaunchScreenPlaceholder" { return }
        let placeholder = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        placeholder.tag = "LaunchScreenPlaceholder"
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = placeholder
        }, completion:nil)
    }
    
    @objc func openCanvasURL(_ url: URL) -> Bool {
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
    
    @objc func routeToRemindable(from response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let urlString = userInfo[RemindableActionURLKey] as? String, let url = URL(string: urlString) {
            Router.sharedInstance.route(visibleController, toURL: url, modal: true)
        }
    }
}

// MARK: Post launch setup
extension ParentAppDelegate {
    @objc func postLaunchSetup() {
        NativeLoginManager.shared().setup()
        NativeLoginManager.shared().delegate = self
        NativeLoginManager.shared().app = .parent
        setupDefaultErrorHandling()
        CanvasAnalytics.setHandler(self)

        guard let lastSession = Keychain.mostRecentSession else {
            TheKeymaster.logout()
            return
        }

        self.session = lastSession
        self.legacySession = Session(baseURL: lastSession.baseURL, user: SessionUser(id: lastSession.userID, name: lastSession.userName, avatarURL: lastSession.userAvatarURL), token: lastSession.accessToken)
        self.didLogin(lastSession)
    }
}

// MARK: Logging in/out
extension ParentAppDelegate {
    
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
extension ParentAppDelegate {
    
    @objc func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
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
    
    @objc func setupDefaultErrorHandling() {
        CanvasCore.ErrorReporter.setErrorHandler({ error, presentingViewController in
            self.alertUser(of: error, from: presentingViewController)
            
            if error.shouldRecordInCrashlytics {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: nil)
            }
        })
    }
    
    
    
    @objc func handleError(_ error: NSError) {
        ErrorReporter.reportError(error, from: window?.rootViewController)
    }
}

// MARK: Crashlytics
extension ParentAppDelegate {
    
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

extension ParentAppDelegate: CanvasAnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String : Any]?) {
        if hasFirebase {
            Analytics.logEvent(name, parameters: parameters)
        }
    }
}

extension ParentAppDelegate: NativeLoginManagerDelegate {
    func didLogin(_ session: KeychainEntry) {
        guard let legacySession = self.legacySession else {
            return
        }
        Keychain.currentSession = session
        Keychain.addEntry(session)
        AppEnvironment.shared.userDidLogin(session: session)

        // UX requires that students are given color schemes in a specific order.
        // The method call below ensures that we always start with the first color scheme.
        ColorCoordinator.clearColorSchemeDictionary()
        // TODO: use logged in locale
        // LocalizationManager.setCurrentLocale(client.locale)

        let countryCode: String? = Locale.current.regionCode
        if countryCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }

        do {
            let refresher = try Student.observedStudentsRefresher(legacySession)
            refresher.refreshingCompleted.observeValues { [weak self] _ in
                guard let weakSelf = self, let window = weakSelf.window else { return }

                let dashboardHandler = Router.sharedInstance.parentDashboardHandler()
                guard let root = dashboardHandler(nil) else { return }

                weakSelf.addClearCacheGesture(root.view)

                UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    let loading = UIViewController()
                    loading.view.backgroundColor = .white
                    window.rootViewController = loading
                }, completion: { _ in
                    window.rootViewController = root
                })

            }
            refresher.refresh(true)
        } catch let e as NSError {
            print(e)
        }

        Router.sharedInstance.addRoutes()
        Router.sharedInstance.session = legacySession
        NotificationCenter.default.post(name: .loggedIn, object: self, userInfo: [LoggedInNotificationContentsSession: legacySession])
    }

    func didLogin(_ client: CKIClient) {
        self.legacySession = client.authSession
        guard let token = client.authSession.token else {
            return
        }

        let masquerader = client.originalBaseURL != nil
            ? client.originalBaseURL
                .appendingPathComponent("users")
                .appendingPathComponent(client.originalIDOfMasqueradingUser ?? "")
            : nil

        let entry = KeychainEntry(accessToken: token, baseURL: client.authSession.baseURL, expiresAt: nil, locale: "en", masquerader: masquerader, refreshToken: nil, userAvatarURL: client.authSession.user.avatarURL, userID: client.authSession.user.id, userName: client.authSession.user.name)
        self.didLogin(entry)
    }
    
    func didLogout(_ controller: UIViewController) {
        guard let window = self.window else { return }
        Keychain.clearEntries()
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
