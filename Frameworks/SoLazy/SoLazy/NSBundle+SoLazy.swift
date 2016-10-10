//
//  NSBundle+SoLazy.swift
//  SoLazy
//
//  Created by Layne Moseley on 10/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension NSBundle {
    
    static func soLazy() -> NSBundle {
        return NSBundle(identifier: "com.instructure.icanvas.SoLazy")!
    }
}
