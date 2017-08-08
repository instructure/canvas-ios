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
import Fabric
import Crashlytics
import StoreKit

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
        Fabric.with([Crashlytics.self, Answers.self])
        return true
    }   
    
    func prepareReactNative() {
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
    }
    
    func preparePSPDFKit() {
    PSPDFKit.setLicenseKey("Hzs9OwBiE3F33ZKYtqFAN67SqJHbJx3FTPMVk7B+zxi8X19TDcp8eXOTxKC2zTjiRi+D6iqotN8+bti+mVFdCHynptBYRFCJN0B2gSJMUB7BPdKmb7aO6UhlQmkIQPmGQG+It17Bn6tnTPedf+nzudTKWtJXr61Lg/MRNWPs357snXX8Kfbmvy8TEU68uEi0FpbYW1totJqPXtv3ukc0kuSE4st0xV3DjH1LRQLtr1/f+/v9TSVFwY0FEBkliMRwyf2n1/gIUX+cmCZ6axLWBR7CTssjpYNgEs9jStAR8vaO3/cr0ojBglCtlu/D6CgCZAmHafGoiJqNgktkpHE4vAFzNI5clhc7ntmivFwuZbCuYQHXkthKfZffv9tg0P+8ZBMJ5fUqLQQVmnsE+QNIK6+AyZ/N13ECqbzF+QfJD29vXwwxCjD5vaq/mApjHXPOggix7hRnpU2I4U49HVal2AsezAeEkwMF+VrQe4KKDWNGtdDe0oeRJzx7WTf6zG39+kfu0BpFw2V1DHThR28rRga4HtHPMfYtwVfhE5c5onnI0S9bMrOi236RM8xTQO/Jnz+RAizKM0LZu0ZCwFc3Xg==")
        
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let key = "InstLaunchCount"
        var count = UserDefaults.standard.integer(forKey: key)
        count += 1
        if (count > 10) {
            if #available(iOS 10.3, *) {
                #if RELEASE
                SKStoreReviewController.requestReview()
                #endif
            }
        }
        
        UserDefaults.standard.set(count, forKey: key)
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
