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
import Core
import Firebase
import Heap
import SafariServices
import UIKit
import UserNotifications

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

    private var environmentFeatureFlags: Store<GetEnvironmentFeatureFlags>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFirebase()
        CacheManager.resetAppIfNecessary()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        setupDefaultErrorHandling()
        Analytics.shared.handler = self
        NotificationManager.shared.notificationCenter.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        UITableView.setupDefaultSectionHeaderTopPadding()
        FontAppearance.update()

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true, app: .parent)
            Analytics.shared.logScreenView(route: "/login", viewController: window?.rootViewController)
        }
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
        AppStoreReview.handleLaunch()
        updateInterfaceStyle(for: window)
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
        environmentFeatureFlags = environment.subscribe(GetEnvironmentFeatureFlags(context: Context.currentUser))
        environmentFeatureFlags?.refresh(force: true) { _ in
            guard let envFlags = self.environmentFeatureFlags, envFlags.error == nil else { return }
            self.initializeTracking()
        }

        updateInterfaceStyle(for: window)
        CoreWebView.keepCookieAlive(for: environment)
        currentStudentID = environment.userDefaults?.parentCurrentStudentID
        if currentStudentID == nil {
            // UX requires that students are given color schemes in a specific order.
            // The method call below ensures that we always start with the first color scheme.
            ColorScheme.clear()
        }
        Analytics.shared.logSession(session)
        getPreferences { userProfile in performUIUpdate {
            LocalizationManager.localizeForApp(UIApplication.shared, locale: userProfile.locale) {
                GetBrandVariables().fetch(environment: self.environment) { [weak self] _, _, _ in performUIUpdate {
                    self?.showRootView()
                }}
            }
        }}
    }

    func showRootView() {
        guard let window = self.window else { return }
        let controller = HelmNavigationController(rootViewController: DashboardViewController.create())
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            window.rootViewController = controller
        }, completion: { _ in
            self.environment.startupDidComplete()
        })
    }

    func getPreferences(_ completion: @escaping (APIUser) -> Void) {
        let request = GetUserRequest(userID: "self")
        environment.api.makeRequest(request) { [weak self] response, _, _ in
            guard let response = response else { return }
            self?.environment.userDefaults?.limitWebAccess = response.permissions?.limit_parent_app_web_access
            completion(response)
        }
    }

    // similar methods exist in all other app delegates
    // please be sure to update there as well
    // We can't move this to Core as it would require setting up
    // Cocoapods for Core to pull in Firebase
    func configureRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetch(withExpirationDuration: 0) { _, _ in
            remoteConfig.activate { _, _ in
                let keys = remoteConfig.allKeys(from: .remote)
                for key in keys {
                    guard let feature = ExperimentalFeature(rawValue: key) else { continue }
                    let value = remoteConfig.configValue(forKey: key).boolValue
                    feature.isEnabled = value
                    Firebase.Crashlytics.crashlytics().setCustomValue(value, forKey: feature.userDefaultsKey)
//                    Analytics.setUserProperty(value ? "YES" : "NO", forName: feature.rawValue)
                }
            }
        }
    }
}

extension ParentAppDelegate: LoginDelegate {
    var supportsCanvasNetwork: Bool { false }
    var findSchoolButtonTitle: String { NSLocalizedString("Find School", bundle: .core, comment: "") }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        disableTracking()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self, app: .parent)
            Analytics.shared.logScreenView(route: "/login", viewController: window.rootViewController)
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

    func openExternalURLinSafari(_ url: URL) {
        UIApplication.shared.open(url)
    }

    func launchLimitedWebView(url: URL, from sourceViewController: UIViewController) {
        let controller = CoreWebViewController(invertColorsInDarkMode: true)
        controller.isInteractionLimited = true
        controller.webView.load(URLRequest(url: url))
        environment.router.show(controller, from: sourceViewController, options: .modal(.fullScreen, embedInNav: true, addDoneButton: true))
    }

    func userDidLogin(session: LoginSession) {
        LoginSession.add(session)
        // TODO: Register for push notifications?
        setup(session: session)
    }

    func userDidStopActing(as session: LoginSession) {
        disableTracking()
        LoginSession.remove(session)
        // TODO: Deregister push notifications?
        guard environment.currentSession == session else { return }
        environment.userDidLogout(session: session)
        CoreWebView.stopCookieKeepAlive()
    }

    func userDidLogout(session: LoginSession) {
        disableTracking()
        let wasCurrent = environment.currentSession == session
        API(session).makeRequest(DeleteLoginOAuthRequest(), refreshToken: false) { _, _, _ in }
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

// MARK: Error Handling
extension ParentAppDelegate {
    func setupDefaultErrorHandling() {
        environment.errorHandler = { error, controller in performUIUpdate {
            let error = error as NSError
            error.showAlert(from: controller)
            if error.shouldRecordInCrashlytics {
                Firebase.Crashlytics.crashlytics().record(error: error)
            }
        } }
    }
}

// MARK: Crashlytics
extension ParentAppDelegate {
    @objc func setupFirebase() {
        guard !testing else { return }
        if FirebaseOptions.defaultOptions()?.apiKey != nil { FirebaseApp.configure() }
        configureRemoteConfig()
    }
}

extension ParentAppDelegate: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        guard FirebaseOptions.defaultOptions()?.apiKey != nil else {
            return
        }

        if let screenName = parameters?["screen_name"] as? String,
           let screenClass = parameters?["screen_class"] as? String {
            Firebase.Crashlytics.crashlytics().log("\(screenName) (\(screenClass))")
        }
    }

    private func initializeTracking() {
        guard
            let environmentFeatureFlags,
            !ProcessInfo.isUITest,
            let heapID = Secret.heapID.string
        else {
            return
        }

        let isSendUsageMetricsEnabled = environmentFeatureFlags.isFeatureEnabled(.send_usage_metrics)
        let options = HeapOptions()
        options.disableTracking = !isSendUsageMetricsEnabled
        Heap.initialize(heapID, with: options)
        Heap.setTrackingEnabled(isSendUsageMetricsEnabled)
        environment.heapID = Heap.userId()
    }

    private func disableTracking() {
        Heap.setTrackingEnabled(false)
    }
}

// MARK: UNUserNotificationCenterDelegate
extension ParentAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        environment.performAfterStartup { [weak self] in
            self?.routeToRemindable(from: response)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
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
