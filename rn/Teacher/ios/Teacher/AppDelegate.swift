//
// Copyright (C) 2016-present Instructure, Inc.
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
import CanvasCore
import React
import BugsnagReactNative

public let EarlGreyExists = NSClassFromString("EarlGreyImpl") != nil;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let loginConfig = LoginConfiguration(mobileVerifyName: "iosTeacher", logo: #imageLiteral(resourceName: "logo"))
    var window: UIWindow?

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                self?.didRegisterForRemoteNotifications(deviceToken)
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        BuddyBuildSDK.uiTestsDidReceiveRemoteNotification(userInfo)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //BuddyBuildSDK.setup()
        BugsnagReactNative.start()
        Fabric.with([Crashlytics.self, Answers.self])
        setupForPushNotifications()
        preparePSPDFKit()
        window = MasqueradableWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .red
        showLoadingState()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.prepareReactNative()
            self.initiateLoginProcess()
        }
        
        return true
    }
    
    func prepareReactNative() {
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        registerNativeRoutes()
        HelmManager.shared.onReactLoginComplete = {
            self.window?.rootViewController = RootTabBarController()
        }
        HelmManager.shared.onReactReload = {
            self.showLoadingState()
        }
    }
    
    func showLoadingState() {
        if let root = window?.rootViewController, let tag = root.tag, tag == "LaunchScreenPlaceholder" { return }
        let placeholder = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        placeholder.tag = "LaunchScreenPlaceholder"
        window?.rootViewController = placeholder
        
        if let icon = placeholder.view.viewWithTag(12345) {
            icon.layer.add(StartupIconAnimation(), forKey: nil)
        }
    }
    
    func preparePSPDFKit() {
        guard let key = Secrets.fetch(.teacherPSPDFKit) else { return }
        PSPDFKit.setLicenseKey(key)
        PSPDFScrollView.swizzleAllTehThings()
    }
    
    func initiateLoginProcess() {
        CanvasKeymaster.the().fetchesBranding = true
        CanvasKeymaster.the().delegate = loginConfig
        
        NativeLoginManager.shared().delegate = self
    }
    
    func setupForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        UIApplication.shared.registerForRemoteNotifications()
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
        if (!EarlGreyExists) {
            AppStoreReview.requestReview()
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
            Brand.setCurrent(Brand(webPayload: brandingInfo))
            UITabBar.appearance().tintColor = Brand.current.primaryBrandColor
            UITabBar.appearance().barTintColor = .white
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        self.window?.rootViewController = controller
    }
}
