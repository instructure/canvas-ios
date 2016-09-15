//
//  UIImage+Color.swift
//  Keymaster
//
//  Created by Brandon Pluim on 1/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}