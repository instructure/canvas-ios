//
//  ModuleItem+Details.swift
//  SoEdventurous
//
//  Created by Nathan Armstrong on 9/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoPersistent
import TooLegit

extension ModuleItem {
    public static func observer(session: Session, moduleItemID: String) throws -> ManagedObjectObserver<ModuleItem> {
        let context = try session.soEdventurousManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "id", moduleItemID)
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }
}
