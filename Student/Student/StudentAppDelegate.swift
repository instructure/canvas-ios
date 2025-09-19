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
import Horizon
import HorizonUI
import PSPDFKit
import UIKit
import UserNotifications
import WidgetKit

enum LoginError: Error {
    case loggedOut
    case unauthorized
}

@UIApplicationMain
class StudentAppDelegate: UIResponder, UIApplicationDelegate, AppEnvironmentDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)
    private var subscriptions = Set<AnyCancellable>()

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.loginDelegate = self
        env.router = academicRouter
        env.app = .student
        env.window = window
        return env
    }()

    private var environmentFeatureFlags: Store<GetEnvironmentFeatureFlags>?
    private var shouldSetK5StudentView = false
    private var backgroundFileSubmissionAssembly: FileSubmissionAssembly?

    private lazy var todoWidgetRouter = WidgetRouter.createTodoRouter()
    private lazy var gradeListWidgetRouter = WidgetRouter.createGradeListRouter()
    private lazy var courseGradeWidgetRouter = WidgetRouter.createCourseGradeRouter()

    private lazy var analyticsTracker: PendoAnalyticsTracker = {
        .init(environment: environment)
    }()
    private lazy var appExperienceInteractor = ExperienceSummaryInteractorLive(environment: environment)

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CDExperienceSummary.registerTransformers()
        HorizonUI.registerCustomFonts()
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

        listenForExperienceChanges()

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

        unowned let unownedSelf = self

        ReactiveStore(useCase: GetUserProfile())
            .getEntities(ignoreCache: true)
            .tryCatch { unownedSelf.catchViewAsStudentLoginError(error: $0, session: session) }
            .flatMap { list in
                let userProfile = list.first
                return unownedSelf.setupUserEnvironment()
                    .flatMap { _ in unownedSelf.getFeatureFlags() }
                    .map { unownedSelf.initializeTracking(environmentFeatureFlags: $0) }
                    .map { _ in unownedSelf.requestNotificationAuthorizationForUITests() }
                    .map { _ in unownedSelf.setK5StudentViewIfNeeded(userProfile: userProfile) }
                    .flatMap { _ in unownedSelf.showLanguageAlertIfNeeded(locale: userProfile?.locale ?? session.locale) }
                    .flatMap { _ in unownedSelf.getAndSetBrandTheme() }
                    .eraseToAnyPublisher()
            }
            .flatMap { _ in unownedSelf.getAppExperienceSummary() }
            .mapError { unownedSelf.mapSetupError(error: $0, session: session) }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        unownedSelf.showErrorAlert(error: error, session: session)
                    }
                },
                receiveValue: { experience in
                    unownedSelf.refreshNotificationTab()
                    Analytics.shared.logSession(session)
                    unownedSelf.setTabBarControllerFor(experience: experience, isStartup: true, session: session)
                }
            )
            .store(in: &subscriptions)
    }

    func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme?.range(of: "pendo") != nil {
            analyticsTracker.initManager(with: url)
            return true
        }

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

    func applicationDidBecomeActive(_: UIApplication) {
        AppStoreReview.handleLaunch()
        CoreWebView.keepCookieAlive(for: environment)
        updateInterfaceStyle(for: window)
    }

    func applicationDidEnterBackground(_: UIApplication) {
        Logger.shared.log()
        CoreWebView.stopCookieKeepAlive()
        BackgroundVideoPlayer.shared.background()
        environment.refreshWidgets()

        OfflineSyncScheduleInteractor().scheduleNextSync()

        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }

    func applicationWillEnterForeground(_: UIApplication) {
        BackgroundVideoPlayer.shared.reconnect()
    }

    func application(_: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
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

    func checkForWidgetsPresence() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard result.isSuccess, let widgetInfo = result.value else { return }

            let widgetKinds = widgetInfo.map { $0.kind }

            if widgetKinds.contains("TodoWidget") {
                Analytics.shared.logEvent(TodoWidgetEventNames.active.rawValue)
            }

            if widgetKinds.contains("GradeListWidget") {
                Analytics.shared.logEvent(GradeListWidgetEventNames.active.rawValue)
            }

            if widgetKinds.contains("CourseTotalGradeWidget") {
                Analytics.shared.logEvent(CourseGradeWidgetEventNames.active.rawValue)
            }
        }
    }
}

