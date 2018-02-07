//
//  Tab+Modules.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/28/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

extension Tab {
    private static func predicate(id: String, contextID: ContextID) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "rawContextID", contextID.canvasContextID)
    }

    public static func modulesTab(for context: ContextID, in session: Session) throws -> Tab? {
        let moc = try session.enrollmentManagedObjectContext()
        return try moc.findOne(withPredicate: predicate(id: "modules", contextID: context))
    }

    public static func homeTab(for context: ContextID, in session: Session) throws -> Tab? {
        let moc = try session.enrollmentManagedObjectContext()
        return try moc.findOne(withPredicate: predicate(id: "home", contextID: context))
    }
}
