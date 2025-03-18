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
import Combine
import Core
import Firebase
import Heap
import PSPDFKit
import UIKit
import UserNotifications

@UIApplicationMain
class StudentAppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)
    private var subscriptions = Set<AnyCancellable>()

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = self
        env.router = router
        env.app = .student
        env.window = window
        return env
    }()
    private var environmentFeatureFlags: Store<GetEnvironmentFeatureFlags>?
    private var shouldSetK5StudentView = false
    private var backgroundFileSubmissionAssembly: FileSubmissionAssembly?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LoginSession.migrateSessionsToBeAccessibleWhenDeviceIsLocked()
        BackgroundProcessingAssembly.register(scheduler: CoreTaskSchedulerLive(taskScheduler: .shared))
        BackgroundProcessingAssembly.register(taskID: OfflineSyncBackgroundTaskRequest.ID) {
            CourseSyncBackgroundUpdatesAssembly.makeOfflineSyncBackgroundTask()
        }
        BackgroundProcessingAssembly.resolveInteractor().register(taskID: OfflineSyncBackgroundTaskRequest.ID)
        setupFirebase()
        CacheManager.resetAppIfNecessary()

        #if DEBUG
            UITestHelpers.setup(self)
        #endif

        DocViewerViewController.setup(.studentPSPDFKitLicense)
        setupDefaultErrorHandling()
        setupPageViewLogging()
        PushNotificationsInteractor.shared.notificationCenter.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        UITableView.setupDefaultSectionHeaderTopPadding()
        Appearance.update()

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
            RemoteLogger.shared.logBreadcrumb(route: "/login", viewController: window?.rootViewController)
        }

        return true
    }

    func setup(session: LoginSession) {
        environment.userDidLogin(session: session)
        // This is to handle the case where the app is force closed while a background upload was in progress.
        // In this case the upload is canceled and app is not launched with `handleEventsForBackgroundURLSession`
        // so we manually re-connect to the background url session to check if there are any failed uploads.
        // If a debugger is attached to the app, the upload will fail with a `Could not communicate with background transfer service` error.
        if !testing {
            setupFileSubmissionAssemblyForBackgroundUploads(completion: nil)
        }

        GetUserProfile().fetch(environment: environment, force: true) { apiProfile, urlResponse, _ in performUIUpdate {
            PageViewEventController.instance.userDidChange()

            if urlResponse?.isUnauthorized == true, !session.isFakeStudent {
                self.userDidLogout(session: session)
                LoginViewModel().showLoginView(on: self.window!, loginDelegate: self, app: .student)
                return
            }

            self.environment.userDefaults?.isK5StudentView = self.shouldSetK5StudentView
            self.environmentFeatureFlags = self.environment.subscribe(GetEnvironmentFeatureFlags(context: Context.currentUser))
            self.environmentFeatureFlags?.refresh(force: true) { _ in
                defer { self.environmentFeatureFlags = nil }
                guard let envFlags = self.environmentFeatureFlags, envFlags.error == nil else { return }
                self.initializeTracking()
            }

            self.updateInterfaceStyle(for: self.window)
            CoreWebView.keepCookieAlive(for: self.environment)
            PushNotificationsInteractor.shared.userDidLogin(loginSession: session)

            // NotificationManager.registerForRemoteNotifications is not called in UITests,
            // so we need to requestAuthorization in order to be able to test notification related logic like
            // AssignmentReminders
            if ProcessInfo.isUITest {
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert], completionHandler: { _, _ in })
            }

            let isK5StudentView = self.environment.userDefaults?.isK5StudentView ?? false
            if isK5StudentView {
                ExperimentalFeature.K5Dashboard.isEnabled = true
                self.environment.userDefaults?.isElementaryViewEnabled = true
            }
            self.environment.k5.userDidLogin(profile: apiProfile, isK5StudentView: isK5StudentView)
            Analytics.shared.logSession(session)

            self.refreshNotificationTab()
            LocalizationManager.localizeForApp(UIApplication.shared, locale: apiProfile?.locale ?? session.locale) {
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
        let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [CoreNavigationController.self])
        appearance.barTintColor = nil
        appearance.tintColor = nil
        appearance.titleTextAttributes = nil

        guard let window = self.window else { return }
        let controller = StudentTabBarController()
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            window.rootViewController = controller
        }, completion: { _ in
            self.environment.startupDidComplete()
            UIApplication.shared.registerForPushNotifications()
        })
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if options[.sourceApplication] as? String == Bundle.teacherBundleID,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.path.contains("student_view"),
           let fakeStudent = LoginSession.mostRecent(in: .shared, forKey: .fakeStudents) {
            shouldSetK5StudentView = components.path.contains("k5")
            userDidLogin(session: fakeStudent)
            return true
        }
        return openURL(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.handleLaunch()
        CoreWebView.keepCookieAlive(for: environment)
        updateInterfaceStyle(for: window)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.shared.log()
        CoreWebView.stopCookieKeepAlive()
        BackgroundVideoPlayer.shared.background()
        environment.refreshWidgets()

        OfflineSyncScheduleInteractor().scheduleNextSync()

        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        BackgroundVideoPlayer.shared.reconnect()
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Logger.shared.log()

        if identifier == FileSubmissionAssembly.ShareExtensionSessionID {
            setupFileSubmissionAssemblyForBackgroundUploads(completion: completionHandler)
        } else {
            let manager = UploadManager(env: environment, identifier: identifier)
            manager.completionHandler = {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
            manager.createSession()
        }
    }

    // If the application is launched from the background, we pass the completion from the `handleEventsForBackgroundURLSession` function.
    // If the application is launched normally, we don't need to pass system completion, the url session will tear down when it's finished. 
    private func setupFileSubmissionAssemblyForBackgroundUploads(completion: (() -> Void)?) {
        let backgroundAssembly = FileSubmissionAssembly.makeShareExtensionAssembly()
        backgroundAssembly.connectToBackgroundURLSession {
            DispatchQueue.main.async { [weak self] in
                completion?()
                self?.backgroundFileSubmissionAssembly = nil
            }
        }
        backgroundFileSubmissionAssembly = backgroundAssembly
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

// MARK: - Push notifications

extension StudentAppDelegate: UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationsInteractor.shared.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
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
        if let url = response.notification.request.routeURL {
            openURL(url, userInfo: [
                "forceRefresh": true,
                "pushNotification": response.notification.request.content.userInfo["aps"] ?? [:]
            ])
        }
        completionHandler()
    }
}

