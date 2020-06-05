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
import PSPDFKit
import CanvasCore
import UserNotifications
import Firebase
import Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)
    @objc var session: Session?

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = self
        env.router = router
        env.app = .student
        env.window = window
        return env
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFirebase()
        CacheManager.resetAppIfNecessary()
        CacheManager.removeBloat()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif

        DocViewerViewController.setup(.studentPSPDFKitLicense)
        prepareReactNative()
        setupDefaultErrorHandling()
        setupPageViewLogging()
        TabBarBadgeCounts.application = UIApplication.shared
        Core.Analytics.shared.handler = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        if launchOptions?[.sourceApplication] as? String == Bundle.teacherBundleID,
            let url = launchOptions?[.url] as? URL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.path == "student_view",
            let fakeStudent = LoginSession.mostRecent(in: .shared, forKey: .fakeStudents) {
            LoginSession.add(fakeStudent)
        }

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            window?.makeKeyAndVisible()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true, app: .student)
            window?.makeKeyAndVisible()
        }

        handleLaunchOptionsNotifications(launchOptions)

        return true
    }

    func setup(session: LoginSession) {
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Firebase.Crashlytics.crashlytics().setUserID(crashlyticsUserId)
        }

        Analytics.setUserID(session.userID)
        Analytics.setUserProperty(session.baseURL.absoluteString, forName: "base_url")

        let getProfile = GetUserProfileRequest(userID: "self")
        environment.api.makeRequest(getProfile) { _, urlResponse, _ in
            if urlResponse?.isUnauthorized == true, !session.isFakeStudent {
                DispatchQueue.main.async { self.userDidLogout(session: session) }
            }
            if let legacySession = Session.current {
                self.session = legacySession
                LegacyModuleProgressShim.observeProgress(legacySession)
                ModuleItem.beginObservingProgress(legacySession)
            }
            PageViewEventController.instance.userDidChange()
            DispatchQueue.main.async { self.refreshNotificationTab() }
            GetBrandVariables().fetch(environment: self.environment) { _, _, _ in
                DispatchQueue.main.async {
                    Brand.setCurrent(Brand(core: Core.Brand.shared), applyInWindow: self.window)
                    NativeLoginManager.login(as: session)
                }
            }
        }
        Analytics.shared.logSession(session)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if
            options[.sourceApplication] as? String == Bundle.teacherBundleID,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.path == "student_view",
            let fakeStudent = LoginSession.mostRecent(in: .shared, forKey: .fakeStudents) {
            userDidLogin(session: fakeStudent)
            return true
        }
        return openCanvasURL(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.handleLaunch()
        CoreWebView.keepCookieAlive(for: environment)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.shared.log()
        CoreWebView.stopCookieKeepAlive()
        BackgroundVideoPlayer.shared.background()
        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        BackgroundVideoPlayer.shared.reconnect()
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Logger.shared.log()
        let manager = UploadManager(identifier: identifier)
        manager.completionHandler = {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
        manager.createSession()
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

// MARK: Push notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationKitController.didRegisterForRemoteNotifications(deviceToken, errorHandler: handlePushNotificationRegistrationError)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handlePushNotificationRegistrationError((error as NSError).addingInfo())
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handlePush(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }

    @objc func handlePushNotificationRegistrationError(_ error: NSError) {
        Firebase.Crashlytics.crashlytics().log("source: push_notification_registration")
        Firebase.Crashlytics.crashlytics().record(error: error)
    }

    func handleLaunchOptionsNotifications(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject],
            notification["aps"] as? [String: AnyObject] != nil {
            handlePush(userInfo: notification)
        }
    }

    func handlePush(userInfo: [AnyHashable: Any]) {
        StartupManager.shared.enqueueTask { [weak self] in
            PushNotifications.recordUserInfo(userInfo)
            // Handle local notifications we know about first
            if let routerURL = userInfo[NotificationManager.RouteURLKey] as? String,
                let url = URL(string: routerURL) {
                self?.openCanvasURL(url)
                return
            }

            // Must be a push notification
            self?.routeToPushNotificationPayloadURL(userInfo)
        }
    }
}

extension AppDelegate: Core.AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}

// MARK: SoErroneous
extension AppDelegate {

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
                Firebase.Crashlytics.crashlytics().record(error: error)
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

    @objc func setupFirebase() {
        guard !testing else {
            setupDebugCrashLogging()
            return
        }

        if FirebaseOptions.defaultOptions()?.apiKey != nil { FirebaseApp.configure() }
        CanvasCrashlytics.setupForReactNative()
        configureRemoteConfig()
    }

