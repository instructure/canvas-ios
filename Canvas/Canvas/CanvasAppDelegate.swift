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
import Fabric
import Crashlytics
import Secrets
import AttendanceLE

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
            _ = openCanvasURL(assignmentURL)
        }
    }
}

// MARK: Post launch setup
extension AppDelegate {
    func makeAWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        window?.makeKeyAndVisible()
    }
    
    func postLaunchSetup() {
        PSPDFKit.license()
        self.setupCrashlytics()
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
    
    func alertUser(of error: NSError, from presentingViewController: UIViewController?) {
        guard let presentFrom = presentingViewController else { return }
        
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
    
    func setupDefaultErrorHandling() {
        SoLazy.ErrorReporter.setErrorHandler({ error, presentingViewController in
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