// MARK: - Usage Analytics

extension StudentAppDelegate: Core.AnalyticsHandler {

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

// MARK: - Error Handling

extension StudentAppDelegate {
    func setupDefaultErrorHandling() {
        environment.errorHandler = { error, controller in
            if OfflineModeAssembly.make().isOfflineModeEnabled() {
                return
            }

            performUIUpdate {
                let error = error as NSError
                error.showAlert(from: controller)
                if error.shouldRecordInCrashlytics {
                    Firebase.Crashlytics.crashlytics().record(error: error)
                }
            }
        }
    }
}

// MARK: - Crashlytics

extension StudentAppDelegate {

    @objc func setupFirebase() {
        guard !testing else {
            setupDebugCrashLogging()
            return
        }

        if FirebaseOptions.defaultOptions()?.apiKey != nil {
            FirebaseApp.configure()
            configureRemoteConfig()
            Core.Analytics.shared.handler = self
            RemoteLogger.shared.handler = self
        }
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

extension StudentAppDelegate: RemoteLogHandler {

    func handleBreadcrumb(_ name: String) {
        Firebase.Crashlytics.crashlytics().log(name)
    }

    func handleError(_ name: String, reason: String) {
        let model = ExceptionModel(name: name, reason: reason)
        Firebase.Crashlytics.crashlytics().record(exceptionModel: model)
    }
}

// MARK: - PageView Logging

extension StudentAppDelegate {
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

// MARK: - Launching URLS

extension StudentAppDelegate {
    @objc @discardableResult func openURL(_ url: URL, userInfo: [String: Any]? = nil) -> Bool {
        if LoginSession.mostRecent == nil, let host = url.host {
            let loginNav = LoginNavigationController.create(loginDelegate: self, app: .student)
            loginNav.login(host: host)
            window?.rootViewController = loginNav
            RemoteLogger.shared.logBreadcrumb(route: "/login", viewController: window?.rootViewController)
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

// MARK: - Login Delegate

extension StudentAppDelegate: LoginDelegate {
    func changeUser() {
        shouldSetK5StudentView = false
        environment.k5.userDidLogout()
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        disableTracking()
        LoginViewModel().showLoginView(on: window, loginDelegate: self, app: .student)
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
        openExternalURLinSafari(url)
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
        deleteAssignmentRemindersAsync(userId: session.userID)
    }

    func userDidLogout(session: LoginSession) {
        disableTracking()
        shouldSetK5StudentView = false
        let wasCurrent = environment.currentSession == session
        API(session).makeRequest(DeleteLoginOAuthRequest(), refreshToken: false) { _, _, _ in }
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func actAsFakeStudent(withID fakeStudentID: String) {}

    private func deleteAssignmentRemindersAsync(userId: String) {
        var reminderDeleteSubscription: AnyCancellable?
        reminderDeleteSubscription = AssignmentRemindersInteractorLive(notificationCenter: UNUserNotificationCenter.current())
            .deleteAllReminders(userId: userId)
            .sink { _ in
                reminderDeleteSubscription?.cancel()
                reminderDeleteSubscription = nil
            } receiveValue: { _ in }
    }
}

// MARK: - Handle siri notifications
extension StudentAppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url, app: .student) {
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