// MARK: - Setup User Environment

extension StudentAppDelegate {
    private func setupUserEnvironment() -> AnyPublisher<Void, Error> {
        PageViewEventController.instance.userDidChange()
        updateInterfaceStyle(for: window)
        CoreWebView.keepCookieAlive(for: environment)
        PushNotificationsInteractor.shared.userDidLogin(api: environment.api)

        return Publishers.typedJust()
    }

    private func getFeatureFlags() -> AnyPublisher<[FeatureFlag], Error> {
        ReactiveStore(
            useCase: GetEnvironmentFeatureFlags(context: Context.currentUser)
        )
        .getEntities(ignoreCache: true)
        .eraseToAnyPublisher()
    }

    private func getAndSetBrandTheme() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetBrandVariables())
            .getEntities(ignoreCache: true)
            .compactMap { $0.first }
            .map { $0.applyBrandTheme() }
            .eraseToAnyPublisher()
    }

    private func getAppExperienceSummary() -> AnyPublisher<Experience, Error> {
        appExperienceInteractor.getExperienceSummary()
    }

    private func requestNotificationAuthorizationForUITests() {
        // NotificationManager.registerForRemoteNotifications is not called in UITests,
        // so we need to requestAuthorization in order to be able to test notification related logic like
        // AssignmentReminders
        if ProcessInfo.isUITest {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert], completionHandler: { _, _ in })
        }
    }

    private func setK5StudentViewIfNeeded(userProfile: UserProfile?) {
        environment.userDefaults?.isK5StudentView = shouldSetK5StudentView
        let isK5StudentView = environment.userDefaults?.isK5StudentView ?? false
        if isK5StudentView {
            ExperimentalFeature.K5Dashboard.isEnabled = true
            environment.userDefaults?.isElementaryViewEnabled = true
        }
        environment.k5.userDidLogin(profile: userProfile, isK5StudentView: isK5StudentView)
    }

    private func catchViewAsStudentLoginError(error: Error, session: LoginSession) -> AnyPublisher<[UserProfile], Error> {
        let err = error as NSError
        if err.domain == NSError.Constants.domain,
           err.code == HttpError.forbidden, session.isFakeStudent {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    private func mapSetupError(error: Error, session: LoginSession) -> Error {
        let err = error as NSError
        if err.domain == NSError.Constants.domain,
           err.code == HttpError.unauthorized, !session.isFakeStudent {
            userDidLogout(session: session)
            return LoginError.unauthorized
        } else if let apiError = error as? APIError, case .unauthorized = apiError {
            userDidLogout(session: session)
            return LoginError.unauthorized
        } else {
            return error
        }
    }

    private func showErrorAlert(error: Error, session: LoginSession) {
        if error is LoginError {
            environment.router.setRootViewController(
                isLoginTransition: false,
                viewController: LoginNavigationController.create(
                    loginDelegate: self,
                    app: .student
                )
            )
        } else {
            UIAlertController.showLoginErrorAlert(
                cancelAction: { [weak self] in
                    self?.userDidLogout(session: session)
                },
                retryAction: { [weak self] in
                    self?.setup(session: session)
                }
            )
        }
    }

    private func showIncorrectAppExperienceAlert(session: LoginSession?) {
        let alert = UIAlertController(
            title: String(
                localized: "Oops, something went wrong",
                bundle: .student
            ),
            message: String(
                localized: "It looks like your account isn't set up as a learner role. If you believe this is a mistake, contact your admin or support team.",
                bundle: .student
            ),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: "Logout", bundle: .core),
                style: .cancel
            ) { [weak self] _ in
                if let session {
                    self?.userDidLogout(session: session)
                }
            }
        )

        environment.topViewController?.present(alert, animated: true)
    }

    private func showLanguageAlertIfNeeded(locale: String?) -> AnyPublisher<Void, Error> {
        LocalizationManager.localizeForApp(
            UIApplication.shared,
            locale: locale
        )
        .flatMap { [weak self] languageAlert -> AnyPublisher<Void, Error> in
            if let languageAlert, let rootVC = self?.environment.window?.rootViewController {
                if let presented = rootVC.presentedViewController { // QR login alert
                    self?.environment.router.dismiss(presented) {
                        self?.environment.router.show(languageAlert, from: rootVC, options: .modal())
                    }
                } else {
                    self?.environment.router.show(languageAlert, from: rootVC, options: .modal())
                }
                return Empty().setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    private func listenForExperienceChanges() {
        AppEnvironment.shared.experience
            .dropFirst()
            .sink { [weak self] in
                self?.setTabBarControllerFor(experience: $0, isStartup: false, session: nil)
            }
            .store(in: &subscriptions)
    }

    private func setTabBarControllerFor(experience: Experience, isStartup: Bool, session: LoginSession?) {
        switch experience {
        case .academic:
            AppEnvironment.shared.app = .student
            AppEnvironment.shared.router = academicRouter
            guard let window = window else { return }

            let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [CoreNavigationController.self])
            appearance.barTintColor = nil
            appearance.tintColor = nil
            appearance.titleTextAttributes = nil

            let controller = StudentTabBarController()
            controller.view.layoutIfNeeded()
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = controller
            }, completion: { [weak self] _ in
                if isStartup {
                    self?.environment.startupDidComplete()
                    UIApplication.shared.registerForPushNotifications()
                }
            })
        case .careerLearner, .careerLearningProvider:
            AppEnvironment.shared.app = .horizon
            AppEnvironment.shared.router = Router(routes: HorizonRoutes.routeHandlers())
            HorizonUI.setInstitutionColor(Brand.shared.primary)
            guard let window = window else { return }
            let controller = HorizonTabBarController()
            controller.view.layoutIfNeeded()
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window.rootViewController = controller
            }, completion: { [weak self] _ in
                if isStartup {
                    self?.environment.startupDidComplete()
                    UIApplication.shared.registerForPushNotifications()
                }
            })
