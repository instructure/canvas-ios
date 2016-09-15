//
//  AppDelegate.swift
//  Vanilla
//
//  Created by Derrick Hathaway on 1/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

import SoPersistent
import Keymaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SelectDomainDataSource {

    
    var window: UIWindow?
    
    var logoImage: UIImage = UIImage(named: "vanilla_logo_image")!
    var mobileVerifyName: String = "iCanvas"
    var tintTopColor: UIColor = UIColor(hue: 28/360.0, saturation: 0.7, brightness: 0.57, alpha: 1.0)
    var tintBottomColor: UIColor = UIColor(hue: 43/360.0, saturation: 0.18, brightness: 1.0, alpha: 1.0)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let selectDomainVC = SelectDomainViewController.new()
        selectDomainVC.pickedDomainAction = { domain in
            print(domain)
        }
        selectDomainVC.pickedSessionAction = { session in
            print(session)
        }
        selectDomainVC.dataSource = self
        
        let navController = UINavigationController(rootViewController: selectDomainVC)
        navController.navigationBarHidden = true
        window?.rootViewController = navController
        
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

struct VanillaViewModel: TableViewCellViewModel {
    
    let name: String
    let subtitle: String
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: "AssignmentCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "VanillaCell")
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VanillaCell", forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = subtitle
        return cell
    }
}

