//
//  Tab+Modules.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/28/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

extension Tab {
    static func modulesTab(for context: ContextID, in session: Session) throws -> Tab? {
        let moc = try session.enrollmentManagedObjectContext()
        return try moc.findOne(withPredicate: NSPredicate(format: "%K == 'modules' && %K == %@", "id", "rawContextID", context.canvasContextID))
    }
}
