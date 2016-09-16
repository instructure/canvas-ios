//
//  UIColor+Calendar.swift
//  Calendar
//
//  Created by Brandon Pluim on 4/17/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

public extension UIColor {
    class var calendarTintColor: UIColor {
        return UIColor(red: 9.0/255.0, green: 188.0/255.0, blue: 211.0/255.0, alpha: 1.0)
    }
    class var calendarHighlightTintColor: UIColor {
        return UIColor(red: 179.0/255.0, green: 224.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }
    
    class var calendarDayCircleColor: UIColor {
        return UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    }
    
    class var calendarDayDetailBackgroundColor: UIColor {
        return UIColor(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    }
    
    class var calendarNoResultsTextColor: UIColor {
        return UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    }
    
    class var calendarDayOffTextColor: UIColor {
        return UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 145.0/255.0, alpha: 1.0)
    }
    
    class var calendarDaysOfWeekBackgroundColor: UIColor {
        return UIColor(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    }
}