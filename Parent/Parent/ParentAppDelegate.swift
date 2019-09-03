//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import AVKit
import UIKit
import CanvasCore
import CanvasKit
import Fabric
import Crashlytics
import Firebase
import UserNotifications
import Core

let ParentAppRefresherTTL: TimeInterval = 5.minutes

@UIApplicationMain
class ParentAppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Parent.router
        Router.sharedInstance.addRoutes()
        return env
    }()

    var legacySession: Session?

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCrashlytics()
        CacheManager.resetAppIfNecessary()
        if hasFirebase {
            FirebaseApp.configure()
        }
        setupDefaultErrorHandling()
        Core.Analytics.shared.handler = self
        UNUserNotificationCenter.current().delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true)
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return openCanvasURL(url)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
        AppStoreReview.handleLaunch()
    }
    
    @objc func openCanvasURL(_ url: URL) -> Bool {
        if url.scheme == "canvas-parent" {
            if environment.currentSession != nil {
                Router.sharedInstance.route(topMostViewController()!, toURL: url, modal: false)
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
            Router.sharedInstance.route(topMostViewController()!, toURL: url, modal: true)
        }
    }

    func setup(session: LoginSession) {
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        // UX requires that students are given color schemes in a specific order.
        // The method call below ensures that we always start with the first color scheme.
        ColorCoordinator.clearColorSchemeDictionary()
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }
        // Legacy CanvasKit support
        let legacyClient = CKIClient(baseURL: session.baseURL, token: session.accessToken)!
        legacyClient.actAsUserID = session.actAsUserID
        legacyClient.originalIDOfMasqueradingUser = session.originalUserID
        legacyClient.originalBaseURL = session.originalBaseURL
        legacyClient.fetchCurrentUser().subscribeNext({ user in
            legacyClient.setValue(user, forKey: "currentUser")
            CKIClient.current = legacyClient
            self.legacySession = legacyClient.authSession
            Router.sharedInstance.session = legacyClient.authSession
            NotificationCenter.default.post(name: .loggedIn, object: self, userInfo: [LoggedInNotificationContentsSession: legacyClient.authSession])
            self.showRootView()
        }, error: { _ in DispatchQueue.main.async {
            self.userDidLogout(session: session)
        } })
    }

    func showRootView() {
        guard let legacySession = legacySession else { return }
        do {
            let refresher = try Student.observedStudentsRefresher(legacySession)
            refresher.refreshingCompleted.observeValues { [weak self] _ in
                guard let self = self, let window = self.window else { return }

                let dashboardHandler = Router.sharedInstance.parentDashboardHandler()
                guard let controller = dashboardHandler(nil) else { return }

                controller.view.layoutIfNeeded()
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    window.rootViewController = controller
                }, completion: nil)
            }
            refresher.refresh(true)
        } catch let e as NSError {
            print(e)
        }
    }
}

extension ParentAppDelegate: LoginDelegate {
    var supportsCanvasNetwork: Bool { return false }
    var whatsNewURL: URL? {
        return URL(string: "https://s3.amazonaws.com/tr-learncanvas/docs/WhatsNewCanvasParent.pdf")
    }

    func openSupportTicket() {
        guard let presentFrom = topMostViewController() else { return }
        let subject = String.localizedStringWithFormat("[Parent Login Issue] %@", NSLocalizedString("Trouble logging in", comment: ""))
        presentFrom.present(UINavigationController(rootViewController: ErrorReportViewController.create(subject: subject)), animated: true)
    }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self)
        }, completion: nil)
    }

    func openExternalURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func userDidLogin(session: LoginSession) {
        LoginSession.add(session)
        // TODO: Register for push notifications?
        LocalizationManager.localizeForApp(UIApplication.shared, locale: session.locale) {
            setup(session: session)
        }
    }

    func userDidStopActing(as session: LoginSession) {
        LoginSession.remove(session)
        // TODO: Deregister push notifications?
        guard environment.currentSession == session else { return }
        environment.userDidLogout(session: session)
        CoreWebView.stopCookieKeepAlive()
    }

    func userDidLogout(session: LoginSession) {
        let wasCurrent = environment.currentSession == session
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func logout() {
        if let session = environment.currentSession {
            userDidLogout(session: session)
        }
    }
}

extension ParentAppDelegate {
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreWebView.stopCookieKeepAlive()
        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }

    func topMostViewController() -> UIViewController? {
        return window?.rootViewController?.topMostViewController()
    }
}

// MARK: SoErroneous
extension ParentAppDelegate {
    
    @objc func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
        guard let presentFrom = presentingViewController else { return }
        
        DispatchQueue.main.async {
            let alertDetails = error.alertDetails(reportAction: {
                presentFrom.present(UINavigationController(rootViewController: ErrorReportViewController.create(error: error)), animated: true)
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
    }
}

extension ParentAppDelegate: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String : Any]?) {
        if hasFirebase {
            Analytics.logEvent(name, parameters: parameters)
        }
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
