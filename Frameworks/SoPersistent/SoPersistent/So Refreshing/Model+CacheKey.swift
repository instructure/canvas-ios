//
//  Model+CacheKey.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 3/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    public static func cacheKey(context: NSManagedObjectContext, _ values: [AnyObject] = []) -> String {
        return entityName(context)
            + "://"
            + (values.map { "\($0)" }).joinWithSeparator("//")
    }
}