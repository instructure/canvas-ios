//
//  UIImage+Resize.swift
//  Parent
//
//  Created by Brandon Pluim on 3/16/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

extension UIImage {
    func imageScaledToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func imageScaledByPercentage(percent: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * percent, height: size.height * percent)
        return imageScaledToSize(newSize)
    }
}
