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
import TooLegit
import TechDebt
import PSPDFKit
import SoPretty
import SoLazy
import SoPersistent
import SoEdventurous
import CanvasKeymaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if unitTesting {
            return true
        }

        BuddyBuildSDK.setup()
        
        makeAWindow()
        postLaunchSetup()
        prepareTheKeymaster()
        
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if url.scheme == "file" {
            do {
                try ReceivedFilesViewController.add(toReceivedFiles: url)
                return true
            } catch let e as NSError {
                handleError(e)
            }
        } else if url.scheme == "canvas-courses" {
            return openCanvasURL(url)
        } else if handleDropboxOpenURL(url) {
            return true
        }
        
        return false
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
    
}

// MARK: Local notifications
extension AppDelegate {
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let assignmentURL = (notification.userInfo?[CBILocalNotificationAssignmentURLKey] as? String).flatMap({ URL(string: $0) }) {
            openCanvasURL(assignmentURL)
        }
    }
}

// MARK: Post launch setup
extension AppDelegate {
    func makeAWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    }
    
    func postLaunchSetup() {
        PSPDFKit.license()
        Crashlytics.prepare()
        Analytics.prepare()
        NetworkMonitor.engage()
        CBILogger.install(LoginConfiguration.sharedConfiguration.logFileManager)
        Brand.current().apply(self.window!)
        UINavigationBar.appearance().barStyle = .black
        Router.shared().addCanvasRoutes(handleError)
        setupDefaultErrorHandling()
    }
}

// MARK: Logging in/out
extension AppDelegate {
    
    func prepareTheKeymaster() {
        TheKeymaster?.delegate = LoginConfiguration.sharedConfiguration

        Session.logoutSignalProducer
            .startWithValues(didLogout)
        
        Session.loginSignalProducer
            .startWithValues(didLogin)
    }
    
    func didLogin(_ session: Session) {

        LegacyModuleProgressShim.observeProgress(session)
        ModuleItem.beginObservingProgress(session)
        Crashlytics.setDebugInformation()
        ConversationUpdater.shared().updateUnreadConversationCount()
        CKCanvasAPI.updateCurrentAPI() // set's currenAPI from CKIClient.currentClient()
        
        let root = rootViewController(session)
        addClearCacheGesture(root.view)

        window?.rootViewController = root
    }
    
    func didLogout(_ domainPicker: UIViewController) {
        window?.rootViewController = domainPicker
    }
    
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
    
    func presentErrorAlert(_ presentingViewController: UIViewController, error: NSError) {
        error.presentAlertFromViewController(presentingViewController, reportError: {
            let support = SupportTicketViewController.present(from: presentingViewController, supportTicketType: SupportTicketTypeProblem)
            support?.initialTicketBody = error.reportDescription
        })
    }
    
    func setupDefaultErrorHandling() {
        TableViewController.defaultErrorHandler = presentErrorAlert
        CollectionViewController.defaultErrorHandler = presentErrorAlert
        
        SoLazy.ErrorReporter.setErrorHandler({ error, userInfo in 
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: userInfo)
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
        if let vc = window?.rootViewController  {
            presentErrorAlert(vc, error: error)
        }
    }
}


// MARK: Launching URLS
extension AppDelegate {
    func openCanvasURL(_ url: URL) -> Bool {
    
        if url.scheme == "canvas-courses" {
            Router.shared().openCanvasURL(url)
            return true
        }
        
        if url.scheme == "file" {
            do {
                try ReceivedFilesViewController.add(toReceivedFiles: url)
                return true
            } catch let e as NSError {
                handleError(e)
                return false
            }
        }
        
        if handleDropboxOpenURL(url) {
            return true
        }
        
        Router.shared().openCanvasURL(url)
        return true
    }
}
