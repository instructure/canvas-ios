//
//  UIImage+SoLazy.swift
//  iCanvas
//
//  Created by Ben Kraus on 8/12/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public extension UIImage {
    public func resizedImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// Creates an image that has RTL support if available
    public static func RTLImage(named: String, renderingMode: UIImageRenderingMode? = nil) -> UIImage? {
        var image = UIImage(named: named)
        if let mode = renderingMode {
            image = image?.imageWithRenderingMode(mode)
        }
        
        if #available(iOS 9.0, *) {
            return image?.imageFlippedForRightToLeftLayoutDirection()
        }
        
        return image
     }
}