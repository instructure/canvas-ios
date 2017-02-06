//
//  RootViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit


// loads the root view controller for the current TeachEnvironment
public func rootLoggedInViewController() throws -> UIViewController {
    let courses = try CoursesCollectionViewController.tab()
    
    let tabs = UITabBarController()
    tabs.viewControllers = [courses]
    return tabs
}
