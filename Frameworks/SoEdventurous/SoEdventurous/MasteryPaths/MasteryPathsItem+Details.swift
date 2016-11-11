//
//  MasteryPathsItem+Details.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 10/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

extension MasteryPathsItem {
    public static func predicateForMasteryPathsItem(inModule moduleID: String, fromItemWithMasteryPaths moduleItemID: String) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "%K == %@", "moduleID", moduleID), NSPredicate(format: "%K == %@", "moduleItemID", moduleItemID)])
    }
}
