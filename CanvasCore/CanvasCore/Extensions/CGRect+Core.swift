//
//  CGRect+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 9/25/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

extension CGRect {
    
    // Clamps the rect inside of `size`
    // Example:
    //  If your rect is (100, 100), and you pass in (50, 50), the returns rect will be (50x50)
    //  If you pass in an inset of 10, the resulting rect would be (40x40)
    public func clamp(_ size: CGSize, inset: CGFloat = 0.0) -> CGRect {
        var clamped = self
        if clamped.width > size.width {
            clamped.size.width = size.width - inset
        }
        if clamped.height > size.height {
            clamped.size.height = size.height - inset
        }
        return clamped
    }
}
