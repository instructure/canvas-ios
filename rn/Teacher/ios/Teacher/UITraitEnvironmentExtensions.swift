//
//  UIViewControllerExtensions.swift
//  Teacher
//
//  Created by Garrett Richards on 5/17/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

extension UITraitEnvironment {
    func sizeClassInfoForJavascriptConsumption() -> [String: String] {
        let horizontalKey = "horizontal"
        let verticalKey = "vertical"
        var data = [String:String]()
        let horizontalSizeClass = self.traitCollection.horizontalSizeClass
        let verticalSizeClass  = self.traitCollection.verticalSizeClass
        data[horizontalKey] = horizontalSizeClass.description
        data[verticalKey] = verticalSizeClass.description
        return data
    }
}
