//
//  Upload+Details.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/12/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoPersistent
import TooLegit

extension Upload {
    public static func predicate(id: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", id)
    }
}
