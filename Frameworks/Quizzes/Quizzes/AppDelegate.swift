//
//  AppDelegate.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 12/23/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import QuizKit
import TooLegit
import DoNotShipThis


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)
    
    let defaultSession = Session.art
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)

        let courseID = "968776"
        let quizID = "3357679"
        let baseURL = defaultSession.baseURL
        let url = baseURL/api/v1/"courses"/courseID/"quizzes"/quizID
        let v = QuizIntroViewController(session: defaultSession, quizURL: url, quizID: quizID)
        
        window?.rootViewController = UINavigationController(rootViewController:v)
        window?.makeKeyAndVisible()
        
        return true
    }
}
