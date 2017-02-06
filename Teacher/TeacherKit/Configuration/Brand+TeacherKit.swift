//
//  Brand+TeacherKit.swift.swift
//  Teacher
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import SoPretty


extension Brand {
    public static let teacherKit = Brand(
        tintColor:UIColor(hue: 350/360.0, saturation: 1.0, brightness: 0.76, alpha: 0),
        secondaryTintColor: UIColor(hue: 205/360.0, saturation: 0.92, brightness: 0.82, alpha: 1.0),
        navBarTintColor: UIColor(hue: 229/360.0, saturation: 1.0, brightness: 0.24, alpha: 1.0),
        navForegroundColor: .white,
        tabBarTintColor: .white,
        tabsForegroundColor: UIColor(hue: 229/360.0, saturation: 1.0, brightness: 0.24, alpha: 1.0),
        logo: UIImage(named: "logo", in: .teacherKit, compatibleWith: nil)!
    )
}
