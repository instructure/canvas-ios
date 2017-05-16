//
//  UIUserInterfaceSizeClassExtensions.swift
//  Teacher
//
//  Created by Garrett Richards on 5/15/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

extension UIUserInterfaceSizeClass {
    var description: String {
        get {
            switch(self) {
            case .compact: return "compact"
            case .regular: return "regular"
            case .unspecified: fallthrough
            default: return "unspecified"
            }
        }
    }
}
