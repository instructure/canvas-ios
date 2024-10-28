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
import Combine
import Core
import FirebaseCrashlyticsSwift
import FirebaseRemoteConfigSwift
import Firebase
import Heap
import PSPDFKit
import SafariServices
import UIKit
import UserNotifications

@UIApplicationMain
class TeacherAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)
    private var subscriptions = Set<AnyCancellable>()

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Teacher.router
        env.loginDelegate = self
        env.app = .teacher
        env.window = window
        return env
    }()
    private var environmentFeatureFlags: Store<GetEnvironmentFeatureFlags>?
    private var isK5User = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if NSClassFromString("XCTestCase") != nil { return true }
        LoginSession.migrateSessionsToBeAccessibleWhenDeviceIsLocked()
        setupFirebase()
        CacheManager.resetAppIfNecessary()
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        setupDefaultErrorHandling()
        DocViewerViewController.setup(.teacherPSPDFKitLicense)
        setupPageViewLogging()
        PushNotificationsInteractor.shared.notificationCenter.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        UITableView.setupDefaultSectionHeaderTopPadding()
        FontAppearance.update()

        if let session = LoginSession.mostRecent {
            window?.rootViewController = LoadingViewController.create()
            window?.makeKeyAndVisible()
            userDidLogin(session: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true, app: .teacher)
            window?.makeKeyAndVisible()
            Analytics.shared.logScreenView(route: "/login", viewController: window?.rootViewController)
        }

        handleLaunchOptionsNotifications(launchOptions)

        return true
    }

    func setup(session: LoginSession, wasReload: Bool = false) {
        environment.userDidLogin(session: session)

        let getProfile = GetUserProfileRequest(userID: "self")
        environment.api.makeRequest(getProfile) { apiProfile, urlResponse, error in performUIUpdate {
            PageViewEventController.instance.userDidChange()

            guard let apiProfile = apiProfile, error == nil else {
                if urlResponse?.isUnauthorized == true {
                    self.userDidLogout(session: session)
                    LoginViewModel().showLoginView(on: self.window!, loginDelegate: self, app: .teacher)
                }
                return
            }

            self.environmentFeatureFlags = self.environment.subscribe(GetEnvironmentFeatureFlags(context: Context.currentUser))
            self.environmentFeatureFlags?.refresh(force: true) { _ in
                defer { self.environmentFeatureFlags = nil }
                guard let envFlags = self.environmentFeatureFlags, envFlags.error == nil else { return }
                self.initializeTracking()
            }

            self.updateInterfaceStyle(for: self.window)
            CoreWebView.keepCookieAlive(for: self.environment)
            PushNotificationsInteractor.shared.userDidLogin(loginSession: session)

            self.isK5User = apiProfile.k5_user == true
            Analytics.shared.logSession(session)

            LocalizationManager.localizeForApp(UIApplication.shared, locale: apiProfile.locale) {
                ReactiveStore(useCase: GetBrandVariables())
                    .getEntities()
                    .receive(on: RunLoop.main)
                    .replaceError(with: [])
                    .sink { [weak self] brandVars in
                        brandVars.first?.applyBrandTheme()
                        self?.setTabBarController()
                    }
                    .store(in: &self.subscriptions)
            }
        }}
    }

    func setTabBarController() {
        guard let window = self.window else { return }
        let controller = TeacherTabBarController()
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            window.rootViewController = controller
        }, completion: { _ in
            self.environment.startupDidComplete()
            UIApplication.shared.registerForPushNotifications()
        })
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationsInteractor.shared.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
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
        if let url = response.notification.request.routeURL {
            openURL(url, userInfo: [
                "forceRefresh": true,
                "pushNotification": response.notification.request.content.userInfo["aps"] ?? [:]
            ])
        }
        completionHandler()
    }

    func handleLaunchOptionsNotifications(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if
            let notification = launchOptions?[.remoteNotification] as? [AnyHashable: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            if let url = notification.routeURL {
                openURL(url, userInfo: [
                    "forceRefresh": true,
                    "pushNotification": aps
                ])
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
        if (!uiTesting) {
            AppStoreReview.handleLaunch()
        }
        updateInterfaceStyle(for: window)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreWebView.stopCookieKeepAlive()
        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return openURL(url)
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
                }
            }
        }
    }
}

// MARK: PageView Logging
extension TeacherAppDelegate {
    func setupPageViewLogging() {
        class BackgroundAppHelper: AppBackgroundHelperProtocol {

            let queue = DispatchQueue(label: "com.instructure.icanvas.app-background-helper", attributes: .concurrent)
            var tasks: [String: UIBackgroundTaskIdentifier] = [:]

            func startBackgroundTask(taskName: String) {
                queue.async(flags: .barrier) { [weak self] in
                    self?.tasks[taskName] = UIApplication.shared.beginBackgroundTask(
                        withName: taskName,
                        expirationHandler: { [weak self] in
                            self?.endBackgroundTask(taskName: taskName)
                    })
                }
            }

            func endBackgroundTask(taskName: String) {
                queue.async(flags: .barrier) { [weak self] in
                    if let task = self?.tasks[taskName] {
                        self?.tasks[taskName] = .invalid
                        UIApplication.shared.endBackgroundTask(task)
                    }
                }
            }
        }

        let helper = BackgroundAppHelper()
        PageViewEventController.instance.configure(backgroundAppHelper: helper)
    }
}

