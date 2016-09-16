//
//  IconTodayView.swift
//  Calendar
//
//  Created by Brandon Pluim on 5/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

class IconTodayView : UIView {
    
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var imgIconBackground: UIImageView!
    
    
    class func instantiateFromNib(date: NSDate, tintColor: UIColor?, target: AnyObject, action: Selector) -> IconTodayView? {
        if let todayView = IconTodayView.loadFromNibNamed("IconTodayView", bundle: IconTodayView.bundle) as? IconTodayView {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d"
            todayView.lblDayOfMonth.text = dateFormatter.stringFromDate(date)
            
            let calendarImage = UIImage(named: "icon_today", inBundle: IconTodayView.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            todayView.imgIconBackground.image = calendarImage
            todayView.imgIconBackground.tintColor = tintColor
            
            todayView.lblDayOfMonth.textColor = tintColor
            todayView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
            
            return todayView
        }
        
        return nil
    }
}