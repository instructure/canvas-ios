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
import CanvasKit
import ReactiveSwift
import UserNotifications
import PSPDFKit
import Fabric
import Crashlytics
import Firebase
import CanvasCore
import Core
import React

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Teacher.router
        env.loginDelegate = self
        return env
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if NSClassFromString("XCTestCase") != nil { return true }
        setupCrashlytics()
        CacheManager.resetAppIfNecessary()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        if hasFirebase {
            FirebaseApp.configure()
        }
        Core.Analytics.shared.handler = self
        DocViewerViewController.setup(.teacherPSPDFKitLicense)
        prepareReactNative()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        UIApplication.shared.reactive.applicationIconBadgeNumber <~ TabBarBadgeCounts.applicationIconBadgeNumber

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            window?.makeKeyAndVisible()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true)
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
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }
        // Legacy CanvasKit support
        let legacyClient = CKIClient(
            baseURL: session.baseURL,
            token: session.accessToken ?? "",
            refreshToken: session.refreshToken,
            clientID: session.clientID,
            clientSecret: session.clientSecret
        )!
        legacyClient.actAsUserID = session.actAsUserID
        legacyClient.originalIDOfMasqueradingUser = session.originalUserID
        legacyClient.originalBaseURL = session.originalBaseURL
        let getProfile = GetUserProfileRequest(userID: "self")
        environment.api.makeRequest(getProfile) { response, urlResponse, error in
            guard let profile = response, error == nil else {
                if urlResponse?.isUnauthorized == true {
                    DispatchQueue.main.async { self.userDidLogout(session: session) }
                }
                return
            }
            let legacyUser = CKIUser()
            legacyUser?.id = session.userID
            legacyUser?.name = session.userName
            legacyUser?.sortableName = session.userName
            legacyUser?.shortName = session.userName
            legacyUser?.avatarURL = profile.avatar_url?.rawValue
            legacyUser?.loginID = profile.login_id
            legacyUser?.email = profile.primary_email
            legacyUser?.calendar = profile.calendar?.ics
            legacyUser?.sisUserID = ""
            legacyClient.setValue(legacyUser, forKey: "currentUser")
            CKIClient.current = legacyClient
            GetBrandVariables().fetch(environment: self.environment) { _, _, _ in
                Brand.setCurrent(Brand(core: Core.Brand.shared), applyInWindow: self.window)
                NativeLoginManager.login(as: session, wasReload: wasReload)
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
            self.setup(session: session, wasReload: true)
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
                if helmVC.moduleName == url.path {
                    rootView.selectedIndex = index
                    rootView.resetSelectedViewController()
                    return
                }
            }

            RCTLinkingManager.application(app, open: url, options: options)
        }
        return true
    }
}

extension AppDelegate: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        if hasFirebase {
            Analytics.logEvent(name, parameters: parameters)
        }
    }
}

extension AppDelegate: RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
}

extension AppDelegate: LoginDelegate, NativeLoginManagerDelegate {
    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self)
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
}

// MARK: Crashlytics
extension AppDelegate {
    @objc func setupCrashlytics() {
        guard !uiTesting else { return }
        guard hasFabric else {
            NSLog("WARNING: Crashlytics was not properly initialized.")
            return
        }

        Fabric.with([Crashlytics.self, Answers.self])
        CanvasCrashlytics.setupForReactNative()
    }
}
