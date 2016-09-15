//
//  Marshal+SoPersistent.swift
//  Assignments
//
//  Created by Derrick Hathaway on 1/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import Marshal

extension NSNumber: ValueType {
    public static func value(object: Any) throws -> NSNumber {
        guard let n = object as? NSNumber else {
            throw Error.TypeMismatch(expected: NSNumber.self, actual: object.dynamicType)
        }
        return n
    }
}