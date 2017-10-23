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

public let EarlGreyExists = NSClassFromString("EarlGreyImpl") != nil;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let loginConfig = LoginConfiguration(mobileVerifyName: "iCanvas", logo: #imageLiteral(resourceName: "logo"))
    var window: UIWindow?

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        BuddyBuildSDK.uiTestsDidReceiveRemoteNotification(userInfo)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        prepareReactNative()
        preparePSPDFKit()
        createMainWindow()
        initiateLoginProcess()
        setupForPushNotifications()
        Fabric.with([Crashlytics.self, Answers.self])
        return true
    }   
    
    func prepareReactNative() {
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        registerNativeRoutes()
        HelmManager.shared.onReactLoginComplete = {
            self.window?.rootViewController = RootTabBarController()
        }
    }
    
    func preparePSPDFKit() {
        if let key = Secrets.fetch(.teacherPSPDFKit) {
            PSPDFKit.setLicenseKey(key)
            PSPDFScrollView.swizzleAllTehThings()
        }
    }
    
    func createMainWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
    }
    
    func initiateLoginProcess() {
        CanvasKeymaster.the().fetchesBranding = true
        CanvasKeymaster.the().delegate = loginConfig
        
        NativeLoginManager.shared().delegate = self
    }
    
    func setupForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
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
            Brand.setCurrent(Brand(webPayload: brandingInfo), applyInWindow: window)
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        self.window?.rootViewController = controller
    }
}
