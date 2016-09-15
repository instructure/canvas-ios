//
//  UIColor+Toast.swift
//  iCanvas
//
//  Created by Kyle Longhurst on 8/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

extension UIColor {
    public static var toastSuccess: UIColor {
        return UIColor(red: 0x00/255.0, green: 0xAD/255.0, blue: 0x18/255.0, alpha: 1.0)
    }
    public static var toastInfo: UIColor {
        return UIColor(red: 0x00/255.0, green: 0x96/255.0, blue: 0xDB/255.0, alpha: 1.0)
    }
    public static var toastFailure: UIColor {
        return UIColor(red: 0xAD/255.0, green: 0x39/255.0, blue: 0x3A/255.0, alpha: 1.0)
    }
}