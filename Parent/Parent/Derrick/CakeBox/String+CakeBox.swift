//
//  String+CakeBox.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/29/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
