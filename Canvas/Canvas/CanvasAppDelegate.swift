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
import TechDebt
import PSPDFKit
import CanvasKeymaster
import Fabric
import Crashlytics
import CanvasCore
import ReactiveSwift
import BugsnagReactNative

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let loginConfig = LoginConfiguration(mobileVerifyName: "iCanvas", logo: #imageLiteral(resourceName: "login_logo"))
    var session: Session?
    var window: UIWindow?
    var syncDisposable: Disposable?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if unitTesting {
            return true
        }

        BuddyBuildSDK.setup()
        BugsnagReactNative.start()
        TheKeymaster?.fetchesBranding = true
        TheKeymaster?.delegate = loginConfig
        
        window = MasqueradableWindow(frame: UIScreen.main.bounds)
        showLoadingState()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.postLaunchSetup()
        }
        
        return true
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
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return openCanvasURL(url)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.application(application, handleOpen: url)
    }
}

// MARK: Push notifications
extension AppDelegate {

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        #if !arch(i386) && !arch(x86_64)
            application.registerForRemoteNotifications()
        #endif
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        didRegisterForRemoteNotifications(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        didFailToRegisterForRemoteNotifications(error as NSError)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        app(application, didReceiveRemoteNotification: userInfo)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.requestReview()
    }
}

// MARK: Local notifications
extension AppDelegate {
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let assignmentURL = (notification.userInfo?[CBILocalNotificationAssignmentURLKey] as? String).flatMap({ URL(string: $0) }) {
            _ = openCanvasURL(assignmentURL)
        }
    }
}

// MARK: Post launch setup
extension AppDelegate {
    
    func postLaunchSetup() {
        PSPDFKit.license()
        setupCrashlytics()
        prepareReactNative()
        Analytics.prepare()
        NetworkMonitor.engage()
        CBILogger.install(loginConfig.logFileManager)
        Brand.current.apply(self.window!)
        excludeHelmInBranding()
        UINavigationBar.appearance().barStyle = .black
        if let w = window { Brand.current.apply(w) }
        Router.shared().addCanvasRoutes(handleError)
        setupDefaultErrorHandling()
        UIApplication.shared.reactive.applicationIconBadgeNumber
            <~ TabBarBadgeCounts.applicationIconBadgeNumber
    }
}

// MARK: Logging in/out
extension AppDelegate {
    
