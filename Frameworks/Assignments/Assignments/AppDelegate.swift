//
//  AppDelegate.swift
//  Assignments
//
//  Created by Derrick Hathaway on 1/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import AssignmentKit
import SoPersistent
import SoLazy
import DoNotShipThis
import Keymaster
import FileKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if unitTesting {
            return true
        }

        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let courseID: String = "24219" // Beginning iOS
//        let courseID: String = "1140383" // Advanced Lobster Tasting
//        let courseID: String = "1787647" // All Hands On Deck
//        let courseID: String = "1422605"
        
        let navigationController = UINavigationController()
        let session = Session.nas
        // Keymaster.sharedInstance.addSession(session)
        let vc = try! AssignmentList(session: session, courseID: courseID)
        
        navigationController.viewControllers = [vc]
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible() 

        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("received local notification. Probably an assignment reminder. You can handle this later once you have a router")
        
        let alert = UIAlertView()
        alert.title = "Alert"
        alert.message = notification.alertBody
        alert.addButtonWithTitle("Dismiss")
        
        alert.show()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        let session = Session.nas // TODO: get real session
        do {
            let uploads = try Upload.inProgress(session)
            try addUploadCompletionHandlers(session, uploads: uploads)
        } catch {
            // oh well
        }
    }

    func addUploadCompletionHandlers(session: Session, uploads: [Upload]) throws {
        for upload in uploads {
            if let fileUpload = upload as? SubmissionFileUpload {
                let backgroundSession = session.copyToBackgroundSessionWithIdentifier(upload.backgroundSessionID, sharedContainerIdentifier: nil)
                try fileUpload.addCompletionHandler(inSession: backgroundSession)
            }
        }
    }

}
