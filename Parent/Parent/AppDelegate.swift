//
//  AppDelegate.swift
//  Parent
//
//  Created by Brandon Pluim on 1/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit
import Keymaster
import ObserverAlertKit
import TooLegit
import WhizzyWig
import Fabric
import Crashlytics
import Airwolf

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var topViewController: UIViewController {
        var topViewControler = window!.rootViewController!
        while topViewControler.presentedViewController != nil {
            topViewControler = topViewControler.presentedViewController!
        }
        return topViewControler
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        if let url = RegionPicker.defaultPicker.pickedRegionURL {
            AirwolfAPI.baseURL = url
        } else {
            if let _ = Keymaster.sharedInstance.mostRecentSession() { // Currently already signed in, without a region. They are already in the original default region
                RegionPicker.defaultPicker.setRegionToDefault()
                AirwolfAPI.baseURL = RegionPicker.defaultPicker.pickedRegionURL!
            } else {
                RegionPicker.defaultPicker.pickBestRegion { url in
                    if let url = url {
                        AirwolfAPI.baseURL = url
                    }
                }
            }
        }

        WhizzyWigView.setOpenURLHandler { url in
            let webBrowser = WebBrowserViewController(useAPISafeLinks: false)
            webBrowser.url = url
            let nav = UINavigationController(rootViewController: webBrowser)
            self.topViewController.presentViewController(nav, animated: true, completion: nil)
        }
        
        Router.sharedInstance.addRoutes()

        Keymaster.sharedInstance.useSharedCredentials = false
        if let session = Keymaster.sharedInstance.mostRecentSession() {
            Keymaster.sharedInstance.currentSession = session
            Router.sharedInstance.session = session
            Router.sharedInstance.routeToLoggedInViewController()
        } else {
            Router.sharedInstance.routeToLoggedOutViewController()
        }

        window!.makeKeyAndVisible()

        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            routeToRemindable(from: notification)
        }

        return true
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        // On, iOS 10.0b1 application:didReceiveLocalNotification is not being called when opening the app from a local notification and making it transistion from the background. Instead, this is being called. Not
        // sure if this is a bug or some change in API behavior.
        // 
        // This api exists as of 9.0, but the odd behavior only exists as of 10.0, so...
        if #available(iOS 10.0, *) {
            routeToRemindable(from: notification)
        }
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if application.applicationState == .Active {
            let alert = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("View", comment: ""), style: .Cancel, handler: { [unowned self] _ in
                self.routeToRemindable(from: notification)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { _ in }))
            topViewController.presentViewController(alert, animated: true, completion: nil)
        } else if application.applicationState == .Inactive {
            routeToRemindable(from: notification)
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == "canvas-parent" {
            if let _ = Keymaster.sharedInstance.currentSession {
                Router.sharedInstance.route(self.topViewController, toURL: url, modal: false)
            } else if let window = self.window, vc = Router.sharedInstance.viewControllerForURL(url) {
                Router.sharedInstance.route(window, toRootViewController: vc)
            } else {
                // should never get here... should either have a session or a window!
            }
        }

        return false
    }

    private func routeToRemindable(from notification: UILocalNotification) {
        if let urlString = notification.userInfo?[RemindableActionURLKey] as? String, url = NSURL(string: urlString) {
            Router.sharedInstance.route(topViewController, toURL: url, modal: true)
        }
    }

}

