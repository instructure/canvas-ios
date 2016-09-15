//
//  UIFont+SoLazy.swift
//  SoLazy
//
//  Created by Ben Kraus on 4/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public extension UIFont {
    public func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
            options: unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.UsesFontLeading.rawValue, NSStringDrawingOptions.self),
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}