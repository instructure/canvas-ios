//
//  Session+ManagedObjectContext.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 11/11/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import Marshal
import TooLegit
import CoreData
@testable import AssignmentKit
@testable import FileKit
@testable import EnrollmentKit

extension Session {
    public func managedObjectContext<T: NSManagedObject>(type: T.Type, options: [String: AnyObject] = [:]) -> NSManagedObjectContext {
        let scope: String? = try? options <| "scope"
        let className = NSStringFromClass(object_getClass(T))
        let frameworkName = className.componentsSeparatedByString(".").first!

        let context: NSManagedObjectContext
        switch frameworkName {
        case "AssignmentKit":
            context = try! assignmentsManagedObjectContext(scope)
        case "FileKit":
            context = try! filesManagedObjectContext()
        case "EnrollmentKit":
            context = try! enrollmentManagedObjectContext(scope)
        default: fatalError("Plz to add your context above for \(frameworkName)")
        }

        return context
    }
}
