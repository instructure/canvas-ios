//
//  UIImage+SoIconic.swift
//  Icons
//
//  Created by Derrick Hathaway on 6/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation


let bundle = NSBundle(identifier: "com.instructure.SoIconic")!

extension UIImage {
    public static func icon(icon: Icon, filled: Bool = false) -> UIImage {
        let name = icon.imageName(filled)
        guard let icon = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil) else {
            fatalError("An image does not exist for the Icon/Filled/Size combination specified: \(name). Please add the varient to SoIconic.framework")
        }
        
        return icon
    }
}