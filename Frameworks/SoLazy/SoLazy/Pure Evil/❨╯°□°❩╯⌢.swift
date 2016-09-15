//
//  ❨╯°□°❩╯⌢.swift
//  SoLazy
//
//  Created by Ben Kraus on 3/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

prefix operator ❨╯°□°❩╯⌢ {}
@noreturn prefix public func ❨╯°□°❩╯⌢ (text: String) {
    fatalError("❨╯°□°❩╯⌢ \(text)")
}