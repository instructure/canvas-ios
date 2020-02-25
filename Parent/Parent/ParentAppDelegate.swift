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
import Fabric
import Crashlytics
import Firebase
import UserNotifications
import Core
import SafariServices

let ParentAppRefresherTTL: TimeInterval = 5.minutes
var legacySession: Session?
var currentStudentID: String?

@UIApplicationMain
class ParentAppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)
    var studentsRefresher: Refresher?

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = router
        env.loginDelegate = self
        return env
    }()

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCrashlytics()
        CacheManager.resetAppIfNecessary()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        if hasFirebase {
            FirebaseApp.configure()
            configureRemoteConfig()
        }
        setupDefaultErrorHandling()
        Analytics.shared.handler = self
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

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
        AppStoreReview.handleLaunch()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "canvas-parent" {
            environment.router.route(to: url, from: topMostViewController()!, options: .modal(embedInNav: true, addDoneButton: true))
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
        // UX requires that students are given color schemes in a specific order.
        // The method call below ensures that we always start with the first color scheme.
        ColorScheme.clear()
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }
        legacySession = Session.current
        Analytics.shared.logSession(session)
        getPreferences()
        showRootView()
    }

    func showRootView() {
        guard let session = legacySession else { return }
        do {
            let refresher = try Student.observedStudentsRefresher(session)
            refresher.refreshingCompleted.observeValues { [weak self] _ in
                guard let self = self, let window = self.window else { return }
                self.studentsRefresher = nil

                let controller = UINavigationController(rootViewController: DashboardViewController.create(session: session))
                controller.view.layoutIfNeeded()
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    window.rootViewController = controller
                }, completion: nil)
            }
            refresher.refresh(true)
            studentsRefresher = refresher
        } catch let e as NSError {
            print(e)
        }
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
        remoteConfig.activate { error in
            guard error == nil else {
                return
            }
            let keys = remoteConfig.allKeys(from: RemoteConfigSource.remote)
            for key in keys {
                guard let feature = ExperimentalFeature(rawValue: key) else { continue }
                let value = remoteConfig.configValue(forKey: key).boolValue
                feature.isEnabled = value
                Crashlytics.sharedInstance().setBoolValue(value, forKey: feature.userDefaultsKey)
                Analytics.setUserProperty(value ? "YES" : "NO", forName: feature.rawValue)
            }
        }
        remoteConfig.fetch(completionHandler: nil)
    }
}

extension ParentAppDelegate: LoginDelegate {
    var supportsCanvasNetwork: Bool { false }
    var findSchoolButtonTitle: String { NSLocalizedString("Find School", bundle: .core, comment: "") }

    func openSupportTicket() {
        guard let presentFrom = topMostViewController() else { return }
        let subject = String.localizedStringWithFormat("[Parent Login Issue] %@", NSLocalizedString("Trouble logging in", comment: ""))
        presentFrom.present(UINavigationController(rootViewController: ErrorReportViewController.create(subject: subject)), animated: true)
    }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        legacySession = nil
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self)
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
            NSLog("WARNING: Crashlytics was not properly initialized.")
            return
        }
        Fabric.with([Crashlytics.self])
    }
}

extension ParentAppDelegate: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
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

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
