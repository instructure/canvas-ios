//
//  ObserverCourseListViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
//import CakeBox
import CoreData
//import ThreeLegit
import ReactiveCocoa
import JaSON

extension Course {
    func colorfulViewModel() -> ColorfulViewModel {
        return ColorfulViewModel(name: name)
    }
}

public func observerCourseListViewController(session: Session, userID: Int64) throws -> UIViewController {
    
    // Holiday Extravaganza TODO: SoErroneous
    guard let model = NSManagedObjectModel(named: "CourseKit", inBundle: NSBundle(forClass: Assignment.self)) else { fatalError("problems?") }
    let storeURL = session.localStoreDirectoryURL.URLByAppendingPathComponent("courses.sqlite")
    
    let context = try NSManagedObjectContext(storeURL: storeURL, model: model)
    
    return try Course.tableViewController(nil, context: context, remote: Course.getCoursesByUser(session, userID: userID)) { $0.colorfulViewModel() }
}
