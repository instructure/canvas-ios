//
//  UIImage+FileKit.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/24/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoLazy

extension UIImage {
    public static func FileKitImageNamed(_ name: String) -> UIImage {
        guard let image = UIImage(named: name, in: .fileKit, compatibleWith: nil) else { ❨╯°□°❩╯⌢"Cannot load image named \(name) from FileKit.framework" }

        return image
    }
}
