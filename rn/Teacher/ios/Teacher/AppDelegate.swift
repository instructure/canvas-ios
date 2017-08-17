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

public let EarlGreyExists = NSClassFromString("EarlGreyImpl") != nil;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        BuddyBuildSDK.uiTestsDidReceiveRemoteNotification(userInfo)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        BugsnagReactNative.start()
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
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID", factory: { props in
            let split = EnrollmentSplitViewController()
            
            let master = HelmViewController(moduleName: "/courses/:courseID", props: props)
            let masterNav = HelmNavigationController()
            masterNav.viewControllers = [EmptyViewController(), master]
            masterNav.view.backgroundColor = .white
            masterNav.delegate = split
            // setting the UINavController's delegate breaks the interactive pop. This fixes it.
            masterNav.interactivePopGestureRecognizer?.delegate = split
            
            let emptyNav = HelmNavigationController(rootViewController: EmptyViewController())
            
            split.viewControllers = [masterNav, emptyNav]
            split.view.accessibilityIdentifier = "favorited-course-list.view"
            split.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: UIImage(named: "courses"), selectedImage: nil)
            split.tabBarItem.accessibilityIdentifier = "tab-bar.courses-btn"
            
            return split
        }, withCustomPresentation: { (current, new) in
            guard let tabVC = current.tabBarController else { return }
            var vcs = tabVC.viewControllers ?? []
            vcs[0] = new
            
            let snapshot = tabVC.view.snapshotView(afterScreenUpdates: true)!
            let tabVCView = tabVC.view
            let prevCenter = tabVC.view.center
            let window = UIApplication.shared.delegate!.window!
            
            if let tabVCView = tabVCView {
                tabVCView.center = CGPoint(x: tabVCView.center.x + tabVCView.frame.size.width + 20 /* who knows why */, y: tabVCView.center.y)
                window?.insertSubview(snapshot, belowSubview: tabVC.view)
                
                UIView.animate(withDuration: 0.3, animations: {
                    tabVC.setViewControllers(vcs, animated: false)
                    tabVCView.center = prevCenter
                    snapshot.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: { _ in
                    snapshot.removeFromSuperview()
                })
            }
        })
        HelmManager.shared.registerNativeViewController(for: "/attendance", factory: { props in
            guard
                let destinationURL = (props["launchURL"] as? String).flatMap(URL.init(string:)),
                let courseName = props["courseName"] as? String,
                let courseID = props["courseID"] as? String,
                let courseColor = props["courseColor"].flatMap(RCTConvert.uiColor)
                else { return nil }
                
                return TeacherAttendanceViewController(
                    courseName: courseName,
                    courseColor: courseColor,
                    launchURL: destinationURL,
                    courseID: courseID,
                    date: Date()
                )
        })
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
        if (count > 10 && !EarlGreyExists) {
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