    func addClearCacheGesture(_ view: UIView) {
        let clearCacheGesture = UITapGestureRecognizer(target: self, action: #selector(clearCache))
        clearCacheGesture.numberOfTapsRequired = 3
        clearCacheGesture.numberOfTouchesRequired = 4
        view.addGestureRecognizer(clearCacheGesture)
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        let alert = UIAlertController(title: NSLocalizedString("Cache cleared", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: nil))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: SoErroneous
extension AppDelegate {
    
    func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
        guard let presentFrom = presentingViewController else { return }
        
        DispatchQueue.main.async {
            let alertDetails = error.alertDetails(reportAction: {
                let support = SupportTicketViewController.present(from: presentingViewController, supportTicketType: SupportTicketTypeProblem)
                support?.reportedError = error
            })
            
            if let deets = alertDetails {
                let alert = UIAlertController(title: deets.title, message: deets.description, preferredStyle: .alert)
                deets.actions.forEach(alert.addAction)
                presentFrom.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setupDefaultErrorHandling() {
        CanvasCore.ErrorReporter.setErrorHandler({ error, presentingViewController in
            self.alertUser(of: error, from: presentingViewController)
            
            if error.shouldRecordInCrashlytics {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: nil)
            }
        })
    }
    
    var visibleController: UIViewController {
        guard var vc = window?.rootViewController else { ❨╯°□°❩╯⌢"No root view controller?!" }
        
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    
    func handleError(_ error: NSError) {
        ErrorReporter.reportError(error, from: window?.rootViewController)
    }
}

// MARK: Crashlytics
extension AppDelegate {
    
    func setupCrashlytics() {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: "Fabric") else {
            NSLog("WARNING: Crashlytics was not properly initialized.");
            return
        }
        
        Fabric.with([Crashlytics.self])
    }
}


// MARK: Launching URLS
extension AppDelegate {
    func openCanvasURL(_ url: URL) -> Bool {
        StartupManager.shared.enqueueTask({
            
            if handleDropboxOpenURL(url) {
                return
            }
            
            if url.scheme == "file" {
                do {
                    try ReceivedFilesViewController.add(toReceivedFiles: url)
                } catch let e as NSError {
                    self.handleError(e)
                }
            } else {
                Router.shared().openCanvasURL(url)
            }
        })
        
        return true
    }
}

import React

extension AppDelegate: RCTBridgeDelegate {
    func prepareReactNative() {
        NativeLoginManager.shared().delegate = self
        NativeLoginManager.shared().app = .student
        HelmManager.shared.bridge = RCTBridge(delegate: self, launchOptions: nil)
        HelmManager.shared.onReactLoginComplete = {
            guard let session = self.session else {
                return
            }

            self.syncDisposable = startSyncingAsyncActions(session)

            let root = rootViewController(session)
            self.addClearCacheGesture(root.view)
            self.window?.rootViewController = root
        }
        
        HelmManager.shared.onReactReload = {
            self.showLoadingState()
        }
        
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/tabs/:tabID", factory: { props in
            guard let tabID = props["tabID"] as? String else { return nil }
            guard let courseID = props["courseID"] as? String else { return nil }

            let session = CanvasKeymaster.the().currentClient.authSession
            let contextID = ContextID.course(withID: courseID)
            
            guard let tabs = try? Tab.collection(session, contextID: contextID) else { return nil }
            guard let tab = tabs.filter({ $0.id == tabID }).first else { return nil }
            guard let url = tab.routingURL(session) else { return nil }
            guard let controller = Router.shared().controller(forHandling: url) else {
                DispatchQueue.main.async {
                    Router.shared().fallbackHandler(url, self.window?.rootViewController)
                }
                return nil
            }
            
            // Work around all these controllers not setting the nav color
            DispatchQueue.main.async {
                controller.navigationController?.navigationBar.barTintColor = (session.enrollmentsDataSource[ContextID(id: courseID, context: .course)] as? Course)?.color.value ?? .black
                controller.navigationController?.navigationBar.tintColor = .white
                controller.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            }
            
            return controller
        })
        
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID/tabs", factory: { props in
            guard let courseID = props["courseID"] as? String else { return nil }
            let url = URL(string: "api/v1/courses/\(courseID)/tabs")
            return Router.shared().controller(forHandling: url)
        })
        
        HelmManager.shared.registerNativeViewController(for: "/users/self/files", factory: { props in
            guard let folderController = FolderViewController(interfaceStyle: FolderInterfaceStyleLight) else { return nil }
            guard let canvasAPI = CKCanvasAPI.current() else { return nil }
            folderController.canvasAPI = canvasAPI
            folderController.title = NSLocalizedString("Files", comment: "")
            let context = CKContextInfo(from: canvasAPI.user)
            folderController.loadRootFolder(forContext: context)
            return UINavigationController(rootViewController: folderController)
        })
        
        HelmManager.shared.registerNativeViewController(for: "/profile/settings", factory: { props in
            let settings = SettingsViewController.controller(CKCanvasAPI.current())
            return UINavigationController(rootViewController: settings)
        })
        
        HelmManager.shared.registerNativeViewController(for: "/groups/:groupID", factory: { props in
            guard let groupID = props["groupID"] as? String else { return nil }
            
            let url = URL(string: "api/v1/groups/\(groupID)/tabs")
            return Router.shared().controller(forHandling: url)
        })

        HelmManager.shared.registerNativeViewController(for: "/launch_external_tool", factory: { props in
            guard let toolUrl = props["url"] as? String else { return nil }
            guard let baseUrl = TheKeymaster?.currentClient.baseURL?.absoluteString else { return nil }
            let sessionlessUrl = "\(baseUrl)/api/v1/accounts/self/external_tools/sessionless_launch?url=\(toolUrl)"
            guard let url = URL(string: sessionlessUrl) else { fatalError("Invalid URL") }
            let toolName = props["toolName"] as? String ?? ""
            let ltiController = LTIViewController(toolName: toolName, courseID: nil, launchURL: url, in: currentSession, showDoneButton: true)
            return UINavigationController(rootViewController: ltiController)
        })
        
        HelmManager.shared.registerSharedNativeViewControllers()
    }
    
    func excludeHelmInBranding() {
        let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [HelmNavigationController.self])
        appearance.barTintColor = nil
        appearance.tintColor = nil
        appearance.titleTextAttributes = nil
    }
    
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        let url = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil)
        return url
    }
}

extension AppDelegate: NativeLoginManagerDelegate {
    func didLogin(_ client: CKIClient) {
        let session = client.authSession
        self.session = session
        
        LegacyModuleProgressShim.observeProgress(session)
        ModuleItem.beginObservingProgress(session)
        CKCanvasAPI.updateCurrentAPI()
        
        if let brandingInfo = client.branding?.jsonDictionary() as? [String: Any] {
            Brand.setCurrent(Brand(webPayload: brandingInfo))
            UITabBar.appearance().tintColor = Brand.current.primaryBrandColor
            UITabBar.appearance().barTintColor = .white
        } else {
            let b = Brand.current
            guard let brand = CKIBrand() else {
                fatalError("Why can't I init a brand?")
            }
            brand.navigationBackground = "#313640" // ask me why this value is hard-coded and I'll tell you a sad sad tale
            brand.navigationButtonColor = b.navButtonColor.hex
            brand.navigationTextColor = b.navTextColor.hex
            brand.primaryColor = b.tintColor.hex
            brand.primaryButtonTextColor = b.secondaryTintColor.hex
            brand.linkColor = b.tintColor.hex
            brand.primaryButtonBackgroundColor = b.tintColor.hex
            brand.primaryButtonTextColor = "#FFFFFF"
            brand.secondaryButtonBackgroundColor = b.secondaryTintColor.hex
            brand.secondaryButtonTextColor = "#FFFFFF"
            brand.fontColorDark = "#000000"
            brand.fontColorLight = "#666666"
            brand.headerImageURL = ""
            
            client.branding = brand
        }
    }
    
    func didLogout(_ controller: UIViewController) {
        self.window?.rootViewController = controller
    }
}