//        case .careerLearningProvider:
//            showIncorrectAppExperienceAlert(session: session)
        }
    }
}

// MARK: - Push notifications

extension StudentAppDelegate: UNUserNotificationCenterDelegate {
    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationsInteractor.shared.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        environment.reportError(error)
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard environment.app != .horizon else {
            return
        }
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
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
        analyticsTracker.track(name, properties: parameters)

        PageViewEventController.instance.logPageView(
            name,
            attributes: parameters
        )
    }

    private func initializeTracking(environmentFeatureFlags: [FeatureFlag]) {
        guard !ProcessInfo.isUITest else { return }

        let isTrackingEnabled = environmentFeatureFlags.isFeatureEnabled(.send_usage_metrics)

        if isTrackingEnabled {
            analyticsTracker.startSession(completion: checkForWidgetsPresence)
        } else {
            analyticsTracker.endSession()
        }
    }

    private func disableTracking() {
        analyticsTracker.endSession()
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
                        }
                    )
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
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                if let url = components,
                   let viewProxy = StudentAppViewProxy(window: self.window, env: self.environment) {
                    if self.todoWidgetRouter.handling(url, using: viewProxy) { return }
                    if self.courseGradeWidgetRouter.handling(url, using: viewProxy) { return }
                    if self.gradeListWidgetRouter.handling(url, using: viewProxy) { return }
                }

                components?.originIsNotification = true
                AppEnvironment.shared.router.route(
                    to: components?.url ?? url,
                    userInfo: userInfo,
                    from: from,
                    options: .modal(embedInNav: true, addDoneButton: true)
                )
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
        guard let window, window.isShowingLoginStartViewController == false else { return }
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
        UNUserNotificationCenter.current().setBadgeCount(0)
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

    func actAsFakeStudent(withID _: String) {}

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
    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
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
