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
class StudentAppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = self
        env.router = router
        env.app = .student
        env.window = window
        return env
    }()

    private var shouldSetK5StudentView = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFirebase()
        Core.Analytics.shared.handler = self
        CacheManager.resetAppIfNecessary()

        #if DEBUG
            UITestHelpers.setup(self)
        #endif

        DocViewerViewController.setup(.studentPSPDFKitLicense)
        prepareReactNative()
        setupDefaultErrorHandling()
        setupPageViewLogging()
        TabBarBadgeCounts.application = UIApplication.shared
        NotificationManager.shared.notificationCenter.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        UITableView.setupDefaultSectionHeaderTopPadding()

        if launchOptions?[.sourceApplication] as? String == Bundle.teacherBundleID,
           let url = launchOptions?[.url] as? URL,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.path.contains("student_view"),
           let fakeStudent = LoginSession.mostRecent(in: .shared, forKey: .fakeStudents) {
            shouldSetK5StudentView = components.path.contains("k5")
            LoginSession.add(fakeStudent)
        }

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            window?.makeKeyAndVisible()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true, app: .student)
            window?.makeKeyAndVisible()
            Analytics.shared.logScreenView(route: "/login", viewController: window?.rootViewController)
        }

        return true
    }

    func setup(session: LoginSession) {
        environment.userDidLogin(session: session)
        environment.userDefaults?.isK5StudentView = shouldSetK5StudentView
        CoreWebView.keepCookieAlive(for: environment)
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Firebase.Crashlytics.crashlytics().setUserID(crashlyticsUserId)
        }

        Analytics.setUserID(session.userID)
        Analytics.setUserProperty(session.baseURL.absoluteString, forName: "base_url")
        NotificationManager.shared.subscribeToPushChannel()

        GetUserProfile().fetch(environment: environment, force: true) { apiProfile, urlResponse, _ in
            let isK5StudentView = self.environment.userDefaults?.isK5StudentView ?? false
            if isK5StudentView {
                ExperimentalFeature.K5Dashboard.isEnabled = true
                self.environment.userDefaults?.isElementaryViewEnabled = true
            }
            self.environment.k5.userDidLogin(profile: apiProfile, isK5StudentView: isK5StudentView)

            if urlResponse?.isUnauthorized == true, !session.isFakeStudent {
                DispatchQueue.main.async { self.userDidLogout(session: session) }
            }

            PageViewEventController.instance.userDidChange()
            DispatchQueue.main.async {
                self.refreshNotificationTab()
                LocalizationManager.localizeForApp(UIApplication.shared, locale: apiProfile?.locale ?? session.locale) {
                    GetBrandVariables().fetch(environment: self.environment) { _, _, _ in performUIUpdate {
                        NativeLoginManager.login(as: session)
                    }}
                }
            }
        }
        Analytics.shared.logSession(session)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if options[.sourceApplication] as? String == Bundle.teacherBundleID,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.path.contains("student_view"),
           let fakeStudent = LoginSession.mostRecent(in: .shared, forKey: .fakeStudents) {
            shouldSetK5StudentView = components.path.contains("k5")
            if environment.currentSession != nil {
                NativeLoginManager.shared().logout() // Cleanup old to prevent token errors
            }
            userDidLogin(session: fakeStudent)
            return true
        }
        return openURL(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.handleLaunch()
        CoreWebView.keepCookieAlive(for: environment)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.shared.log()
        CoreWebView.stopCookieKeepAlive()
        BackgroundVideoPlayer.shared.background()
        environment.refreshWidgets()
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
            remoteConfig.activate { _, _ in
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
extension StudentAppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.subscribeToPushChannel(token: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        environment.reportError(error)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        PushNotifications.record(response.notification)
        if let url = NotificationManager.routeURL(from: response.notification.request.content.userInfo) {
            openURL(url, userInfo: [
                "forceRefresh": true,
                "pushNotification": response.notification.request.content.userInfo["aps"] ?? [:],
            ])
        }
        completionHandler()
    }
}

extension StudentAppDelegate: Core.AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}

// MARK: Error Handling
extension StudentAppDelegate {
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
extension StudentAppDelegate {

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
extension StudentAppDelegate {
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
extension StudentAppDelegate {
    @objc @discardableResult func openURL(_ url: URL, userInfo: [String: Any]? = nil) -> Bool {
        if LoginSession.mostRecent == nil, let host = url.host {
            let loginNav = LoginNavigationController.create(loginDelegate: self, app: .student)
            loginNav.login(host: host)
            window?.rootViewController = loginNav
            Analytics.shared.logScreenView(route: "/login", viewController: window?.rootViewController)
        }
        // the student app doesn't have as predictable of a tab bar setup and for
        // several views, does not have a route configured for them so for now we
        // will hard code until we move more things over to helm
        let tabRoutes = [["/", "", "/courses", "/groups"], ["/calendar"], ["/to-do"], ["/notifications"], ["/conversations", "/inbox"]]
        environment.performAfterStartup {
            let path = url.path
            if let i = tabRoutes.firstIndex(where: { $0.contains(path) }) {
                guard let tabBarController = self.window?.rootViewController as? UITabBarController else { return }

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
            } else if let from = self.environment.topViewController {
                var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
                comps?.originIsNotification = true
                AppEnvironment.shared.router.route(to: comps?.url ?? url, userInfo: userInfo, from: from, options: .modal(embedInNav: true, addDoneButton: true))
            }
        }
        return true
    }
}

extension StudentAppDelegate: LoginDelegate, NativeLoginManagerDelegate {
    func changeUser() {
        shouldSetK5StudentView = false
        environment.k5.userDidLogout()
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self, app: .student)
            Analytics.shared.logScreenView(route: "/login", viewController: window.rootViewController)
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
        setup(session: session)
    }

    func userDidStopActing(as session: LoginSession) {
        LoginSession.remove(session)
        guard environment.currentSession == session else { return }
        PageViewEventController.instance.userDidChange()
        NotificationManager.shared.unsubscribeFromPushChannel()
        UIApplication.shared.applicationIconBadgeNumber = 0
        environment.userDidLogout(session: session)
        CoreWebView.stopCookieKeepAlive()
        NativeLoginManager.shared().logout()
    }

    func userDidLogout(session: LoginSession) {
        shouldSetK5StudentView = false
        let wasCurrent = environment.currentSession == session
        API(session).makeRequest(DeleteLoginOAuthRequest(), refreshToken: false) { _, _, _ in }
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func actAsFakeStudent(withID fakeStudentID: String) {}
}

// MARK: - Handle siri notifications
extension StudentAppDelegate {
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
            return openURL(url)
        }
        return false
    }
}

// MARK: - Tabs
extension StudentAppDelegate {
    func refreshNotificationTab() {
        if let tabs = window?.rootViewController as? UITabBarController,
            tabs.viewControllers?.count ?? 0 > 3,
            let nav = tabs.viewControllers?[3] as? UINavigationController,
            let activities = nav.viewControllers.first as? ActivityStreamViewController {
            activities.refreshData(force: true)
        }
    }
}
