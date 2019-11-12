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
import TechDebt
import PSPDFKit
import CanvasKit
import Fabric
import Crashlytics
import CanvasCore
import ReactiveSwift
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
        return env
    }()

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.shared.log()
        setupCrashlytics()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        CacheManager.resetAppIfNecessary()
        if hasFirebase {
            FirebaseApp.configure()
        }
        DocViewerViewController.setup(.studentPSPDFKitLicense)
        prepareReactNative()
        setupDefaultErrorHandling()
        setupPageViewLogging()
        UIApplication.shared.reactive.applicationIconBadgeNumber
            <~ TabBarBadgeCounts.applicationIconBadgeNumber
        Core.Analytics.shared.handler = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

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
        if hasFirebase {
            Analytics.setUserID(session.userID)
            Analytics.setUserProperty(session.baseURL.absoluteString, forName: "base_url")
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
            if let legacySession = Session.current {
                self.session = legacySession
                LegacyModuleProgressShim.observeProgress(legacySession)
                ModuleItem.beginObservingProgress(legacySession)
            }
            PageViewEventController.instance.userDidChange()
            CKCanvasAPI.updateCurrentAPI()
            GetBrandVariables().fetch(environment: self.environment) { _, _, _ in
                DispatchQueue.main.async {
                    Brand.setCurrent(Brand(core: Core.Brand.shared), applyInWindow: self.window)
                    NativeLoginManager.login(as: session, wasReload: wasReload)
                }
            }
        }
        Analytics.shared.logSession(session)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return openCanvasURL(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.handleLaunch()
        CoreWebView.keepCookieAlive(for: environment)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.shared.log()
        CoreWebView.stopCookieKeepAlive()
        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
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
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }

    @objc func handlePushNotificationRegistrationError(_ error: NSError) {
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["source": "push_notification_registration"])
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
            if let assignmentURL = userInfo[CBILocalNotificationAssignmentURLKey] as? String,
                let url = URL(string: assignmentURL) {
                self?.openCanvasURL(url)
                return
            } else if let routerURL = userInfo[NotificationManager.RouteURLKey] as? String,
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
        if hasFirebase {
            Analytics.logEvent(name, parameters: parameters)
        }
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
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: nil)
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

    @objc func setupCrashlytics() {
        guard !uiTesting else { return }
        guard hasFabric else {
            NSLog("WARNING: Crashlytics was not properly initialized.")
            return
        }

        Fabric.with([Crashlytics.self])
        CanvasCrashlytics.setupForReactNative()
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
            let loginNav = LoginNavigationController.create(loginDelegate: self)
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
                AppEnvironment.shared.router.route(to: comps?.url ?? url, from: from, options: [.modal, .embedInNav, .addDoneButton])
            }
        }
        return true
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
}

// MARK: - Handle siri notifications
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url) {
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
