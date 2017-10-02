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
import SoLazy
import BugsnagReactNative

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
            HelmManager.branding = Brand(webPayload: brandingInfo)
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        self.window?.rootViewController = controller
    }
}
