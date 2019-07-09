//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import CoreData
import Core
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, AppEnvironmentDelegate {
    lazy var window: UIWindow? = ActAsUserWindow(frame: UIScreen.main.bounds, loginDelegate: self)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Student.router
        return env
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        environment.logger.log(#function)
        #if DEBUG
            UITestHelpers.setup(self)
        #endif
        DocViewerViewController.setup(.studentPSPDFKitLicense)
        setupNotifications()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        if let session = Keychain.mostRecentSession {
            window?.rootViewController = LoadingViewController.create()
            userDidLogin(keychainEntry: session)
        } else {
            window?.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true)
        }
        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        environment.logger.log(#function)
        UploadManager.shared.completionHandler = {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL, let login = GetSSOLogin(url: url) {
            window?.rootViewController = LoadingViewController.create()
            login.fetch(environment: environment) { [weak self] (session, error) -> Void in
                guard let session = session, error == nil else {
                    self?.changeUser()
                    return
                }
                self?.userDidLogin(keychainEntry: session)
            }
            return true
        }
        return false
    }

    func setupNotifications() {
        if ProcessInfo.isUITest {
            return
        }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { [weak self] _, error in
            if let error = error {
                self?.environment.logger.log(error.localizedDescription)
            }
        }
    }

    func setup(session: KeychainEntry) {
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        GetBrandVariables().fetch(environment: environment) { _, _, _ in DispatchQueue.main.async {
            self.showRootView()
        } }
    }

    func showRootView() {
        guard let window = window else { return }
        let controller = RootViewController.create()
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            window.rootViewController = controller
        }, completion: nil)

        // FIXME: Move to dev menu
        if CommandLine.arguments.contains("RouterDebug") {
            controller.selectedViewController?.show(RouterViewController(), sender: nil)
        }
    }
}

extension AppDelegate: LoginDelegate {
    func changeUser() {
        guard let window = window, !(window.rootViewController is LoginNavigationController) else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self)
        }, completion: nil)
    }

    func openExternalURL(_ url: URL) {
        // FIXME: Should open SFSafariViewController?
        UIApplication.shared.open(url)
    }

    func userDidLogin(keychainEntry: KeychainEntry) {
        Keychain.addEntry(keychainEntry)
        // TODO: Register for push notifications?
        LocalizationManager.setCurrentLocale(keychainEntry.locale)
        if LocalizationManager.needsRestart {
            restartForLocalization()
        } else {
            setup(session: keychainEntry)
        }
    }

    func userDidLogout(keychainEntry: KeychainEntry) {
        Keychain.removeEntry(keychainEntry)
        // TODO: Deregister push notifications?
        guard environment.currentSession == keychainEntry else { return }
        environment.userDidLogout(session: keychainEntry)
        CoreWebView.stopCookieKeepAlive()
        changeUser()
    }
}

extension AppDelegate {
    func restartForLocalization() {
        let alert = UIAlertController(
            title: NSLocalizedString("Updated Language Settings", bundle: .student, comment: ""),
            message: NSLocalizedString("The app needs to restart to use the new language settings. Please relaunch the app.", bundle: .student, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close App", bundle: .student, comment: ""), style: .default) { _ in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        })
        window?.rootViewController?.present(alert, animated: true)
    }

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

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        if let route = response.notification.route,
            let topVC = topMostViewController() {
            router.route(to: route, from: topVC, options: [.modal, .embedInNav, .addDoneButton])
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
