//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CoreData
import Core
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, AppEnvironmentDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Student.router
        env.backgroundAPIManager.eventsHandler = self
        return env
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        environment.logger.log(#function)
        DocViewerViewController.setup(.studentPSPDFKitLicense)
        setupNotifications()

        if let session = Keychain.mostRecentSession {
            window.rootViewController = LoadingViewController.create()
            userDidLogin(keychainEntry: session)
        } else {
            window.rootViewController = LoginNavigationController.create(loginDelegate: self, fromLaunch: true)
        }
        window.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        CoreWebView.keepCookieAlive(for: environment)
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        environment.backgroundAPIManager.create(withIdentifier: identifier)
        environment.backgroundAPIManager.add(completionHandler: completionHandler, forIdentifier: identifier)
        environment.logger.log(#function)
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
        Keychain.currentSession = session
        environment.userDidLogin(session: session)
        CoreWebView.keepCookieAlive(for: environment)
        let getBrand = GetBrandVariables(env: environment, force: true)
        getBrand.completionBlock = { DispatchQueue.main.async { self.showRootView() } }
        environment.queue.addOperation(getBrand)
    }

    func showRootView() {
        let controller = RootViewController.create()
        controller.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.window.rootViewController = controller
        }, completion: nil)

        // FIXME: Move to dev menu
        if CommandLine.arguments.contains("RouterDebug") {
            controller.selectedViewController?.show(RouterViewController(), sender: nil)
        }
    }
}

extension AppDelegate: LoginDelegate {
    var loginLogo: UIImage { return UIImage(named: "CanvasStudent")! }

    func changeUser() {
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window.rootViewController = LoginNavigationController.create(loginDelegate: self)
        }, completion: nil)
    }

    func openExternalURL(_ url: URL) {
        // FIXME: Should open SFSafariViewController?
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        try? NSPersistentContainer.destroy(session: keychainEntry)
        guard Keychain.currentSession == keychainEntry else { return }
        Keychain.currentSession = nil
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
        window.rootViewController?.present(alert, animated: true)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreWebView.stopCookieKeepAlive()
        if LocalizationManager.needsRestart {
            exit(EXIT_SUCCESS)
        }
    }
}

extension AppDelegate: BackgroundURLSessionDelegateEventHandler {
    func urlSessionDidFinishEvent(forBackgroundURLSession session: URLSession) {
        environment.logger.log(#function)
        guard let currentUser = Keychain.currentSession else {
            return
        }
        let createSubmissions = CreateFileSubmissions(env: environment, userID: currentUser.userID)
        environment.queue.addOperation(createSubmissions)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        environment.logger.log("app delegate, \(#function)")
        let operation = OperationSet()
        for entry in Keychain.entries {
            let env = AppEnvironment()
            env.router = Student.router
            env.userDidLogin(session: entry)
            environment.logger.log("finishing events for user \(entry.userID)")
            operation.addOperation(CreateFileSubmissions(env: env, userID: entry.userID))
        }
        environment.queue.addOperations([operation], waitUntilFinished: true)
        environment.backgroundAPIManager.complete(session: session)
    }

    func topMostViewController() -> UIViewController? {
        return window.rootViewController?.topMostViewController()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        if let urlString = response.notification.request.content.userInfo[NotificationManager.RouteURLKey] as? String,
            let url = URL(string: urlString),
            let topVC = topMostViewController() {
            router.route(to: url, from: topVC, options: [.modal, .embedInNav, .addDoneButton])
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
