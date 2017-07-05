//
//  AppDelegate.swift
//  Teacher
//
//  Created by Derrick Hathaway on 4/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import CanvasKeymaster
import ReactiveSwift
import UserNotifications
import PSPDFKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
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
        return true
    }
    
    func prepareReactNative() {
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
    }
    
    func preparePSPDFKit() {
    PSPDFKit.setLicenseKey("OTHwfJpEorug7eEHAwjZtVUFIa5AgMbKA4o6Z0vO5JHB27GtywIs9XpZ5DVdhYJmBEBLkoKXHxO+juOjUeAjTi5NpUy00bhM0msTMBugxA7hquQYyk0jttdAUYTYZFmJNkQ0a/E/X3ABC7zMYCj18Ntirin6Ac+/sy/4jCgmfnO3rHrWQEGhii2XMtMro3UW9L5JYKNpxD85Civ8cpxm2Im43kh7clwkNcZ+7zfNHCHqRwBjmPKTFd5O1tRvvGIpuSS1F2x406WTF6yh8bymTstWekAy0PXuYCAaHfemopEBSP6VO2M8CICGNfCmO2TUeaL9aXLwuzp37BGTV6rP4w2af+TfpRWJ+oaVGBo4hi+T+aaI7zot6NVDPYPrvJPgmrjtp24FMEm9/mJLsO46905oQyhcdIbc+P6Cx2Dhk9N8zE+PPZO/ByDvGVx4UbYsBcjsasSwvyNf0sGKz3iNnUMGr+o6PK1LXgyb4n6LqKGKWUNFk3zQALNbnj2J4Jel52CY18aO1t3XUzBhBw6txuIyueYYxK+nRv+4DrkO1KHmvmtKAhbl9HKgWbnWxkw7mIVotSAhyCalisg/e7LveQ==")
        
        PSPDFScrollView.swizzleAllTehThings()
    }
    
    func createMainWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
    }
    
    func initiateLoginProcess() {
        CanvasKeymaster.the().fetchesBranding = true
        CanvasKeymaster.the().delegate = LoginConfiguration.shared
        
        NativeLoginManager.shared().delegate = self
    }
    
    func setupForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
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
            HelmManager.branding = Brand(webPayload: brandingInfo)
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        self.window?.rootViewController = controller
    }
}