extension TeacherAppDelegate: AnalyticsHandler {

    func handleScreenView(screenName: String, screenClass: String, application: String) {
        Firebase.Crashlytics.crashlytics().log("\(screenName) (\(screenClass))")
    }

    func handleError(_ name: String, reason: String) {
        let model = ExceptionModel(name: name, reason: reason)
        Firebase.Crashlytics.crashlytics().record(exceptionModel: model)
    }

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        if Heap.isTrackingEnabled() {
            Heap.track(name, withProperties: parameters)
        }

        PageViewEventController.instance.logPageView(
            name,
            attributes: parameters
        )
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

extension TeacherAppDelegate: LoginDelegate {
    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        disableTracking()
        LoginViewModel().showLoginView(on: window, loginDelegate: self, app: .teacher)
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
        guard let from = environment.topViewController, url.scheme?.hasPrefix("http") == true else {
            return UIApplication.shared.open(url, options: [:])
        }
        let safari = SFSafariViewController(url: url)
        safari.transitioningDelegate = ResetTransitionDelegate.shared
        environment.router.show(safari, from: from, options: .modal())
    }

    func openExternalURLinSafari(_ url: URL) {
        UIApplication.shared.open(url)
    }

    func userDidLogin(session: LoginSession) {
        LoginSession.add(session)
        setup(session: session)
    }

    func userDidStopActing(as session: LoginSession) {
        disableTracking()
        LoginSession.remove(session)
        guard environment.currentSession == session else { return }
        PageViewEventController.instance.userDidChange()
        PushNotificationsInteractor.shared.unsubscribeFromCanvasPushNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
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

    func actAsFakeStudent(withID fakeStudentID: String) {
        actAsFakeStudent(with: fakeStudentID)
    }

    func actAsFakeStudent(with fakeStudentID: String, rootAccount: String? = nil) {
        guard let session = environment.currentSession else { return }

        var baseUrl = session.baseURL
        if let rootAccountHost = rootAccount {
            var components = URLComponents()
            components.scheme = "https"
            components.host = rootAccountHost
            baseUrl = components.url ?? baseUrl
        }

        let entry = LoginSession(
            accessToken: session.accessToken,
            baseURL: baseUrl,
            expiresAt: session.expiresAt,
            lastUsedAt: Date(),
            locale: session.locale,
            masquerader: (session.originalBaseURL ?? session.baseURL)
                .appendingPathComponent("fake-students")
                .appendingPathComponent(session.originalUserID ?? session.userID),
            refreshToken: session.refreshToken,
            userAvatarURL: nil,
            userID: fakeStudentID,
            userName: String(localized: "Test Student", bundle: .teacher),
            userEmail: session.userEmail,
            clientID: session.clientID,
            clientSecret: session.clientSecret
        )
        LoginSession.add(entry, to: .shared, forKey: .fakeStudents)
        var deepLink = "canvas-student:student_view"
        if isK5User == true {
            deepLink.append("_k5")
        }
        if let url = URL(string: deepLink) {
            UIApplication.shared.open(url)
        }
    }

    func actAsStudentViewStudent(studentViewStudent: APIUser) {
        if let url = URL(string: "canvas-student://"), UIApplication.shared.canOpenURL(url) {
            actAsFakeStudent(with: studentViewStudent.id.rawValue, rootAccount: studentViewStudent.root_account)
        } else if let url = URL(string: "https://itunes.apple.com/us/app/canvas-student/id480883488?ls=1&mt=8") {
            openExternalURL(url)
        }
    }
}

// MARK: Error Handling
extension TeacherAppDelegate {
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
extension TeacherAppDelegate {
    @objc func setupFirebase() {
        guard !testing else { return }

        if FirebaseOptions.defaultOptions()?.apiKey != nil {
            FirebaseApp.configure()
            configureRemoteConfig()
            Core.Analytics.shared.handler = self
        }
    }
}

// MARK: Launching URLS
extension TeacherAppDelegate {
    @objc @discardableResult func openURL(_ url: URL, userInfo: [String: Any]? = nil) -> Bool {
        if LoginSession.mostRecent == nil, let host = url.host {
            let loginNav = LoginNavigationController.create(loginDelegate: self, app: .teacher)
            loginNav.login(host: host)
            window?.rootViewController = loginNav
            Analytics.shared.logScreenView(route: "/login", viewController: window?.rootViewController)
        }

        let tabRoutes = [["/", "", "/courses", "/groups"], ["/to-do"], ["/conversations", "/inbox"]]
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

extension TeacherAppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url, app: .teacher) {
            window?.rootViewController = LoadingViewController.create()
            login.fetch(environment: environment) { [weak self] session, error in
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
