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
import Firebase
import UserNotifications
import Core
import SafariServices

let ParentAppRefresherTTL: TimeInterval = 5.minutes
var currentStudentID: String?

@UIApplicationMain
class ParentAppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = router
        env.loginDelegate = self
        env.app = .parent
        env.window = window
        return env
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFirebase()
        CacheManager.resetAppIfNecessary()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        setupDefaultErrorHandling()
        Analytics.shared.handler = self
        UNUserNotificationCenter.current().delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true, app: .parent)
        }
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
        AppStoreReview.handleLaunch()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "canvas-parent" {
            environment.router.route(to: url, from: topMostViewController()!, options: .modal(.fullScreen, embedInNav: true, addDoneButton: true))
        }
        return false
    }

    @objc func routeToRemindable(from response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let url = userInfo[RemindableActionURLKey] as? String, let studentID = userInfo[RemindableStudentIDKey] as? String {
            currentStudentID = studentID
            environment.router.route(to: url, from: topMostViewController()!, options: .modal(embedInNav: true, addDoneButton: true))
        }
    }

    func setup(session: LoginSession) {
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        currentStudentID = environment.userDefaults?.parentCurrentStudentID
        if currentStudentID == nil {
            // UX requires that students are given color schemes in a specific order.
            // The method call below ensures that we always start with the first color scheme.    
            ColorScheme.clear()
        }
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Firebase.Crashlytics.crashlytics().setUserID(crashlyticsUserId)
        }
        Analytics.shared.logSession(session)
        getPreferences()
        GetBrandVariables().fetch(environment: self.environment) { [weak self] _, _, _ in performUIUpdate {
            self?.showRootView()
        } }
    }

    func showRootView() {
        guard let window = self.window else { return }
        let controller = DashboardNavigationController(rootViewController: DashboardViewController.create())
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            window.rootViewController = controller
        }, completion: { _ in
            StartupManager.shared.markStartupFinished()
        })
    }

    func getPreferences() {
        let request = GetUserRequest(userID: "self")
        environment.api.makeRequest(request) { [weak self] response, _, _ in
            self?.environment.userDefaults?.limitWebAccess = response?.permissions?.limit_parent_app_web_access
        }
    }

    // similar methods exist in all other app delegates
    // please be sure to update there as well
    // We can't move this to Core as it would require setting up
    // Cocoapods for Core to pull in Firebase
    func configureRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetch(withExpirationDuration: 0) { _, _ in
            remoteConfig.activate { _ in
                let keys = remoteConfig.allKeys(from: .remote)
                for key in keys {
                    guard let feature = ExperimentalFeature(rawValue: key) else { continue }
                    let value = remoteConfig.configValue(forKey: key).boolValue
                    feature.isEnabled = value
                    Firebase.Crashlytics.crashlytics().setCustomValue(value, forKey: feature.userDefaultsKey)
                    Analytics.setUserProperty(value ? "YES" : "NO", forName: feature.rawValue)
                }
            }
        }
    }
}

extension ParentAppDelegate: LoginDelegate {
    var supportedDeepLinkActions: [String] {
        return ["create-account"]
    }

    var supportsQRCodeLogin: Bool {
        ExperimentalFeature.qrLoginParent.isEnabled
    }
    var supportsCanvasNetwork: Bool { false }
    var findSchoolButtonTitle: String { NSLocalizedString("Find School", bundle: .core, comment: "") }

    func openSupportTicket() {
        guard let presentFrom = topMostViewController() else { return }
        let subject = String.localizedStringWithFormat("[Parent Login Issue] %@", NSLocalizedString("Trouble logging in", comment: ""))
        presentFrom.present(UINavigationController(rootViewController: ErrorReportViewController.create(subject: subject)), animated: true)
    }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self, app: .parent)
        }, completion: nil)
    }

    func openExternalURL(_ url: URL) {
        if url.scheme == "https", let topVC = topMostViewController() {
            if environment.userDefaults?.limitWebAccess == true {
                launchLimitedWebView(url: url, from: topVC)
            } else {
                let safari = SFSafariViewController(url: url)
                safari.modalPresentationStyle = .fullScreen
                topVC.present(safari, animated: true, completion: nil)
            }
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func launchLimitedWebView(url: URL, from sourceViewController: UIViewController) {
        let controller = CoreWebViewController()
        controller.isInteractionLimited = true
        controller.webView.load(URLRequest(url: url))
        environment.router.show(controller, from: sourceViewController, options: .modal(.fullScreen, embedInNav: true, addDoneButton: true))
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
        environment.api.makeRequest(DeleteLoginOAuthRequest(session: session)) { _, _, _ in }
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func logout() {
        if let session = environment.currentSession {
            userDidLogout(session: session)
        }
    }

    func handleDeepLink(url: URL) {
        if url.host == "create-account" {
            let title = NSLocalizedString("Login required", comment: "")
            let message = NSLocalizedString("It looks like you’re trying to add a student. Try adding this student after you’ve logged in", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", bundle: .core, comment: ""), style: .default))
            guard let vc = topMostViewController() else { return }
            AppEnvironment.shared.router.show(alert, from: vc, options: .modal())
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
        ErrorReporter.setErrorHandler({ error, presentingViewController in
            self.alertUser(of: error, from: presentingViewController)

            if error.shouldRecordInCrashlytics {
                Firebase.Crashlytics.crashlytics().record(error: error)
            }
        })
    }

    @objc func handleError(_ error: NSError) {
        ErrorReporter.reportError(error, from: window?.rootViewController)
    }
}

// MARK: Crashlytics
extension ParentAppDelegate {
    @objc func setupFirebase() {
        guard !testing else { return }
        if FirebaseOptions.defaultOptions()?.apiKey != nil { FirebaseApp.configure() }
        CanvasCrashlytics.setupForReactNative()
        configureRemoteConfig()
    }
}

extension ParentAppDelegate: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}

// MARK: UNUserNotificationCenterDelegate
extension ParentAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        StartupManager.shared.enqueueTask { [weak self] in
            self?.routeToRemindable(from: response)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}

extension ParentAppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url, app: .parent) {
            window?.rootViewController = LoadingViewController.create()
            login.fetch(environment: environment) { [weak self] (session, error) -> Void in
                guard let session = session, error == nil else {
                    self?.changeUser()
                    return
                }
                self?.userDidLogin(session: session)
            }
            return true
        }
        return false
    }
}
