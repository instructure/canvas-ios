//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import UserNotifications
import PSPDFKit
import Firebase
import CanvasCore
import Core
import React

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Teacher.router
        env.loginDelegate = self
        env.app = .teacher
        env.window = window
        return env
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if NSClassFromString("XCTestCase") != nil { return true }
        setupFirebase()
        CacheManager.resetAppIfNecessary()
        CacheManager.removeBloat()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        Core.Analytics.shared.handler = self
        DocViewerViewController.setup(.teacherPSPDFKitLicense)
        prepareReactNative()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        TabBarBadgeCounts.application = UIApplication.shared

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            window?.makeKeyAndVisible()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true, app: .teacher)
            window?.makeKeyAndVisible()
        }

        handleLaunchOptionsNotifications(launchOptions)

        return true
    }

    func setup(session: LoginSession, wasReload: Bool = false) {
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        if Locale.current.regionCode != "CA" {
            let crashlyticsUserId = "\(session.userID)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Firebase.Crashlytics.crashlytics().setUserID(crashlyticsUserId)
        }

        let getProfile = GetUserProfileRequest(userID: "self")
        environment.api.makeRequest(getProfile) { response, urlResponse, error in
            guard response != nil, error == nil else {
                if urlResponse?.isUnauthorized == true {
                    DispatchQueue.main.async { self.userDidLogout(session: session) }
                }
                return
            }
            GetBrandVariables().fetch(environment: self.environment) { _, _, _ in
                Brand.setCurrent(Brand(core: Core.Brand.shared), applyInWindow: self.window)
                NativeLoginManager.login(as: session)
            }
        }
        Analytics.shared.logSession(session)
    }

    @objc func prepareReactNative() {
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        registerNativeRoutes()
        NativeLoginManager.shared().delegate = self
        HelmManager.shared.onReactLoginComplete = {
            NotificationKitController.setupForPushNotifications(delegate: self)
            guard let window = self.window else { return }
            let controller = RootTabBarController()
            controller.view.layoutIfNeeded()
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = controller
            }, completion: nil)
        }
        HelmManager.shared.onReactReload = {
            guard self.window?.rootViewController is RootTabBarController else { return }
            guard let session = LoginSession.mostRecent else {
                self.changeUser()
                return
            }
            self.setup(session: session)
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationKitController.didRegisterForRemoteNotifications(deviceToken) { [weak self] error in
            ErrorReporter.reportError(error.addingInfo(), from: self?.window?.rootViewController)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushNotifications.record(response.notification)
        handlePush(userInfo: response.notification.request.content.userInfo, completionHandler: completionHandler)
    }

    private func handlePush(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        StartupManager.shared.enqueueTask {
            RCTPushNotificationManager.didReceiveRemoteNotification(userInfo) { _ in
                completionHandler()
            }
        }
    }

    func handleLaunchOptionsNotifications(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject],
            notification["aps"] as? [String: AnyObject] != nil {
            handlePush(userInfo: notification, completionHandler: {})
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
        if (!uiTesting) {
            AppStoreReview.handleLaunch()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreWebView.stopCookieKeepAlive()
        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        StartupManager.shared.enqueueTask {
            guard let rootView = app.keyWindow?.rootViewController as? RootTabBarController, let tabViewControllers = rootView.viewControllers else { return }
            for (index, vc) in tabViewControllers.enumerated() {
                let navigationController: UINavigationController?
                if let split = vc as? UISplitViewController {
                    navigationController = split.viewControllers.first as? UINavigationController
                } else {
                    navigationController = vc as? UINavigationController
                }

                guard let navController = navigationController, let helmVC = navController.viewControllers.first as? HelmViewController else { break }
                let path = url.path.isEmpty ? "/" : url.path
                if helmVC.moduleName == path {
                    rootView.selectedIndex = index
                    rootView.resetSelectedViewController()
                    return
                }
            }

            RCTLinkingManager.application(app, open: url, options: options)
        }
        return true
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

extension AppDelegate: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}

extension AppDelegate: RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
}

extension AppDelegate: LoginDelegate, NativeLoginManagerDelegate {
    var supportsQRCodeLogin: Bool {
        ExperimentalFeature.qrLoginTeacher.isEnabled
    }

    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self, app: .teacher)
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
        NotificationKitController.deregisterPushNotifications { _ in }
        UIApplication.shared.applicationIconBadgeNumber = 0
        environment.userDidLogout(session: session)
        CoreWebView.stopCookieKeepAlive()
    }

    func userDidLogout(session: LoginSession) {
        let wasCurrent = environment.currentSession == session
        environment.api.makeRequest(DeleteLoginOAuthRequest(session: session)) { _, _, _ in }
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func actAsFakeStudent(withID fakeStudentID: String) {
        guard let session = environment.currentSession else { return }
        let entry = LoginSession(
            accessToken: session.accessToken,
            baseURL: session.baseURL,
            expiresAt: session.expiresAt,
            lastUsedAt: Date(),
            locale: session.locale,
            masquerader: (session.originalBaseURL ?? session.baseURL)
                .appendingPathComponent("fake-students")
                .appendingPathComponent(session.originalUserID ?? session.userID),
            refreshToken: session.refreshToken,
            userAvatarURL: nil,
            userID: fakeStudentID,
            userName: NSLocalizedString("Test Student", comment: ""),
            userEmail: session.userEmail,
            clientID: session.clientID,
            clientSecret: session.clientSecret
        )
        LoginSession.add(entry, to: .shared, forKey: .fakeStudents)
        if let url = URL(string: "canvas-student:student_view") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: Crashlytics
extension AppDelegate {
    @objc func setupFirebase() {
        guard !testing else { return }

        if FirebaseOptions.defaultOptions()?.apiKey != nil { FirebaseApp.configure() }
        CanvasCrashlytics.setupForReactNative()
        configureRemoteConfig()
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url, app: .teacher) {
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
