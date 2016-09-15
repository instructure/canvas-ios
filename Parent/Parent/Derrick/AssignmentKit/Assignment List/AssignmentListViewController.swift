//
//  AssignmentListViewController.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/23/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit
//import CakeBox
import CoreData
//import ThreeLegit
import ReactiveCocoa
import JaSON

extension Assignment {
    func colorfulViewModel() -> ColorfulViewModel {
        return ColorfulViewModel(name: name)
    }
}

public func assignmentListViewController(session: Session, courseID: Int64) throws -> UIViewController {
    
    // Holiday Extravaganza TODO: SoErroneous
    guard let model = NSManagedObjectModel(named: "AssignmentKit", inBundle: NSBundle(forClass: Assignment.self)) else { fatalError("problems?") }
    let storeURL = session.localStoreDirectoryURL.URLByAppendingPathComponent("assignments.sqlite")
    
    let context = try NSManagedObjectContext(storeURL: storeURL, model: model)
    
    let forCourse = NSPredicate(format:"%K == %@", "courseID", NSNumber(longLong: courseID))
    
    return try Assignment.tableViewController(forCourse, context: context, remote: Assignment.getAssignments(session, courseID: courseID)) { $0.colorfulViewModel() }
}
