//
//  NSSortDescriptor+SoPersistent.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 1/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension String {
    public var ascending: NSSortDescriptor {
        return NSSortDescriptor(key: self, ascending: true)
    }
    public var descending: NSSortDescriptor {
        return NSSortDescriptor(key: self, ascending: false)
    }
}
