//
//  LoadCalendarViewFromNib.swift
//  Calendar
//
//  Created by Brandon Pluim on 2/10/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib( nibName: nibNamed, bundle: bundle ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}