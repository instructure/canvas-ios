//
//  ParentSelectDomainDataSource.swift
//  Parent
//
//  Created by Derrick Hathaway on 10/19/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import Keymaster


class ParentSelectDomainDataSource: NSObject, SelectDomainDataSource  {
    static let instance = ParentSelectDomainDataSource()
    
    var logoImage: UIImage = UIImage(named: "parent_logo")!
    var mobileVerifyName: String = "iosParent"
    var tintTopColor: UIColor {
        return ColorScheme.blueColorScheme.inverse().tintTopColor
    }
    var tintBottomColor: UIColor {
        return ColorScheme.blueColorScheme.inverse().tintBottomColor
    }
}

