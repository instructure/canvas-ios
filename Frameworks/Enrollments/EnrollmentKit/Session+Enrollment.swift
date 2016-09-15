//
//  Session+Course.swift
//  Enrollments
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let enrollmentKitModelName = "EnrollmentKit"
let enrollmentKitSubdomain = "EnrollmentKit"
let enrollmentKitFailedToLoadErrorCode = 10001
let enrollmentKitFailedToLoadErrorDescription = "Failed to load \(enrollmentKitModelName) NSManagedObjectModel"
let enrollmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the EnrollmentKit database file.", comment: "EnrollmentKit Database Load Failure Message")

extension Session {
    public func enrollmentManagedObjectContext(scope: String? = nil) throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: enrollmentKitModelName, inBundle: NSBundle(forClass: Course.self))?.mutableCopy() as! NSManagedObjectModel
        let storeName = scope == nil ? enrollmentKitModelName : "\(enrollmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
            localizedErrorDescription: enrollmentKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}


// MARK: Colorful

extension Session {
    public func colorForCourse(courseID: String) -> UIColor {
        let context = ContextID(id: courseID, context: .Course)
        let color = enrollmentsDataSource[context]?.color ?? .prettyGray()
        print("colorForCourse = \(color)")
        return color
    }
    
    public func colorForGroup(groupID: String) -> UIColor {
        let context = ContextID(id: groupID, context: .Group)
        let color = enrollmentsDataSource[context]?.color ?? .prettyGray()
        print("colorForGroup = \(color)")
        return color
    }
    
    
    public func courseWithID(courseID: String) -> Course? {
        return enrollmentsDataSource[ContextID(id: courseID, context: .Course)] as? Course
    }
    
    public func groupWithID(groupID: String) -> Group? {
        return enrollmentsDataSource[ContextID(id: groupID, context: .Group)] as? Group
    }
}