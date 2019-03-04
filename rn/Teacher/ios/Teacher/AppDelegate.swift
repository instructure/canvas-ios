//
// Copyright (C) 2017-present Instructure, Inc.
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
import CanvasKeymaster
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

    @objc let loginConfig = LoginConfiguration(mobileVerifyName: "iosTeacher", logo: UIImage(named: "teacher-logomark")!, fullLogo: UIImage(named: "teacher-logo")!)
    var window: UIWindow?

    let hasFabric = (Bundle.main.object(forInfoDictionaryKey: "Fabric") as? [String: Any])?["APIKey"] != nil
    let hasFirebase = FirebaseOptions.defaultOptions()?.apiKey != nil

    lazy var environment: AppEnvironment = {
        let env = AppEnvironment.shared
        env.router = Teacher.router
        return env
    }()

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationKitController.didRegisterForRemoteNotifications(deviceToken) { [weak self] error in
            ErrorReporter.reportError(error.addingInfo(), from: self?.window?.rootViewController)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCrashlytics()
        ResetAppIfNecessary()
        if hasFirebase {
            FirebaseApp.configure()
        }
        setupForPushNotifications()
        preparePSPDFKit()
        window = MasqueradableWindow(frame: UIScreen.main.bounds)
        showLoadingState()
        window?.makeKeyAndVisible()
        UIApplication.shared.reactive.applicationIconBadgeNumber <~ TabBarBadgeCounts.applicationIconBadgeNumber
        
        DispatchQueue.main.async {
            self.prepareReactNative()
            self.initiateLoginProcess()
            CanvasAnalytics.setHandler(self)
        }
        
        return true
    }
    
    @objc func prepareReactNative() {
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        registerNativeRoutes()
        HelmManager.shared.onReactLoginComplete = {
            guard let window = self.window else { return }
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                let loading = UIViewController()
                loading.view.backgroundColor = .white
                window.rootViewController = loading
            }, completion: { _ in
                window.rootViewController = RootTabBarController()
            })
        }
        HelmManager.shared.onReactReload = {
            self.showLoadingState()
        }
    }
    
    @objc func showLoadingState() {
        guard let window = self.window else { return }
        if let root = window.rootViewController, let tag = root.tag, tag == "LaunchScreenPlaceholder" { return }
        let placeholder = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        placeholder.tag = "LaunchScreenPlaceholder"
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = placeholder
        }, completion:nil)
    }
    
    @objc func preparePSPDFKit() {
        guard let key = Secret.teacherPSPDFKitLicense.string else { return }
        PSPDFKit.setLicenseKey(key)
    }
    
    @objc func initiateLoginProcess() {
        CanvasKeymaster.the().fetchesBranding = true
        CanvasKeymaster.the().delegate = loginConfig
        
        NativeLoginManager.shared().delegate = self
    }
    
    @objc func setupForPushNotifications() {
        NotificationKitController.setupForPushNotifications(delegate: self)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushNotifications.record(response.notification)
        StartupManager.shared.enqueueTask {
            RCTPushNotificationManager.didReceiveRemoteNotification(response.notification.request.content.userInfo) { _ in
                completionHandler()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if (!uiTesting) {
            AppStoreReview.handleLaunch()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        LocalizationManager.closed()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
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

extension AppDelegate: CanvasAnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String : Any]?) {
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

extension AppDelegate: NativeLoginManagerDelegate {
    func didLogin(_ client: CKIClient) {
        if let brandingInfo = client.branding?.jsonDictionary() as? [String: Any] {
            Brand.setCurrent(Brand(webPayload: brandingInfo), applyInWindow: window)
            // copy to new Core.Brand
            if let data = try? JSONSerialization.data(withJSONObject: brandingInfo) {
                let response = try! JSONDecoder().decode(APIBrandVariables.self, from: data)
                Core.Brand.shared = Core.Brand(response: response)
            }
        }

        if let entry = client.keychainEntry {
            Keychain.addEntry(entry)
            environment.userDidLogin(session: entry)
            CoreWebView.keepCookieAlive(for: environment)
        }

        if let locale = client.effectiveLocale {
            LocalizationManager.setCurrentLocale(locale)
        }

        let countryCode: String? = Locale.current.regionCode
        if countryCode != "CA" {
            let session = client.authSession
            let crashlyticsUserId = "\(session.user.id)@\(session.baseURL.host ?? session.baseURL.absoluteString)"
            Crashlytics.sharedInstance().setUserIdentifier(crashlyticsUserId)
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        if let entry = Keychain.currentSession {
            Keychain.removeEntry(entry)
            environment.userDidLogout(session: entry)
            CoreWebView.stopCookieKeepAlive()
        }
        guard let window = self.window else { return }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = controller
        }, completion:nil)
    }
}

// MARK: Crashlytics
extension AppDelegate {

    @objc func setupCrashlytics() {
        guard !uiTesting else { return }
        guard hasFabric else {
            NSLog("WARNING: Crashlytics was not properly initialized.");
            return
        }

        Fabric.with([Crashlytics.self, Answers.self])
        CanvasCrashlytics.setupForReactNative()
    }
}