    func setupDebugCrashLogging() {
        NSSetUncaughtExceptionHandler { exception in
            print("CRASH: \(exception)")
            print("Stack Trace:")
            for symbol in exception.callStackSymbols {
                print("  \(symbol)")
            }
        }
    }
}

// MARK: PageView Logging
extension AppDelegate {
    func setupPageViewLogging() {
        class BackgroundAppHelper: AppBackgroundHelperProtocol {
            var tasks: [String: UIBackgroundTaskIdentifier] = [:]
            func startBackgroundTask(taskName: String) {
                tasks[taskName] = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
                    self?.tasks[taskName] = .invalid
                }
            }

            func endBackgroundTask(taskName: String) {
                if let task = tasks[taskName] {
                    UIApplication.shared.endBackgroundTask(task)
                }
            }
        }
        let helper = BackgroundAppHelper()
        PageViewEventController.instance.configure(backgroundAppHelper: helper)
    }
}

// MARK: Launching URLS
extension AppDelegate {
    @objc @discardableResult func openCanvasURL(_ url: URL) -> Bool {
        if LoginSession.mostRecent == nil, let host = url.host {
            let loginNav = LoginNavigationController.create(loginDelegate: self, app: .student)
            loginNav.login(host: host)
            window?.rootViewController = loginNav
        }
        // the student app doesn't have as predictable of a tab bar setup and for
        // several views, does not have a route configured for them so for now we
        // will hard code until we move more things over to helm
        let tabRoutes = [["/", "", "/courses", "/groups"], ["/calendar"], ["/to-do"], ["/notifications"], ["/conversations", "/inbox"]]
        StartupManager.shared.enqueueTask {
            let path = url.path
            var index: Int?

            for (i, element) in tabRoutes.enumerated() {
                if element.firstIndex(of: path) != nil {
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

                if tabBarController.presentedViewController != nil {
                    tabBarController.dismiss(animated: true, completion: {
                        DispatchQueue.main.async(execute: finish)
                    })
                } else {
                    finish()
                }
            } else if let from = self.topViewController {
                var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
                comps?.originIsNotification = true
                AppEnvironment.shared.router.route(to: comps?.url ?? url, from: from, options: .modal(embedInNav: true, addDoneButton: true))
            }
        }
        return true
    }
}

extension AppDelegate: LoginDelegate, NativeLoginManagerDelegate {
    var supportsQRCodeLogin: Bool {
        ExperimentalFeature.qrLoginStudent.isEnabled
    }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self, app: .student)
        }, completion: nil)
    }

    func stopActing() {
        if let session = environment.currentSession {
            stopActing(as: session)
        }
    }

    func logout() {
        if let session = environment.currentSession {
            userDidLogout(session: session)
        }
    }

    func openExternalURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func userDidLogin(session: LoginSession) {
        LoginSession.add(session)
        LocalizationManager.localizeForApp(UIApplication.shared, locale: session.locale) {
            setup(session: session)
        }
    }

    func userDidStopActing(as session: LoginSession) {
        LoginSession.remove(session)
        guard environment.currentSession == session else { return }
        PageViewEventController.instance.userDidChange()
        NotificationKitController.deregisterPushNotifications { _ in }
        UIApplication.shared.applicationIconBadgeNumber = 0
        environment.userDidLogout(session: session)
        CoreWebView.stopCookieKeepAlive()
        NativeLoginManager.shared().logout()
    }

    func userDidLogout(session: LoginSession) {
        let wasCurrent = environment.currentSession == session
        environment.api.makeRequest(DeleteLoginOAuthRequest(session: session)) { _, _, _ in }
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func actAsFakeStudent(withID fakeStudentID: String) {}
}

// MARK: - Handle siri notifications
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url, app: .student) {
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
        if let path = userActivity.userInfo?["url"] as? String, let url = URL(string: path) {
            openCanvasURL(url)
            return true
        }
        return false
    }
}

// MARK: - Tabs
extension AppDelegate {
    func refreshNotificationTab() {
        if let tabs = window?.rootViewController as? UITabBarController,
            tabs.viewControllers?.count ?? 0 > 3,
            let nav = tabs.viewControllers?[3] as? UINavigationController,
            let activities = nav.viewControllers.first as? ActivityStreamViewController {
            activities.refreshData(force: true)
        }
    }
}
