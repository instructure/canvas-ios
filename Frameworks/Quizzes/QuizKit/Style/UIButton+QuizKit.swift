//
//  UIButton+QuizKit.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 3/9/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import SoPretty

extension UIButton {
    func makeItBlue() {
        titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        backgroundColor = Brand.current().tintColor
        layer.cornerRadius = 5.0
    }
}